import Foundation

typealias UserCertificate = (data: Data, password: String)

class URLSesionClientCertificateHandling: NSObject, URLSessionDelegate, @unchecked Sendable {
    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard let credential = Credentials.urlCredential(for: Bundle.module.userCertificateForWebsite) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        challenge.sender?.use(credential, for: challenge)
        completionHandler(.useCredential, credential)
    }
}
