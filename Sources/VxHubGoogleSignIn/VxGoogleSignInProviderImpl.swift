#if canImport(UIKit)
//
//  VxGoogleSignInProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import UIKit
import VxHubCore
import GoogleSignIn

public final class VxGoogleSignInProviderImpl: VxGoogleSignInProvider, @unchecked Sendable {

    public init() {}

    // MARK: - VxGoogleSignInProvider

    public func signIn(
        clientID: String,
        presenting viewController: UIViewController,
        completion: @escaping @Sendable (_ userID: String?, _ idToken: String?, _ name: String?, _ email: String?, _ error: Error?) -> Void
    ) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(nil, nil, nil, nil, error)
                return
            }

            guard let user = result?.user else {
                completion(nil, nil, nil, nil, NSError(
                    domain: "VxGoogleSignInProvider",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to get Google user"]
                ))
                return
            }

            let userID = user.userID
            let idToken = user.idToken?.tokenString
            let name = user.profile?.name
            let email = user.profile?.email

            completion(userID, idToken, name, email, nil)
        }
    }
}
#endif
