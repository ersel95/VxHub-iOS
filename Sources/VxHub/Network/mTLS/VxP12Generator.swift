//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 7.01.2025.
//

import Foundation
class Credentials {
    static func urlCredential(for userCertificate: UserCertificate?) -> URLCredential? {
        guard let userCertificate = userCertificate else { return nil }
        
        let p12Contents = VXPKCS12(pkcs12Data: userCertificate.data, password: userCertificate.password)
        
        guard let identity = p12Contents.identity else {
            return nil
        }
        
        return URLCredential(identity: identity, certificates: nil, persistence: .none)
    }
}

class VXPKCS12 {
    let label: String?
    let keyID: NSData?
    let trust: SecTrust?
    let certChain: [SecTrust]?
    let identity: SecIdentity?

    public init(pkcs12Data: Data, password: String) {
        let importPasswordOption: NSDictionary
        = [kSecImportExportPassphrase as NSString: password]
        var items: CFArray?
        let secError: OSStatus
        = SecPKCS12Import(pkcs12Data as NSData,
                          importPasswordOption, &items)
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                VxLogger.shared.error("PKCS12 import failed: Incorrect password")
            } else {
                VxLogger.shared.error("PKCS12 import failed with OSStatus: \(secError)")
            }
            label = nil; keyID = nil; trust = nil; certChain = nil; identity = nil
            return
        }
        guard let theItemsCFArray = items else {
            VxLogger.shared.error("PKCS12 import returned nil items")
            label = nil; keyID = nil; trust = nil; certChain = nil; identity = nil
            return
        }
        let theItemsNSArray: NSArray = theItemsCFArray as NSArray
        guard let dictArray
                = theItemsNSArray as? [[String: AnyObject]]
        else {
            VxLogger.shared.error("PKCS12 import items could not be cast to expected type")
            label = nil; keyID = nil; trust = nil; certChain = nil; identity = nil
            return
        }

        label = dictArray.element(for: kSecImportItemLabel)
        keyID = dictArray.element(for: kSecImportItemKeyID)
        trust = dictArray.element(for: kSecImportItemTrust)
        certChain = dictArray.element(for: kSecImportItemCertChain)
        identity = dictArray.element(for: kSecImportItemIdentity)
    }
}
