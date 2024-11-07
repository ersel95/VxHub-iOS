//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation

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
        
        download(from: url) { data, error in
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
                completion(nil, error)
                return
            }
            
            guard let tempLocalUrl = tempLocalUrl else {
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            do {
                let data = try Data(contentsOf: tempLocalUrl)
                completion(data, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}


