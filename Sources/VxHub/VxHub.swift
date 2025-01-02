// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import RevenueCat
import AppTrackingTransparency
import SwiftUICore
import FacebookCore

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
    public private(set) var remoteConfig = [String: Any]()
    
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
    
    public func initialize(
        config: VxHubConfig,
        delegate: VxHubDelegate?,
        sceneOptions: UIScene.ConnectionOptions?) {
            self.config = config
            self.delegate = delegate
            self.configureHub(application: nil)
        }
    
    public weak var delegate: VxHubDelegate?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    public let id = "58412347912"
    public let dispatchGroup = DispatchGroup()
    private var isFirstLaunch: Bool = true
    
    public private(set) var revenueCatProducts : [VxStoreProduct] = []
    
    public func getVariantPayload(for key: String) -> [String: Any]? {
        return VxAmplitudeManager.shared.getPayload(for: key)
    }
    
    internal var getAppsflyerUUID :  String {
        return VxAppsFlyerManager.shared.appsflyerUID
    }
    
    internal var deviceId: String {
        return VxKeychainManager.shared.UDID
    }
    
    internal var getOneSignalPlayerId: String {
        return VxOneSignalManager.shared.playerId ?? ""
    }
    
    internal var getOneSignalPlayerToken: String {
        return VxOneSignalManager.shared.playerToken ?? ""
    }
    
    public func getIDFA() -> String? {
        let manager = VxPermissionManager()
        return manager.getIDFA()
    }
    
    public func getUDID(completion: @Sendable @escaping(String) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            completion(VxKeychainManager.shared.UDID)
        }
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
                guard self != nil else { return }
                completion?(success)
            }
        }
    }
    
    public func restorePurchases(completion: (@Sendable (Bool) -> Void)? = nil) {
        VxRevenueCat.shared.restorePurchases() { success in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                completion?(success)
            }
        }
    }
    
    public func showEula(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let urlString = self.deviceInfo?.appConfig?.eulaUrl else { return }
            guard let topVc = UIApplication.shared.topViewController() else { return }
            guard let url = URL(string: urlString) else { return }
            if topVc.isModal {
                topVc.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard self != nil else { return }
                        VxWebViewer.shared.present(url: url,
                                                   isFullscreen: isFullScreen,
                                                   showCloseButton: showCloseButton)
                    }
                }
            }else{
                VxWebViewer.shared.present(url: url,
                                           isFullscreen: isFullScreen,
                                           showCloseButton: showCloseButton)
            }
        }
    }
    
    public func showPrivacy(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let urlString = self.deviceInfo?.appConfig?.privacyUrl else { return }
            guard let topVc = UIApplication.shared.topViewController() else { return }
            guard let url = URL(string: urlString) else { return }
            if topVc.isModal {
                topVc.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard self != nil else { return }
                        VxWebViewer.shared.present(url: url,
                                                   isFullscreen: isFullScreen,
                                                   showCloseButton: showCloseButton)
                    }
                }
            }else{
                VxWebViewer.shared.present(url: url,
                                           isFullscreen: isFullScreen,
                                           showCloseButton: showCloseButton)
            }
        }
    }
    
    public func changePreferredLanguage(to languageCode: String, completion: @Sendable @escaping(Bool) -> Void) {
        guard let supportedLanguages = self.deviceInfo?.appConfig?.supportedLanguages else { return }
        guard supportedLanguages.contains(languageCode) else { return }
        
        UserDefaults.removeDownloadedUrl(self.deviceInfo?.appConfig?.localizationUrl ?? "")
        UserDefaults.VxHub_prefferedLanguage = languageCode
        let networkManager = VxNetworkManager()
        networkManager.registerDevice { response, remoteConfig, error in
            if error != nil {
                VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                completion(false)
                return
            }
            
            self.deviceInfo = VxDeviceInfo(vid: response?.vid,
                                           deviceProfile: response?.device,
                                           appConfig: response?.config,
                                           thirdPartyInfos: response?.thirdParty)
            
            self.remoteConfig = remoteConfig ?? [:]
            
            VxDownloader.shared.downloadLocalizables(from: response?.config?.localizationUrl) { error  in
                self.config?.responseQueue.async { [weak self] in
                    guard self != nil else {
                        completion(false)
                        return }
                    completion(true)
                }
            }
        }
    }
    
    public func requestAttPerm() {
        self.requestAtt()
    }
    
    public func isDownloaded(url: URL) -> Bool {
        return UserDefaults.VxHub_downloadedUrls.contains(url.absoluteString)
    }
    
    //MARK: - Video helpers
    public func downloadVideo(from url: String, completion: @escaping @Sendable (Error?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            VxDownloader.shared.downloadVideo(from: url) { error in
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    completion(error)
                }
            }
        }
    }
    
    public func getDownloadedVideoPath(from url: String) -> URL? {
        guard let urlString = URL(string: url) else { return nil }
        let urlKey = urlString.lastPathComponent
        return VxFileManager.shared.pathForVideo(named: urlKey)
    }
    
    //MARK: - Image helpers
    public func vxSetImage(
        on imageView: UIImageView,
        with url: URL?,
        activityIndicatorTintColor: UIColor = .gray,
        placeholderImage: UIImage? = nil,
        showLoadingIndicator: Bool = true,
        indicatorSize: Int = 4, // Default to medium
        completion: (@Sendable (UIImage?, Error?) -> Void)? = nil
    ) {
        let manager = VxImageManager()
        manager.setImage(
            on: imageView,
            with: url,
            activityIndicatorTintColor: activityIndicatorTintColor,
            placeholderImage: placeholderImage,
            showLoadingIndicator: showLoadingIndicator,
            indicatorSize: indicatorSize,
            completion: completion
        )
    }
    
    public func downloadImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (Error?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            VxDownloader.shared.downloadImage(from: url, isLocalized: isLocalized) { error in
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    completion(error)
                }
            }
        }
    }
    
    public func downloadImages(from urls: [String], isLocalized: Bool = false, completion: @escaping @Sendable ([String]) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let downloadGroup = DispatchGroup()
            var downloadedUrls = Array(repeating: "", count: urls.count)
            let lock = NSLock()
            
            for (index, url) in urls.enumerated() {
                downloadGroup.enter()
                VxDownloader.shared.downloadImage(from: url,isLocalized: isLocalized) { error in
                    DispatchQueue.main.async { [weak self] in
                        guard self != nil else { return }
                        if let error = error {
                            VxLogger.shared.error("Image download failed with error: \(error)")
                        } else {
                            lock.lock()
                            downloadedUrls[index] = url
                            lock.unlock()
                        }
                        downloadGroup.leave()
                    }
                }
            }
            
            downloadGroup.notify(queue: .main) {
                completion(downloadedUrls.filter { !$0.isEmpty })
            }
        }
    }
    
    public func getDownloadedImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            VxFileManager.shared.getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    public func getDownloadedImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (Image?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            VxFileManager.shared.getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    public func getImages(from urls: [String], isLocalized: Bool = false, completion: @escaping @Sendable ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var images = [UIImage]()
            let group = DispatchGroup()
            
            for url in urls {
                guard let url = URL(string: url) else { continue }
                group.enter()
                VxFileManager.shared.getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            images.append(image)
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(images)
            }
        }
    }
    
    public func getImages(from urls: [String], isLocalized: Bool, completion: @escaping @Sendable ([Image]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var images = [Image]()
            let group = DispatchGroup()
            
            for url in urls {
                guard let url = URL(string: url) else { continue }
                group.enter()
                VxFileManager.shared.getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            images.append(image)
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(images)
            }
        }
    }
    
    public func openFbUrlIfNeeded(url:URL) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            VxFacebookManager.shared.openFacebookUrl(url, application: UIApplication.shared)
        }
    }
}

