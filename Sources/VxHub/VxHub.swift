// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import RevenueCat
import AppTrackingTransparency
import SwiftUICore

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
    
    public weak var delegate: VxHubDelegate?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    public let id = "58412347912"
    public let dispatchGroup = DispatchGroup()
    private var isFirstLaunch: Bool = true
    
    public private(set) var revenueCatProducts : [StoreProduct] = []
    
    public var localResourcePaths: [String] {
        guard let assets = self.deviceInfo?.remoteConfig?.bloxOnboardingAssetUrls else {
            return []
        }

        // Convert to Data for JSON parsing
        guard let data = assets.data(using: .utf8) else {
            debugPrint("⚠️ Failed to convert bloxOnboardingAssetUrls to data.")
            return []
        }

        // Parse the JSON array
        guard let bloxAssetsArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String] else {
            debugPrint("⚠️ Failed to decode bloxOnboardingAssetUrls as an array.")
            return []
        }

        // Map each asset to its local key
        let mappedAssets = bloxAssetsArray.map { VxFileManager.shared.keyForImage($0) ?? "" }

        // Sort the mapped assets by the numeric value extracted from each file name
        let sortedAssets = mappedAssets.sorted { file1, file2 in
            let number1 = Int(file1.split(separator: "_")[1].prefix { $0.isNumber }) ?? 0
            let number2 = Int(file2.split(separator: "_")[1].prefix { $0.isNumber }) ?? 0
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
    
    public func onboardingTexts() -> String {
        return VxHub.shared.deviceInfo?.remoteConfig?.bloxSetupTexts ?? ""
    } //TODO: - MOVE TO BLOX
    
    public func getAllImages(completion: @escaping([Image]) -> Void) { // TODO: - Make it generic move it to app
        completion(localResourcePaths.compactMap { VxFileManager.shared.getImage(named: $0) })
    }

    public func getVariantPayload(for key: String) -> [String: Any]? {
        return VxAmplitudeManager.shared.getPayload(for: key)
    }
    
    public nonisolated var preferredLanguage: String? {
        return UserDefaults.VxHub_prefferedLanguage ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    public func start(completion: (@Sendable() -> Void)? = nil) {
        self.startHub(completion: completion)
    }
    
    public var supportedLanguages : [String] {
        return self.deviceInfo?.appConfig?.supportedLanguages ?? []
    }
    
    public func logAppsFlyerEvent(eventName: String, values: [String: Any]?) {
        VxAppsFlyerManager.shared.logAppsFlyerEvent(eventName: eventName, values: values)
    }
    
    public func logAmplitudeEvent(eventName: String, properties: [AnyHashable: Any]) {
        VxAmplitudeManager.shared.logEvent(eventName: eventName, properties: properties)
    }
    
    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool) -> Void)? = nil) {
        VxRevenueCat.shared.purchase(productToBuy) { success in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                completion?(success)
            }
        }
    }
    
    public func restorePurchases(completion: (@Sendable (Bool) -> Void)? = nil) {
        VxRevenueCat.shared.restorePurchases() { success in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                completion?(success)
            }
        }
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
//        Task { @MainActor in
                if VxFacebookManager.shared.canInitializeFacebook {
                    VxFacebookManager.shared.setupFacebook(
                        application: application,
                        didFinishLaunching: launchOptions)
                }
        
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
                        if let appsFlyerDevKey = response?.thirdParty?.appsflyerDevKey,
                           let appsFlyerAppId = response?.thirdParty?.appsflyerAppId {
                            VxAppsFlyerManager.shared.initialize(
                                appsFlyerDevKey: appsFlyerDevKey,
                                appleAppID: appsFlyerAppId,
                                delegate: self,
                                customerUserID: VxDeviceConfig.UDID,
                                currentDeviceLanguage:  VxDeviceConfig.deviceLang)
                        }
                        
                        if let oneSignalAppId = response?.thirdParty?.onesignalAppId {
                            VxOneSignalManager.shared.initialize(appId: oneSignalAppId, launchOptions: self.launchOptions)
                            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxOneSignalManager.shared.playerId ?? ""
                            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxOneSignalManager.shared.playerToken ?? ""
                        }
                        
                        if let amplitudeKey = response?.thirdParty?.amplitudeApiKey {
                            if self.config?.environment == .stage {
                                VxAmplitudeManager.shared.initialize(
                                    userId: VxDeviceConfig.UDID,
                                    apiKey: amplitudeKey,
                                    deploymentKey: "client-JOPG0XEyO7eO7T9qb7l5Zu0Ejdr6d1ED", //TODO: - Replace with response deployment key
                                    deviceId: VxDeviceConfig.UDID,
                                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
                            }else {
                                VxAmplitudeManager.shared.initialize(
                                    userId: VxDeviceConfig.UDID,
                                    apiKey: amplitudeKey,
                                    deploymentKey: "client-j2lkyGAV6G0DtNJz8nZNa90WacxJZyVC", //TODO: - Replace with response deployment key
                                    deviceId: VxDeviceConfig.UDID,
                                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
                            }
                        }
                        
                        if let revenueCatId = response?.thirdParty?.revenueCatId {
                            Purchases.logLevel = .warn
                            Purchases.configure(withAPIKey: revenueCatId, appUserID: VxDeviceConfig.UDID)
                            
                            if let oneSignalId = VxOneSignalManager.shared.playerId {
                                Purchases.shared.attribution.setOnesignalID(oneSignalId)
                            }
                            
                            Purchases.shared.attribution.setFirebaseAppInstanceID(VxFirebaseManager.shared.appInstanceId)
                            
                            Purchases.shared.attribution.setAttributes(["$amplitudeDeviceId": VxDeviceConfig.UDID])
                            Purchases.shared.attribution.setAttributes(["$amplitudeUserId": "\(VxDeviceConfig.UDID)"])
                            
                            Purchases.shared.attribution.setFBAnonymousID(VxFacebookManager.shared.facebookAnonymousId)
                            
                            Purchases.shared.attribution.setAppsflyerID(VxAppsFlyerManager.shared.appsflyerUID)
                            Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, publicError in }
                            
                        }
                    }
                    
                    VxAppsFlyerManager.shared.start()
                    self.downloadExternalAssets(from: response, isFirstLaunch: self.isFirstLaunch)

                }
            }
        }
