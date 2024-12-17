//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
import UIKit

internal final class VxDownloader : @unchecked Sendable {
    
    public static let shared = VxDownloader()
    private init() {}
    
    /// Downloads data from a URL and handles it generically using a custom processing block.
    /// - Parameters:
    ///   - urlString: The URL string to download from.
    ///   - destinationName: Optional name for the file when saving to disk.
    ///   - process: A closure to handle the downloaded data (e.g., save to disk, parse, etc.).
    ///   - completion: A closure called with an optional URL (for saved files) or error.
    public func download<T>(
        from urlString: String?,
        process: @escaping @Sendable (Data) throws -> T,
        completion: @escaping @Sendable (T?, Error?) -> Void
    ) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil, URLError(.badURL))
            return
        }
        
        download(from: url) { data, error, success in
            if let error = error {
                VxLogger.shared.warning("Download failed for URL \(url) with error: \(error)")
                completion(nil, error)
                return
            }
            
//            guard let data = data else {
//                VxLogger.shared.warning("Downloaded data is empty for URL: \(url)")
//                debugPrint("Downloaded data is empty for URL: \(url)")
//                completion(nil, URLError(.badServerResponse))
//                return
//            }
            
            do {
                if let data = data,
                   success == true {
                    let result = try process(data)
                    completion(result, nil)
                }else{
                    completion(.none, nil)
                }
            } catch {
                VxLogger.shared.warning("Processing failed for data from URL \(url): \(error)")
                completion(nil, error)
            }
        }
    }
    
    internal func downloadImage(from urlString: String?, isLocalized: Bool = false, completion: @escaping @Sendable (Error?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        download(from: urlString) { data in
            var fileName: String
            if isLocalized {
               fileName = VxFileManager.shared.localizedKeyForImage(urlString) ?? url.lastPathComponent
            }else{
               fileName = url.lastPathComponent
            }
            VxFileManager.shared.save(data, type: .imagesDir, fileName: fileName, overwrite: true) { _ in }
        } completion: { result, error in
            if let error {
                completion(error)
                return
            }
            
            UserDefaults.appendDownloadedUrl(url.absoluteString)
            completion(nil)
        }
    }
    
    /// Downloads the `GoogleService-Info.plist` and saves it to the specified folder.
    internal func downloadGoogleServiceInfoPlist(from urlString: String?, completion: @escaping @Sendable (URL?, Error?) -> Void) {
        let fileName = "GoogleService-Info.plist"
        
        download(from: urlString) { data in
            VxFileManager.shared.save(data, type: .thirdPartyDir, fileName: fileName, overwrite: true) { _ in }
            let savedFileURL = VxFileManager.shared.vxHubDirectoryURL(for: .thirdPartyDir).appendingPathComponent(fileName)
            return savedFileURL
        } completion: { result, error in
            guard let url = URL(string: urlString ?? "") else {
                completion(result, error)
                return }
            UserDefaults.appendDownloadedUrl(url.absoluteString)
            completion(result, error)
        }
    }
    
    /// Downloads localization data and parses it to user defaults.
    internal func downloadLocalizables(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
        download(from: urlString) { data in
            debugPrint("Downloaded localizables from \(urlString)")
            VxLocalizer.shared.parseToUserDefaults(data)
        } completion: { _, error in
            guard let url = URL(string: urlString ?? "") else {
                completion(nil)
                debugPrint("Could not download localizables from \(urlString)")
                return }
            UserDefaults.appendDownloadedUrl(url.absoluteString)
            completion(error)
        }
    }
    
    /// General download method that fetches data from a URL.
    private func download(from url: URL, completion: @escaping @Sendable (Data?, Error?, Bool?) -> Void) {
        guard !UserDefaults.VxHub_downloadedUrls.contains(url.absoluteString) else {
            completion(nil, nil,true)
            return
        }

        VxLogger.shared.log("Downloading \(url)", level: .info)
        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(nil, error, false) }
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                DispatchQueue.main.async { completion(nil, URLError(.badServerResponse), false) }
                return
            }

            do {
                let data = try Data(contentsOf: tempLocalUrl)
                DispatchQueue.main.async { completion(data, nil, true) }
            } catch {
                DispatchQueue.main.async { completion(nil, error, false) }
            }
        }

        task.resume()
    }
}


