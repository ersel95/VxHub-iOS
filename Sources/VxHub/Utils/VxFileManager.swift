//
//  File.swift
//  VxHub
//
//  Created by furkan on 12.11.2024.
//

import Foundation
import UIKit
import SwiftUICore


internal enum SubDirectories : String {
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
    
    private init() {
        createVxHubDirectoryIfNeeded(for: SubDirectories.baseDir)
    }
    
    //MARK: - MAIN METHODS
    
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
        
        if let type = type,
           let folderName = type.folderName {
            return baseDirectory.appendingPathComponent(folderName, isDirectory: true)
        } else {
            return baseDirectory
        }
    }
    
    func save(_ data: Data, type: SubDirectories, fileName: String, overwrite: Bool = true) throws { //TODO: - FIX THREADS
        self.createVxHubDirectoryIfNeeded(for: type)
        let folderURL = self.vxHubDirectoryURL(for: type)
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        if overwrite, FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        try data.write(to: fileURL)
    }
    
    //MARK: - IMAGE HELPERS
    
    public func pathForImage(named imageName: String) -> URL {
        var imageURL = vxHubDirectoryURL(for: .imagesDir).appendingPathComponent(imageName)
        if !imageURL.absoluteString.contains("file://") {
            imageURL = URL(fileURLWithPath: imageURL.path)
        }
        return imageURL
    }
    
    public func saveImage(_ image: UIImage, named imageName: String) -> Bool {
        let imageURL = pathForImage(named: imageName)
        
        guard let imageData = image.pngData() else {
            debugPrint("Error: Could not convert image to PNG data")
            return false
        }
        
        do {
            try imageData.write(to: imageURL)
            return true
        } catch {
            debugPrint("Error saving image to path: \(error)")
            return false
        }
    }
    
    public func keyForImage(_ imageUrlString: String?) -> String? {
        guard let imageUrlString = imageUrlString else { return nil }
        guard let imageUrl = URL(string: imageUrlString) else { return nil }
        let urlKey = imageUrl.path.dropFirst()
        let components = urlKey.split(separator: "/")
        let fileName = components.suffix(3).joined(separator: "-")
        return String(fileName)
    }
    
    public func getUiImage(named imageName: String) -> UIImage? {
        let imageURL = pathForImage(named: imageName)
        
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            VxLogger.shared.error("Image not found at path: \(imageURL.path)")
            return nil
        }
        if let image = UIImage(contentsOfFile: imageURL.path) {
            return image
        } else {
            VxLogger.shared.error("Error: Could not load image data at path: \(imageURL.path)")
            return nil
        }
    }
    
    public func getImage(named imageName: String) -> Image? {
        let imageURL = pathForImage(named: imageName)
        
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            VxLogger.shared.error("Image not found at path): \(imageURL.path)")
            return nil
        }
        
        guard let image =  UIImage(contentsOfFile: imageURL.path) else {
            VxLogger.shared.error("Image not converted: \(imageURL.path)")
            return nil
        }
        
        return Image(uiImage:image)
    }
        
    public func imageExists(named imageName: String) -> Bool {
        let imageURL = pathForImage(named: imageName)
        return FileManager.default.fileExists(atPath: imageURL.path)
    }
}

