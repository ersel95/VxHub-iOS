//
//  File.swift
//  VxHub
//
//  Created by furkan on 12.11.2024.
//

import Foundation
import UIKit
import SwiftUICore

internal enum SubDirectories: String {
    case baseDir, thirdPartyDir, imagesDir, videoDir
    
    var folderName: String? {
        switch self {
        case .baseDir:
            return nil
        case .thirdPartyDir:
            return "VxThirdPartyResources"
        case .imagesDir:
            return "VxImages"
        case .videoDir:
            return "VxVideos"
        }
    }
}

internal struct VxFileManager: @unchecked Sendable {
    private let vxHubDirectoryName = "VxHub"
    private let fileOperationQueue = DispatchQueue(label: "com.vxhub.filemanager", qos: .userInitiated)
    
    public init() {
        let _  = createVxHubDirectoryIfNeeded(for: SubDirectories.baseDir)
    }
    
    // MARK: - Directory Creation
    
    private func createVxHubDirectoryIfNeeded(for dir: SubDirectories?) -> Bool {
        let vxHubURL = self.vxHubDirectoryURL(for: dir)
        if !FileManager.default.fileExists(atPath: vxHubURL.path) {
            do {
                try FileManager.default.createDirectory(at: vxHubURL, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }else {
            return true
        }
    }
    
    internal func vxHubDirectoryURL(for type: SubDirectories?) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let baseDirectory = documentsDirectory.appendingPathComponent(vxHubDirectoryName, isDirectory: true)
        if let type = type, let folderName = type.folderName {
            return baseDirectory.appendingPathComponent(folderName, isDirectory: true)
        } else {
            return baseDirectory
        }
    }
    
    // MARK: - Save Data
    
    func save(_ data: Data, type: SubDirectories, fileName: String, overwrite: Bool = true, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        fileOperationQueue.async {
            guard self.createVxHubDirectoryIfNeeded(for: type) == true else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "VxHub", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create directory"])))
                }
                return
            }
            
            let folderURL = self.vxHubDirectoryURL(for: type)
            var adjustedFileName = fileName
            
            if type == .videoDir, !fileName.hasSuffix(".mp4") {
                adjustedFileName += ".mp4"
            }
            
            let fileURL = folderURL.appendingPathComponent(adjustedFileName)
            do {
                if overwrite, FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    // MARK: - Image Helpers
    
    public func saveImage(_ image: UIImage, named imageName: String, completion: @escaping @Sendable (Bool) -> Void) {
        fileOperationQueue.async {
            let imageURL = self.pathForImage(named: imageName)
            guard let imageData = image.pngData() else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            do {
                try imageData.write(to: imageURL)
                DispatchQueue.main.async { completion(true) }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    public func getImage(url imageUrl: String, isLocalized: Bool = false, completion: @escaping @Sendable (Image?) -> Void) {
        fileOperationQueue.async {
            let imageName: String
            if isLocalized {
                imageName = self.localizedKeyForImage(imageUrl) ?? "Error"
            } else {
                let url = URL(string: imageUrl)
                imageName = url?.lastPathComponent ?? ""
            }
            let imageURL = self.pathForImage(named: imageName)
            guard FileManager.default.fileExists(atPath: imageURL.path) else {
                DispatchQueue.main.async {
                    VxLogger.shared.error("Image not found at path: \(imageURL.path)")
                    completion(nil)
                }
                return
            }
            guard let uiImage = UIImage(contentsOfFile: imageURL.path) else {
                DispatchQueue.main.async {
                    VxLogger.shared.error("Failed to load image at path: \(imageURL.path)")
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(Image(uiImage: uiImage))
            }
        }
    }
    
    public func imageExists(named imageName: String, isLocalized: Bool, completion: @escaping @Sendable (Bool) -> Void) {
        fileOperationQueue.async {
            let imageURL = self.pathForImage(named: imageName)
            let exists = FileManager.default.fileExists(atPath: imageURL.path)
            DispatchQueue.main.async {
                completion(exists)
            }
        }
    }
    
    public func getUiImage(url imageUrl: String, isLocalized: Bool = false, completion: @escaping @Sendable (UIImage?) -> Void) {
        fileOperationQueue.async {
            let imageName: String
            if isLocalized {
                imageName = self.localizedKeyForImage(imageUrl) ?? "Error"
            } else {
                let url = URL(string: imageUrl)
                imageName = url?.lastPathComponent ?? ""
            }
            let imageURL = self.pathForImage(named: imageName)
            guard FileManager.default.fileExists(atPath: imageURL.path) else {
                DispatchQueue.main.async {
                    VxLogger.shared.error("Image not found at path: \(imageURL.path)")
                    completion(nil)
                }
                return
            }
            guard let image = UIImage(contentsOfFile: imageURL.path) else {
                DispatchQueue.main.async {
                    VxLogger.shared.error("Error: Could not load image at path: \(imageURL.path)")
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    // MARK: - Async Methods

    func save(_ data: Data, type: SubDirectories, fileName: String, overwrite: Bool = true) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            save(data, type: type, fileName: fileName, overwrite: overwrite) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func saveImage(_ image: UIImage, named imageName: String) async -> Bool {
        await withCheckedContinuation { continuation in
            saveImage(image, named: imageName) { success in
                continuation.resume(returning: success)
            }
        }
    }

    public func getImage(url imageUrl: String, isLocalized: Bool = false) async -> Image? {
        await withCheckedContinuation { continuation in
            getImage(url: imageUrl, isLocalized: isLocalized) { image in
                continuation.resume(returning: image)
            }
        }
    }

    public func getUiImage(url imageUrl: String, isLocalized: Bool = false) async -> UIImage? {
        await withCheckedContinuation { continuation in
            getUiImage(url: imageUrl, isLocalized: isLocalized) { image in
                continuation.resume(returning: image)
            }
        }
    }

    public func imageExists(named imageName: String, isLocalized: Bool) async -> Bool {
        await withCheckedContinuation { continuation in
            imageExists(named: imageName, isLocalized: isLocalized) { exists in
                continuation.resume(returning: exists)
            }
        }
    }

    // MARK: - Helpers

    public func localizedKeyForImage(_ imageUrlString: String?) -> String? {
        guard let imageUrlString = imageUrlString else { return nil }
        guard let imageUrl = URL(string: imageUrlString) else { return nil }
        let urlKey = imageUrl.path.dropFirst()
        let components = urlKey.split(separator: "/")
        let fileName = components.suffix(3).joined(separator: "-")
        return String(fileName)
    }
    
    public func pathForImage(named imageName: String) -> URL {
        var imageURL = vxHubDirectoryURL(for: .imagesDir).appendingPathComponent(imageName)
        if !imageURL.absoluteString.contains("file://") {
            imageURL = URL(fileURLWithPath: imageURL.path)
        }
        return imageURL
    }
    
    public func pathForVideo(named videoName: String) -> URL {
        var adjustedVideoName = videoName
        if !adjustedVideoName.hasSuffix(".mp4") {
            adjustedVideoName += ".mp4"
        }
        
        var videoURL = vxHubDirectoryURL(for: .videoDir).appendingPathComponent(adjustedVideoName)
        if !videoURL.absoluteString.contains("file://") {
            videoURL = URL(fileURLWithPath: videoURL.path)
        }
        return videoURL
    }

}
