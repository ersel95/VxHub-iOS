import Foundation

internal final class VxBuildConfigs: @unchecked Sendable {
    internal static let shared = VxBuildConfigs()
    
    internal var configDictionary: [String: Any]?
    
    init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if VxHub.shared.config?.environment == .stage {
            guard let path = Bundle.module.path(forResource: "VxInfo-STAGE", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
                return
            }
            configDictionary = dict
        }else{
            guard let path = Bundle.module.path(forResource: "VxInfo-PROD", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
                return
            }
            configDictionary = dict
        }
    }
    
    public func value(for config: VxBuildConfigKeys) -> String? {
        return configDictionary?[config.key] as? String
    }
} 


enum VxBuildConfigKeys {
    case api, mtls
    
    var key: String {
        switch self {
        case .api: return "API_BASE_URL"
        case .mtls: return "MTLS_PASS"
        }
    }
}

