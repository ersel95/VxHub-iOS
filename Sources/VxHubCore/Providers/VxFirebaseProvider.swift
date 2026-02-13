import Foundation

public protocol VxFirebaseProvider: Sendable {
    func configure(path: URL)
    var appInstanceId: String { get }
}
