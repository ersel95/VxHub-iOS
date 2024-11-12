//
//  File.swift
//  VxHub
//
//  Created by furkan on 12.11.2024.
//

import Foundation
import UIKit
import SwiftUICore

public final class VxFileManager: @unchecked Sendable {
    
    private let vxHubDirectoryName = "VxHub"
    public static let shared = VxFileManager()
    let fileManagerThread = DispatchQueue(label: "vxHub.fileManagerUtilityThread")
    
    private init() {
        createVxHubDirectoryIfNeeded()
    }
    
    private func createVxHubDirectoryIfNeeded() {
        let vxHubURL = vxHubDirectoryURL()
        
        if !FileManager.default.fileExists(atPath: vxHubURL.path) {
            do {
                try FileManager.default.createDirectory(at: vxHubURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating VxHub directory: \(error)")
            }
        }
    }
    
    private func vxHubDirectoryURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(vxHubDirectoryName, isDirectory: true)
    }
    
    public func pathForImage(named imageName: String) -> URL {
        var imageURL = vxHubDirectoryURL().appendingPathComponent(imageName)
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
    
    public func getImage(named imageName: String) -> UIImage? {
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
            VxLogger.shared.error("Image not found at path: \(imageURL.path)")
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

