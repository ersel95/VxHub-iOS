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
    case baseDir, thirdPartyDir, imagesDir

    var folderName: String? {
        switch self {
        case .baseDir:
            return nil
        case .thirdPartyDir:
            return "VxThirdPartyResources"
        case .imagesDir:
            return "VxImages"
        }
    }
}

public final class VxFileManager: @unchecked Sendable {
    private let vxHubDirectoryName = "VxHub"
    public static let shared = VxFileManager()
    private let fileOperationQueue = DispatchQueue(label: "com.vxhub.filemanager", qos: .userInitiated)

    private init() {
        createVxHubDirectoryIfNeeded(for: SubDirectories.baseDir)
    }

    // MARK: - Directory Creation

    private func createVxHubDirectoryIfNeeded(for dir: SubDirectories?) {
        let vxHubURL = vxHubDirectoryURL(for: dir)
        if !FileManager.default.fileExists(atPath: vxHubURL.path) {
            do {
                try FileManager.default.createDirectory(at: vxHubURL, withIntermediateDirectories: true, attributes: nil)
                print("Created directory: \(vxHubURL.path)")
            } catch {
                print("Error creating VxHub directory: \(error)")
            }
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
            self.createVxHubDirectoryIfNeeded(for: type)
            let folderURL = self.vxHubDirectoryURL(for: type)
            let fileURL = folderURL.appendingPathComponent(fileName)

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
                print("Error saving image: \(error)")
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
}
