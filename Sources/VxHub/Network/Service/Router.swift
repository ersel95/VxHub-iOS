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
    func cancel()
}

class Router<EndPoint: EndPointType>: NetworkRouter, @unchecked Sendable {
    private var task: URLSessionTask?
    private let vxHubNetworkQueue = DispatchQueue(label: "com.vxhub.networkQueue", qos: .userInitiated)
    private let vxHubNetworkResponseQueue = DispatchQueue.main
    
    internal func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
//        vxHubNetworkQueue.async { [weak self] in
//            guard let self else { return }
            let session = URLSession.shared
            do {
                let request = try self.buildRequest(from: route)
//                NetworkLogger.log(request: request)
                task = session.dataTask(with: request, completionHandler: { data, response, error in
                    self.vxHubNetworkResponseQueue.async { [weak self] in
                        guard self != nil else { return }
                        completion(data, response, error)
                    }
                })
            }catch {
                vxHubNetworkResponseQueue.async { [weak self] in
                    guard self != nil else { return }
                    completion(nil, nil, error)
                }
            }
            self.task?.resume()
//        }
    }
    
    func cancel() {
//        vxHubNetworkQueue.async { [weak self] in
//            guard let self else { return }
            self.task?.cancel()
//        }
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
