// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import RevenueCat
import AppTrackingTransparency

#if canImport(VxHub_OneSignal)
import VxHub_OneSignal
#endif

#if canImport(VxHub_Amplitude)
import VxHub_Amplitude
#endif

#if canImport(VxHub_Facebook)
import VxHub_Facebook
#endif

#if canImport(VxHub_Firebase)
import VxHub_Firebase
#endif

#if canImport(VxHub_Appsflyer)
import VxHub_Appsflyer
#endif

public protocol VxHubDelegate: AnyObject {
    // Core methods (required)
    func VxHubDidInitialize()
    func VxHubDidStart()
    func VxHubDidFailWithError(error: String?)
    
    // Optional SDK-specific methods
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])
    func onConversionDataFail(_ error: Error)
    func oneSignalDidReceiveNotification(_ info: [String: Any])
    func VxHubDidReceiveForceUpdate()
    func VxHubDidReceiveBanned()
}

public extension VxHubDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {}
    func onConversionDataFail(_ error: Error) {}
    func oneSignalDidReceiveNotification(_ info: [String: Any]) {}
    func VxHubDidReceiveForceUpdate() {}
    func VxHubDidReceiveBanned() {}
}

final public class VxHub : @unchecked Sendable {
    
    public static let shared = VxHub()
    
    public private(set) var config: VxHubConfig?
    public private(set) var deviceInfo: VxDeviceInfo?
    
    public func initialize(
        config: VxHubConfig,
        delegate: VxHubDelegate?,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        application: UIApplication) {

        self.config = config
        self.delegate = delegate
        self.launchOptions = launchOptions
        self.configureHub(application: application)
    }
    
    private weak var delegate: VxHubDelegate?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    public let id = "58412347912"
    public let dispatchGroup = DispatchGroup()
        
    public func start() {
        self.startHub()
    }
    
#if canImport(VxHub_Appsflyer)
    public func logAppsFlyerEvent(eventName: String, values: [String: Any]?) {
        VxAppsFlyerManager.shared.logAppsFlyerEvent(eventName: eventName, values: values)
    }
#endif
    
#if canImport(VxHub_Amplitude)
    public func logAmplitudeEvent(eventName: String, properties: [AnyHashable: Any]) {
        VxAmplitudeManager.shared.logEvent(eventName: eventName, properties: properties)
    }
#endif
    
    public func showEula(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        Task { @MainActor in
            guard let urlString = self.deviceInfo?.appConfig?.eulaUrl else { return }
            if let url = URL(string: urlString) {
                VxWebViewer.shared.present(url: url,
                                           isFullscreen: isFullScreen)
            }
        }
    }
    
    public func showPrivacy(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        Task { @MainActor in
            guard let urlString = self.deviceInfo?.appConfig?.privacyUrl else { return }
            if let url = URL(string: urlString) {
                VxWebViewer.shared.present(url: url,
                                           isFullscreen: isFullScreen,
                                           showCloseButton: showCloseButton)
            }
        }
    }
    
    public func changePreferredLanguage(to languageCode: String) {
        guard let supportedLanguages = self.deviceInfo?.appConfig?.supportedLanguages else { return }
        guard supportedLanguages.contains(languageCode) else { return }
        UserDefaults.VxHub_prefferedLanguage = languageCode
    }
}

private extension VxHub {
    
