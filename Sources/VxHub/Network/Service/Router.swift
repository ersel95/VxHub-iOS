//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

public typealias NetworkRouterCompletion = @Sendable (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

public struct NetworkRouterCompletionWrapper: @unchecked Sendable {
    public let completion: NetworkRouterCompletion
    
    public init(completion: @escaping NetworkRouterCompletion) {
        self.completion = completion
    }
}

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func request(_ route: EndPoint) async throws -> (Data, URLResponse)
    func cancel()
}

private enum RouterConfig {
    static let lock = NSLock()
    nonisolated(unsafe) static var sharedSession: URLSession?
    static let maxRetries = 2
    static let retryDelay: TimeInterval = 1.0
}

class Router<EndPoint: EndPointType>: NetworkRouter, @unchecked Sendable {
    private var task: URLSessionTask?
    private let vxHubNetworkQueue = DispatchQueue(label: "com.vxhub.networkQueue", qos: .userInitiated)
    private let vxHubNetworkResponseQueue = DispatchQueue.main

    private var session: URLSession {
        RouterConfig.lock.lock()
        defer { RouterConfig.lock.unlock() }
        if let existing = RouterConfig.sharedSession {
            return existing
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        let newSession = URLSession(configuration: config, delegate: URLSesionClientCertificateHandling(), delegateQueue: nil)
        RouterConfig.sharedSession = newSession
        return newSession
    }

    internal func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        do {
            let request = try self.buildRequest(from: route)
            VxLogger.shared.logRequest(request: request)
            self.performRequest(request, retriesLeft: RouterConfig.maxRetries, completion: completion)
        } catch {
            vxHubNetworkResponseQueue.async {
                completion(nil, nil, error)
            }
        }
    }

    private func performRequest(_ request: URLRequest, retriesLeft: Int, completion: @escaping NetworkRouterCompletion) {
        let currentTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            // Retry on transport errors (not HTTP errors), if retries remain
            if let error = error as? URLError, retriesLeft > 0 {
                VxLogger.shared.warning("Network request failed (\(error.code.rawValue)), retrying... (\(retriesLeft) left)")
                DispatchQueue.global().asyncAfter(deadline: .now() + RouterConfig.retryDelay) {
                    self.performRequest(request, retriesLeft: retriesLeft - 1, completion: completion)
                }
                return
            }

            self.vxHubNetworkResponseQueue.async {
                completion(data, response, error)
            }
        }
        self.task = currentTask
        currentTask.resume()
    }

    internal func request(_ route: EndPoint) async throws -> (Data, URLResponse) {
        let request = try self.buildRequest(from: route)
        VxLogger.shared.logRequest(request: request)

        var lastError: Error?
        for attempt in 0...RouterConfig.maxRetries {
            do {
                return try await session.data(for: request)
            } catch let error as URLError {
                lastError = error
                if attempt < RouterConfig.maxRetries {
                    VxLogger.shared.warning("Async network request failed (\(error.code.rawValue)), retrying... (\(RouterConfig.maxRetries - attempt) left)")
                    try await Task.sleep(nanoseconds: UInt64(RouterConfig.retryDelay * 1_000_000_000))
                }
            }
        }
        throw lastError ?? URLError(.unknown)
    }

    func cancel() {
        self.task?.cancel()
    }
    
    internal func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                               let additionalHeaders):
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}
