// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import RevenueCat
import AppTrackingTransparency
import SwiftUICore

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

@objc public protocol VxHubDelegate: AnyObject {
    // Core methods (required)
    @objc optional func vxHubDidInitialize()
    @objc optional func vxHubDidStart()
    @objc optional func vxHubDidFailWithError(error: String?)
    
    // Optional SDK-specific methods
    @objc optional func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])
    @objc optional func onConversionDataFail(_ error: Error)
    @objc optional func oneSignalDidReceiveNotification(_ info: [String: Any])
    @objc optional func vxHubDidReceiveForceUpdate()
    @objc optional func vxHubDidReceiveBanned()
    
    @objc optional func onPurchaseComplete(didSucceed: Bool, error: String?)
    @objc optional func onRestorePurchases(didSucceed: Bool, error: String?)
    @objc optional func onFetchProducts(products: [StoreProduct]?, error: String?)
}


final public class VxHub : @unchecked Sendable{
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
    private var isFirstLaunch: Bool = true
    
    public private(set) var revenueCatProducts : [StoreProduct] = []
    
    public var localResourcePaths : [String] {
        guard let assets = self.deviceInfo?.remoteConfig?.bloxOnboardingAssetUrls else {
            return []
        }
        let cleanedString = assets
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\"", with: "")
        let bloxAssetsArray = cleanedString.components(separatedBy: ", ")
        let mappedAssets = bloxAssetsArray.map({VxFileManager.shared.keyForImage($0) ?? ""})
        let sortedAssets = mappedAssets.sorted { (file1, file2) -> Bool in
               let number1 = Int(file1.split(separator: "_")[1].prefix(while: { $0.isNumber })) ?? 0
               let number2 = Int(file2.split(separator: "_")[1].prefix(while: { $0.isNumber })) ?? 0
               return number1 < number2
        }
        return sortedAssets
    }
    
    public var bloxValidUrl : String { // TODO: - Make it generic move it to app
        return self.deviceInfo?.remoteConfig?.bloxSetupUrl ?? ""
    }
    
    public func getImageAtIndex(index: Int) -> Image? { // TODO: - Make it generic move it to app
        guard localResourcePaths.isEmpty == false else { return nil }
        return VxFileManager.shared.getImage(named: self.localResourcePaths[index])
    }
    
    public func getAllImages(completion: @escaping([Image]) -> Void) { // TODO: - Make it generic move it to app
        completion(localResourcePaths.compactMap { VxFileManager.shared.getImage(named: $0) })
    }
    
    public func getVariantPayload(for key: String) {
        VxAmplitudeManager.shared.getPayload(for: key)
    }
    
    public nonisolated var preferredLanguage: String? {
        return UserDefaults.VxHub_prefferedLanguage ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    public func start() {
        self.startHub()
    }
    
    public var supportedLanguages : [String] {
        return self.deviceInfo?.appConfig?.supportedLanguages ?? []
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
    
    public func purchase(_ productToBuy: StoreProduct) {
        VxRevenueCat.shared.purchase(productToBuy)
    }
    
    public func restorePurchases() {
        VxRevenueCat.shared.restorePurchases()
    }
    
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
            
            VxNetworkManager.shared.registerDevice { response, error in
                Task { @MainActor in
                    
                    if error != nil {
                        VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                        self.delegate?.vxHubDidFailWithError?(error: error)
                        return
                    }
                    
                    self.deviceInfo = VxDeviceInfo(vid: response?.vid,
                                                   deviceProfile: response?.device,
                                                   appConfig: response?.config,
                                                   thirdPartyInfos: response?.thirdParty,
                                                   remoteConfig: response?.remoteConfig)
                    
                    if response?.device?.banStatus == true {
                        self.delegate?.vxHubDidReceiveBanned?() //TODO: - Need to return?
                    }
                    
                    if response?.config?.forceUpdate == true {
                        self.delegate?.vxHubDidReceiveBanned?() //TODO: - Need to return?
                    }
                    
                    if self.isFirstLaunch == true {
                        debugPrint("init 2")
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
                                deploymentKey: "client-JOPG0XEyO7eO7T9qb7l5Zu0Ejdr6d1ED", //TODO: - Replace with response deployment key
                                deviceId: VxDeviceConfig.UDID,
                                isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
                        }
#endif
                        
                        if let revenueCatId = response?.thirdParty?.revenueCatId {
                            Purchases.logLevel = .warn
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
                            
#if canImport(VxHub_Appsflyer)
                            Purchases.shared.attribution.setAppsflyerID(VxAppsFlyerManager.shared.appsflyerUID)
#endif
                            Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, publicError in }
                            
                            self.isFirstLaunch = false
                        }
                    }
                    
                    if self.config?.requestAtt ?? true {
                        self.requestAtt()
                    }
                    
#if canImport(VxHub_Appsflyer)
                    VxAppsFlyerManager.shared.start()
#endif
                    debugPrint("init 3")
                    self.downloadExternalAssets(from: response, isFirstLaunch: self.isFirstLaunch)

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
                    debugPrint("init 4")
                    dispatchGroup.leave()
                }
            }
            
            if let bloxAssets = response?.remoteConfig?.bloxOnboardingAssetUrls { //TODO: REMOVE ME HANDLE IN APP
                dispatchGroup.enter()
                let cleanedString = bloxAssets
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                let bloxAssetsArray = cleanedString.components(separatedBy: ", ")
                VxDownloader.shared.downloadLocalAssets(from: bloxAssetsArray) { error in
                    self.config?.responseQueue.async { [weak self] in
                        guard let self else { return }
                        debugPrint("init 5")
                        dispatchGroup.leave()
                    }
                }
            }
            
            if isFirstLaunch {
#if canImport(VxHub_Firebase)
                dispatchGroup.enter()
                VxDownloader.shared.downloadGoogleServiceInfoPlist(from: response?.remoteConfig?.firebaseConfigUrl ?? "") { url, error in
                    self.config?.responseQueue.async { [weak self] in
                        if let url {
                            VxFirebaseManager.shared.configure(path: url)
                        }
                        debugPrint("init 6")
                        self?.dispatchGroup.leave()
                    }
                }
#endif
            }
            
            dispatchGroup.enter()
            VxRevenueCat.shared.requestRevenueCatProducts { products in
                self.config?.responseQueue.async { [weak self] in
                    self?.revenueCatProducts = products
                    self?.dispatchGroup.leave()
                    debugPrint("init 7")
                }
            }
            
            dispatchGroup.notify(queue: self.config?.responseQueue ?? .main) {
                debugPrint("Blox asets array",self.localResourcePaths)
                if isFirstLaunch {
                    VxLogger.shared.success("Initialized successfully")
                }else{
                    VxLogger.shared.success("Started successfully")
                }
                debugPrint("init 8")
                self.delegate?.vxHubDidInitialize?()
            }
        }
    }
    
    private func startHub() { // { Warm Start } Only for applicationDidBecomeActive
        guard isFirstLaunch == false else { return }
        VxNetworkManager.shared.registerDevice { response, error in
            Task { @MainActor in
                if error != nil {
                    self.delegate?.vxHubDidFailWithError?(error: error)
                }
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
        self.delegate?.onConversionDataSuccess?(info)
    }
    
    public func onConversionDataFail(_ error: any Error) {
        self.delegate?.onConversionDataFail?(error)
    }
}
#endif

extension VxHub: VxRevenueCatDelegate{
    func didPurchaseComplete(didSucceed: Bool, error: String?) {
        self.delegate?.onPurchaseComplete?(didSucceed: didSucceed, error: error)
    }
    
    func didRestorePurchases(didSucceed: Bool, error: String?) {
        self.delegate?.onRestorePurchases?(didSucceed: didSucceed, error: error)
    }
    
    func didFetchProducts(products: [RevenueCat.StoreProduct]?, error: String?) {
        self.delegate?.onFetchProducts?(products: products, error: error)
    }
    
    
}
