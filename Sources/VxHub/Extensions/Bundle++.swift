//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 7.01.2025.
//

import UIKit

extension Bundle {
    var userCertificateForWebsite: UserCertificate? {
        guard let path = Bundle.module.path(forResource: "vx_mtls_certificate", ofType: "p12"),
              let p12Data = try? Data(contentsOf: URL(fileURLWithPath: path))
        else {
            return nil
        }
        let config = VxBuildConfigs()
        let mtls = config.value(for: .mtls)
        if let mtls {
            return (p12Data, mtls)
        }else{
            return (p12Data, "")
        }
    }
}
