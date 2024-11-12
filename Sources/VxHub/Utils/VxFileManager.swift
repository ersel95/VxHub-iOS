//
//  File.swift
//  VxHub
//
//  Created by furkan on 12.11.2024.
//

import Foundation
import UIKit

public final class VxFileManager: @unchecked Sendable {
    
    private let vxHubDirectoryName = "VxHub"
    public static let shared = VxFileManager()
    
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
            print("Error: Could not convert image to PNG data")
            return false
        }
        
        do {
            try imageData.write(to: imageURL)
            return true
        } catch {
            print("Error saving image to path: \(error)")
            return false
        }
    }
        
    public func imageExists(named imageName: String) -> Bool {
        let imageURL = pathForImage(named: imageName)
        return FileManager.default.fileExists(atPath: imageURL.path)
    }
}