private extension VxHub {
    
    private func configureHub(application: UIApplication? = nil, scene: UIScene? = nil) { // { Cold Start } Only for didFinishLaunchingWithOptions
        self.setDeviceConfig { [weak self] in
            guard let self else { return }
            VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)
            if let application {
                VxFacebookManager.shared.setupFacebook(
                    application: application,
                    didFinishLaunching: launchOptions)
            }
            let networkManager = VxNetworkManager()
            networkManager.registerDevice { response, remoteConfig, error in
                if error != nil {
                    VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                    self.delegate?.vxHubDidFailWithError?(error: error)
                    return
                }
                
                self.deviceInfo = VxDeviceInfo(vid: response?.vid,
                                               deviceProfile: response?.device,
                                               appConfig: response?.config,
                                               thirdPartyInfos: response?.thirdParty)
                
                self.remoteConfig = remoteConfig ?? [:]
                
                if response?.device?.banStatus == true {
                    self.delegate?.vxHubDidReceiveBanned?() //TODO: - Need to return?
                }
                
                if response?.config?.forceUpdate == true {
                    self.delegate?.vxHubDidReceiveBanned?() //TODO: - Need to return?
                }
                
                self.setFirstLaunch(from: response)
                VxAppsFlyerManager.shared.start()
                self.downloadExternalAssets(from: response)
            }
        }
    }
    
    
    private func setFirstLaunch(from response: DeviceRegisterResponse?) {
        guard self.isFirstLaunch == true else { return }
        
        if let appsFlyerDevKey = response?.thirdParty?.appsflyerDevKey,
           let appsFlyerAppId = response?.thirdParty?.appsflyerAppId {
            VxAppsFlyerManager.shared.initialize(
                appsFlyerDevKey: appsFlyerDevKey,
                appleAppID: appsFlyerAppId,
                delegate: self,
                customerUserID: VxDeviceConfig.shared.UDID,
                currentDeviceLanguage:  VxDeviceConfig.shared.deviceLang)
        }
        
        if let fbAppId = response?.thirdParty?.facebookAppId,
           let fcClientToken = response?.thirdParty?.facebookClientToken {
            var appName: String?
            if let appNameResponse = response?.thirdParty?.facebookApplicationName {
                appName = appNameResponse
            }else {
                appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            }
            VxFacebookManager.shared.initFbSdk(appId: fbAppId, clientToken: fcClientToken, appName: appName)
        }
        
        
        if let oneSignalAppId = response?.thirdParty?.onesignalAppId {
            VxOneSignalManager.shared.initialize(appId: oneSignalAppId, launchOptions: self.launchOptions)
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxOneSignalManager.shared.playerId ?? ""
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxOneSignalManager.shared.playerToken ?? ""
        }
        
        if let amplitudeKey = response?.thirdParty?.amplitudeApiKey {
            if self.config?.environment == .stage {
                var deploymentKey: String
                if let key = response?.thirdParty?.amplitudeDeploymentKey {
                    deploymentKey = key
                }else{
                    deploymentKey = "client-JOPG0XEyO7eO7T9qb7l5Zu0Ejdr6d1ED" //TODO: - REMOVE WHEN BACKEND ADD (BLOX KEY)
                }
                VxAmplitudeManager.shared.initialize(
                    userId: VxDeviceConfig.shared.UDID,
                    apiKey: amplitudeKey,
                    deploymentKey: deploymentKey,
                    deviceId: VxDeviceConfig.shared.UDID,
                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
            }else {
                var deploymentKey: String
                if let key = response?.thirdParty?.amplitudeDeploymentKey {
                    deploymentKey = key
                }else{
                    deploymentKey = "client-j2lkyGAV6G0DtNJz8nZNa90WacxJZyVC" //TODO: - REMOVE WHEN BACKEND ADD (BLOX KEY)
                }
                VxAmplitudeManager.shared.initialize(
                    userId: VxDeviceConfig.shared.UDID,
                    apiKey: amplitudeKey,
                    deploymentKey: deploymentKey,
                    deviceId: VxDeviceConfig.shared.UDID,
                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
            }
        }
        
        if let revenueCatId = response?.thirdParty?.revenueCatId {
            Purchases.logLevel = .warn
            Purchases.configure(withAPIKey: revenueCatId, appUserID: VxDeviceConfig.shared.UDID)
            
            if let oneSignalId = VxOneSignalManager.shared.playerId {
                Purchases.shared.attribution.setOnesignalID(oneSignalId)
            }
            Purchases.shared.attribution.setAttributes(["$amplitudeDeviceId": VxDeviceConfig.shared.UDID])
            Purchases.shared.attribution.setAttributes(["$amplitudeUserId": "\(VxDeviceConfig.shared.UDID)"])
            
            Purchases.shared.attribution.setFBAnonymousID(VxFacebookManager.shared.facebookAnonymousId)
            
            Purchases.shared.attribution.setAppsflyerID(VxAppsFlyerManager.shared.appsflyerUID)
            Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, publicError in }
            
        }
    }
    
    private func downloadExternalAssets(from response: DeviceRegisterResponse?) {

        dispatchGroup.enter()
        VxDownloader.shared.downloadLocalizables(from: response?.config?.localizationUrl) { error  in
            defer { self.dispatchGroup.leave() }
            self.config?.responseQueue.async { [weak self] in
                guard self != nil else { return }
            }
        }
        
        if isFirstLaunch {
            dispatchGroup.enter()
            VxDownloader.shared.downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "") { url, error in
                defer {  self.dispatchGroup.leave() }
                self.config?.responseQueue.async { [weak self] in
                    guard self != nil else { return }
                    if let url {
                        VxFirebaseManager.shared.configure(path: url)
                        Purchases.shared.attribution.setFirebaseAppInstanceID(VxFirebaseManager.shared.appInstanceId)
                    }
                }
            }
        }
        
        dispatchGroup.enter()
        VxRevenueCat.shared.requestRevenueCatProducts { products in
            self.config?.responseQueue.async { [weak self] in
                var vxProducts = [VxStoreProduct]()
                let discountGroup = DispatchGroup()
                
                for product in products {
                    discountGroup.enter()
                    Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product) { isEligible in
                        let product = VxStoreProduct(
                            storeProduct: product,
                            isDiscountOrTrialEligible: isEligible.isEligible)
                        vxProducts.append(product)
                        discountGroup.leave()
                    }
                }
                
                discountGroup.notify(queue: self?.config?.responseQueue ?? .main) {
                    self?.revenueCatProducts = vxProducts
                    self?.dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: self.config?.responseQueue ?? .main) {
            if self.isFirstLaunch {
                self.isFirstLaunch = false
                VxLogger.shared.success("Initialized successfully")
            }else{
                VxLogger.shared.success("Started successfully")
            }
            self.delegate?.vxHubDidInitialize?()
        }
        
    }
    
    func startHub(completion: (@Sendable () -> Void)? = nil) {  // { Warm Start } Only for applicationDidBecomeActive
        guard isFirstLaunch == false else {
            completion?()
            return }
        let networkManager = VxNetworkManager()
        networkManager.registerDevice { response, remoteConfig, error in
            if error != nil {
                self.delegate?.vxHubDidFailWithError?(error: error)
                completion?()
            }
            completion?()
            self.downloadExternalAssets(from: response)
            VxAppsFlyerManager.shared.start()
        }
    }
    
    private func requestAtt() {
        let manager = VxPermissionManager()
        manager.requestAttPermission { state in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
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
    
    private func setDeviceConfig(completion: @escaping @Sendable() -> Void) {
        DispatchQueue.main.async(flags: .barrier) { [weak self] in
            guard self != nil else { return }
            VxDeviceConfig.shared.initializeConfig(
                carrier_region: "",
                os: UIDevice.current.systemVersion,
                battery: UIDevice.current.batteryLevel * 100,
                deviceOsVersion: UIDevice.current.systemVersion,
                deviceName: UIDevice.current.name.removingWhitespaces(),
                UDID: VxKeychainManager.shared.UDID,
                deviceModel: UIDevice.VxModelName.removingWhitespaces(),
                resolution: UIScreen.main.resolution,
                appleId: UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""),
                idfaStatus: VxPermissionManager().getIDFA() ?? ""
            )
                completion()
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
