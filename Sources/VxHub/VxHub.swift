// The Swift Programming Language
// https://docs.swift.org/swift-book

import os.log
import UIKit.UIViewController

public class VxHub {
    /// Shared singleton instance.
    private static let queue = DispatchQueue(label: "com.vxhub.queue")
    nonisolated(unsafe) private static var instance: VxHub?

    public static var shared: VxHub {
        return queue.sync {
            if let instance = instance {
                return instance
                
            } else {
                instance = VxHub()
                return instance!
            }
        }
    }
    
    private var apiKey: String? = nil
    private var logger: VxLogger? = nil
    
    private var delegate: InitDelegate?
    
    // Prevent  developers from creating their own instances by making the initializer `private`.
    private init() {}
}

// MARK: - Public developer APIs
public extension VxHub {
    /**
     This is our method to start application. Should be called before app starts..
     */
    func initialize(apiKey: String, logLevel: OSLogType? = .none, delegate: InitDelegate) {
        self.delegate = delegate
        self.apiKey = apiKey
        self.logger = VxLogger(level: logLevel)
        self.logger?.log(message: "Starting VxHubManager with API key: \(apiKey)")
        self.delegate?.inittedSuccess(VxDeviceData(name: "ersel", age: 29))
    }
}
