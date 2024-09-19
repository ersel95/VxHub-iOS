//
//  VxError.swift
//  VxHub
//
//  Created by Mr. t. on 18.09.2024.
//

public class VxErrorModel: Error, @unchecked Sendable {
    private(set) public var error: String
    private(set) public var message: String
    private(set) public var statusCode: Int?

    convenience public init() {
        self.init(error: "Error!", message: "Oops! Something went wrong!\nHelp us improve your experience by sending an error report.")
    }

    convenience public init(message: String, code: Int? = nil) {
        self.init(error: "Error!", message: message, statusCode: code)
    }

    public init(error: String, message: String, statusCode: Int? = nil) {
        self.message = message
        self.error = error
        self.statusCode = statusCode
    }
}

enum ErrorTypeKeys: String, CodingKey {
    case `init`

}
