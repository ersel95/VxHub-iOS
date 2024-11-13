//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
import UIKit

@MainActor
internal final class VxDownloader {
    
    public static let shared = VxDownloader()
    private init() {}
    
    /// Downloads the `GoogleService-Info.plist` file from the specified URL string
    /// and saves it to the `VxHubThirdPartyResources` folder in the app's documents directory.
    /// Calls completion with the file URL if successful, otherwise an error.
    internal func downloadGoogleServiceInfoPlist(from urlString: String?, completion: @escaping @Sendable (URL?, Error?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil, URLError(.badURL))
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent("VxHubThirdPartyResources")
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completion(nil, error)
                return
            }
        }
        
        let destination = folderURL.appendingPathComponent("GoogleService-Info.plist")
        
        download(from: url) { [weak self] data, error in
            guard let self else { return }
            if let error = error {
                VxLogger.shared.warning("Downloading google-plist failed with error: \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                VxLogger.shared.warning("Downloaded google-plist data is empty")
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                
                try data.write(to: destination)
                completion(destination, nil)
            } catch {
                VxLogger.shared.warning("Could not save google-plist to \(destination.absoluteString)")
                completion(nil, error)
            }
        }
    }
    
    internal func downloadLocalAssets(from urlStrings: [String]?, completion: @escaping @Sendable (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        guard let urlStrings else {
            completion(URLError(.badURL))
            return
        }
        
        for urlString in urlStrings {
            guard let url = URL(string: urlString) else {
                continue
            }
            
            guard let fileName = VxFileManager.shared.keyForImage(urlString) else {
                continue
            }
            
            if VxFileManager.shared.imageExists(named: String(fileName)) {
                continue
            }
            
            dispatchGroup.enter()
            download(from: url) { [weak self] data, error in
                guard let self else { return }
                if let error = error {
                    VxLogger.shared.warning("Failed to download asset with error: \(error)")
                    dispatchGroup.leave()
                    completion(error)
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    VxLogger.shared.warning("Downloaded asset data is empty or invalid")
                    dispatchGroup.leave()
                    completion(URLError(.badServerResponse))
                    return
                }
                
                if VxFileManager.shared.saveImage(image, named: String(fileName)) {
                    VxLogger.shared.info("Asset saved successfully: \(fileName)")
                } else {
                    VxLogger.shared.warning("Failed to save asset: \(fileName)")
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            completion(nil)
        }
    }


    /// Downloads localization data and parses it to user defaults.
    internal func downloadLocalizables(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(URLError(.badURL))
            return
        }
        
        download(from: url) { data, error in
            if let error = error {
                VxLogger.shared.warning("Downloading localizes failed withe error: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(URLError(.badServerResponse))
                VxLogger.shared.warning("Downloaded localized are empty")
                return
            }
            
            Task { @MainActor in
                VxLocalizer.shared.parseToUserDefaults(data)
                completion(nil)
            }
        }
    }

    /// General download method that fetches data from a URL.
    private func download(from url: URL, completion: @escaping @Sendable (Data?, Error?) -> Void) {
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    completion(nil, error)
                    return
                }
            }
            
            guard let tempLocalUrl = tempLocalUrl else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    completion(nil, URLError(.badServerResponse))
                    return
                }
            }
            
            do {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let data = try Data(contentsOf: tempLocalUrl)
                    completion(data, nil)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
}