    private func configureHub(application: UIApplication) { // { Cold Start } Only for didFinishLaunchingWithOptions
        Task { @MainActor in
#if canImport(VxHub_Facebook)
                if VxFacebookManager.shared.canInitializeFacebook {
                    VxFacebookManager.shared.setupFacebook(
                        application: application,
                        didFinishLaunching: launchOptions)
                }
#endif
            
            if self.config?.requestAtt ?? true {
                self.requestAtt()
            }
            
            VxNetworkManager.shared.registerDevice { response, error in
                Task { @MainActor in
                    
                    if error != nil {
                        VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                        self.delegate?.VxHubDidFailWithError(error: error)
                        return
                    }
                    
                    self.deviceInfo = VxDeviceInfo(deviceProfile: response?.device,
                                                   appConfig: response?.config,
                                                   thirdPartyInfos: response?.thirdParty)
                    
                    if response?.device?.banStatus == true {
                        self.delegate?.VxHubDidReceiveBanned() //TODO: - Need to return?
                    }
                    
                    if response?.config?.forceUpdate == true {
                        self.delegate?.VxHubDidReceiveBanned() //TODO: - Need to return?
                    }
                    
#if canImport(VxHub_Appsflyer)
                    if let appsFlyerDevKey = response?.thirdParty?.appsflyerDevKey,
                       let appsFlyerAppId = response?.thirdParty?.appsflyerAppId {
                        VxAppsFlyerManager.shared.initialize(
                            appsFlyerDevKey: appsFlyerDevKey,
                            appleAppID: appsFlyerAppId,
                            delegate: self,
                            customerUserID: VxDeviceConfig.UDID,
                            currentDeviceLanguage:  VxDeviceConfig.deviceLang)
                    }
#endif
                    
#if canImport(VxHub_OneSignal)
                    if let oneSignalAppId = response?.thirdParty?.onesignalAppId {
                        VxOneSignalManager.shared.initialize(appId: oneSignalAppId, launchOptions: self.launchOptions)
                        self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxOneSignalManager.shared.playerId ?? ""
                        self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxOneSignalManager.shared.playerToken ?? ""
                    }
#endif
                    
#if canImport(VxHub_Amplitude)
                    if let amplitudeKey = response?.thirdParty?.amplitudeApiKey {
                        VxAmplitudeManager.shared.initialize(
                            userId: VxDeviceConfig.UDID,
                            apiKey: amplitudeKey,
                            deviceId: VxDeviceConfig.UDID)
                    }
#endif
                    
                    if let revenueCatId = response?.thirdParty?.revenueCatId {
                        Purchases.configure(withAPIKey: revenueCatId, appUserID: VxDeviceConfig.UDID)
                        
#if canImport(VxHub_OneSignal)
                        if let oneSignalId = VxOneSignalManager.shared.playerId {
                            Purchases.shared.attribution.setOnesignalID(oneSignalId)
                        }
#endif
                        
#if canImport(VxHub_Firebase)
                        Purchases.shared.attribution.setFirebaseAppInstanceID(VxFirebaseManager.shared.appInstanceId)
#endif
                        
#if canImport(VxHub_Amplitude)
                        Purchases.shared.attribution.setAttributes(["$amplitudeDeviceId": VxDeviceConfig.UDID])
                        Purchases.shared.attribution.setAttributes(["$amplitudeUserId": "\(VxDeviceConfig.UDID)"])
#endif
                        
#if canImport(VxHub_Facebook)
                        Purchases.shared.attribution.setFBAnonymousID(VxFacebookManager.shared.facebookAnonymousId)
#endif
                        Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, publicError in }
                        self.downloadExternalAssets(from: response, isFirstLaunch: true)
                    }
                }
            }
        }
    }
    
    private func downloadExternalAssets(from response: DeviceRegisterResponse?, isFirstLaunch: Bool = false) {
        Task { @MainActor in
            dispatchGroup.enter()
            VxDownloader.shared.downloadLocalizables(from: response?.config?.localizationUrl) { error  in
                self.config?.responseQueue.async { [weak self] in
                    guard let self else { return }
                    dispatchGroup.leave()
                }
            }
            
            if isFirstLaunch {
#if canImport(VxHub_Firebase)
                dispatchGroup.enter()
                VxDownloader.shared.downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "") { url, error in
                    self.config?.responseQueue.async { [weak self] in
                        if let url {
                            VxFirebaseManager.shared.configure(path: url)
                        }
                        self?.dispatchGroup.leave()
                    }
                }
#endif
            }
            
            dispatchGroup.notify(queue: .main) {
                if isFirstLaunch {
                    VxLogger.shared.success("Initialized successfully")
                }else{
                    VxLogger.shared.success("Started successfully")
                }
                self.delegate?.VxHubDidInitialize()
            }
        }
    }
    
    private func startHub() { // { Warm Start } Only for applicationDidBecomeActive
        VxNetworkManager.shared.registerDevice { response, error in
            Task { @MainActor in
                self.downloadExternalAssets(from: response, isFirstLaunch: false)
                #if canImport(VxHub_Appsflyer)
                        VxAppsFlyerManager.shared.start()
                #endif
            }
        }
    }
    
    private func requestAtt() {
        Task { @MainActor in
            VxPermissionManager.shared.requestAttPermission { state in
#if canImport(VxHub_Facebook)
                VxFacebookManager.shared.fbAttFlag()
#endif
                switch state {
                case .granted:
                    Purchases.shared.attribution.collectDeviceIdentifiers()
                default:
                    return
                }
            }
        }
    }
}

#if canImport(VxHub_Appsflyer)
extension VxHub: VxAppsFlyerDelegate {
    public func onConversionDataSuccess(_ info: [AnyHashable : Any]) {
        self.delegate?.onConversionDataSuccess(info)
    }
    
    public func onConversionDataFail(_ error: any Error) {
        self.delegate?.onConversionDataFail(error)
    }
}
#endif