//    }
    
    private func downloadExternalAssets(from response: DeviceRegisterResponse?, isFirstLaunch: Bool = false) {
        Task { @MainActor in
            dispatchGroup.enter()
            VxDownloader.shared.downloadLocalizables(from: response?.config?.localizationUrl) { error  in
                defer { self.dispatchGroup.leave() }
                self.config?.responseQueue.async { [weak self] in
                    guard self != nil else { return }
                }
            }
            
            if let bloxAssets = response?.remoteConfig?.bloxOnboardingAssetUrls {
                // Attempt to decode JSON array from the string
                if let data = bloxAssets.data(using: .utf8) {
                    do {
                        // Parse the JSON string as an array of strings
                        if let bloxAssetsArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                            dispatchGroup.enter()
                            VxDownloader.shared.downloadLocalAssets(from: bloxAssetsArray) { error in
                                defer { self.dispatchGroup.leave() }
                                self.config?.responseQueue.async { [weak self] in
                                    guard self != nil else { return }
                                }
                            }
                        } else {
                            debugPrint("⚠️ Failed to decode bloxOnboardingAssetUrls as an array.")
                        }
                    } catch {
                        debugPrint("⚠️ JSON decoding error: \(error.localizedDescription)")
                    }
                } else {
                    debugPrint("⚠️ Failed to convert bloxOnboardingAssetUrls string to data.")
                }
            }

            
            if isFirstLaunch {
#if canImport(VxHub_Firebase)
                dispatchGroup.enter()
                VxDownloader.shared.downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "") { url, error in
                    defer {  self.dispatchGroup.leave() }
                    self.config?.responseQueue.async { [weak self] in
                        if let url {
                            VxFirebaseManager.shared.configure(path: url)
                        }
                    }
                }
#endif
            }
            
            dispatchGroup.enter()
            VxRevenueCat.shared.requestRevenueCatProducts { products in
                defer { self.dispatchGroup.leave() }
                self.config?.responseQueue.async { [weak self] in
                    self?.revenueCatProducts = products
                }
            }
            
            dispatchGroup.notify(queue: self.config?.responseQueue ?? .main) {
                if isFirstLaunch {
                    self.isFirstLaunch = false
                    VxLogger.shared.success("Initialized successfully")
                }else{
                    VxLogger.shared.success("Started successfully")
                }
                self.delegate?.vxHubDidInitialize?()
            }
        }
    }
    
    func startHub(completion: (@Sendable () -> Void)? = nil) {  // { Warm Start } Only for applicationDidBecomeActive
        guard isFirstLaunch == false else {
            completion?()
            return }
        VxNetworkManager.shared.registerDevice { response, error in
            Task { @MainActor in
                if error != nil {
                    self.delegate?.vxHubDidFailWithError?(error: error)
                    completion?()
                }
                completion?()
                self.downloadExternalAssets(from: response, isFirstLaunch: false)
                VxAppsFlyerManager.shared.start()
            }
        }
    }
    
    private func requestAtt() {
        Task { @MainActor in
            VxPermissionManager.shared.requestAttPermission { state in
                VxFacebookManager.shared.fbAttFlag()
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


extension VxHub: VxAppsFlyerDelegate {
    public func onConversionDataSuccess(_ info: [AnyHashable : Any]) {
        self.delegate?.onConversionDataSuccess?(info)
    }
    
    public func onConversionDataFail(_ error: any Error) {
        self.delegate?.onConversionDataFail?(error)
    }
}


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
