// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if os(iOS)
import AppTrackingTransparency
#endif
import SwiftUI
import StoreKit
import Combine
import AuthenticationServices
import CloudKit

public protocol VxHubDelegate: AnyObject {
    // Core methods (required)
    func vxHubDidInitialize()
    func vxHubDidStart()
    func vxHubDidFailWithError(error: String?)

    // Optional SDK-specific methods
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])
    func onConversionDataFail(_ error: Error)
    func oneSignalDidReceiveNotification(_ info: [String: Any])
    func vxHubDidReceiveForceUpdate()
    func vxHubDidReceiveBanned()

    func onPurchaseComplete(didSucceed: Bool, error: String?)
    func onRestorePurchases(didSucceed: Bool, error: String?)
    func onFetchProducts(products: [any VxPurchaseProduct]?, error: String?)
    func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String)
}

// Default implementations for optional methods
public extension VxHubDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {}
    func onConversionDataFail(_ error: Error) {}
    func oneSignalDidReceiveNotification(_ info: [String: Any]) {}
    func vxHubDidReceiveForceUpdate() {}
    func vxHubDidReceiveBanned() {}
    func onPurchaseComplete(didSucceed: Bool, error: String?) {}
    func onRestorePurchases(didSucceed: Bool, error: String?) {}
    func onFetchProducts(products: [any VxPurchaseProduct]?, error: String?) {}
    func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String) {}
}


public extension Notification.Name {
    static let vxHubStateDidChange = Notification.Name("vxHubStateDidChange")
}

final public class VxHub : NSObject, @unchecked Sendable{
    public static let shared = VxHub()

    // MARK: - Thread-safe state queue
    private let stateQueue = DispatchQueue(label: "com.vxhub.state", qos: .userInitiated)

    // MARK: - Thread-safe backing stores
    private var _config: VxHubConfig?
    private var _deviceInfo: VxDeviceInfo?
    private var _deviceConfig: VxDeviceConfig?
    private var _remoteConfig = [String: Any]()
    private var _isPremium: Bool = false
    private var _balance: Int = 0
    private var _isConnectedToInternet: Bool = false
    private var _currentConnectionType: String = VxConnection.unavailable.description
    private var _isFirstLaunch: Bool = true
    private var _revenueCatProducts: [VxStoreProduct] = []

    // MARK: - Thread-safe public properties
    public internal(set) var config: VxHubConfig? {
        get { stateQueue.sync { _config } }
        set { stateQueue.sync { _config = newValue } }
    }
    public internal(set) var deviceInfo: VxDeviceInfo? {
        get { stateQueue.sync { _deviceInfo } }
        set { stateQueue.sync { _deviceInfo = newValue } }
    }
    public internal(set) var deviceConfig: VxDeviceConfig? {
        get { stateQueue.sync { _deviceConfig } }
        set { stateQueue.sync { _deviceConfig = newValue } }
    }
    public internal(set) var remoteConfig: [String: Any] {
        get { stateQueue.sync { _remoteConfig } }
        set { stateQueue.sync { _remoteConfig = newValue } }
    }
    public var isPremium: Bool {
        get { stateQueue.sync { _isPremium } }
        set {
            stateQueue.sync { _isPremium = newValue }
            NotificationCenter.default.post(name: .vxHubStateDidChange, object: nil)
        }
    }
    public var balance: Int {
        get { stateQueue.sync { _balance } }
        set {
            stateQueue.sync { _balance = newValue }
            NotificationCenter.default.post(name: .vxHubStateDidChange, object: nil)
        }
    }
    public var isConnectedToInternet: Bool {
        get { stateQueue.sync { _isConnectedToInternet } }
        set {
            stateQueue.sync { _isConnectedToInternet = newValue }
            NotificationCenter.default.post(name: .vxHubStateDidChange, object: nil)
        }
    }
    public internal(set) var currentConnectionType: String {
        get { stateQueue.sync { _currentConnectionType } }
        set { stateQueue.sync { _currentConnectionType = newValue } }
    }
    private var isFirstLaunch: Bool {
        get { stateQueue.sync { _isFirstLaunch } }
        set { stateQueue.sync { _isFirstLaunch = newValue } }
    }
    public internal(set) var revenueCatProducts: [VxStoreProduct] {
        get { stateQueue.sync { _revenueCatProducts } }
        set {
            stateQueue.sync { _revenueCatProducts = newValue }
            NotificationCenter.default.post(name: .vxHubStateDidChange, object: nil)
        }
    }

    #if canImport(UIKit)
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
    #else
    public func initialize(
        config: VxHubConfig,
        delegate: VxHubDelegate?) {
            self.config = config
            self.delegate = delegate
            self.configureHub()
        }
    #endif

    public weak var delegate: VxHubDelegate?
    #if canImport(UIKit)
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    #endif

    var reachabilityManager: VxReachabilityManager?
    var downloadManager = VxDownloader()

    #if canImport(UIKit)
    public var deviceBottomHeight: CGFloat?
    #endif
    
    public func getVariantPayload(for key: String) -> [String: Any]? {
        return VxProviderRegistry.shared.analyticsProvider?.getPayload(for: key)
    }
    
    internal var getAppsflyerUUID: String {
        return VxProviderRegistry.shared.attributionProvider?.attributionUID ?? ""
    }
    
    public var deviceId: String {
        return VxKeychainManager().UDID
    }
    
    internal var getOneSignalPlayerId: String {
        #if os(iOS)
        return VxProviderRegistry.shared.pushProvider?.playerId ?? ""
        #else
        return ""
        #endif
    }

    internal var getOneSignalPlayerToken: String {
        #if os(iOS)
        return VxProviderRegistry.shared.pushProvider?.playerToken ?? ""
        #else
        return ""
        #endif
    }
    
    public func getIDFA() -> String? {
        #if os(iOS)
        let manager = VxPermissionManager()
        return manager.getIDFA()
        #else
        return nil
        #endif
    }
    
    public nonisolated var preferredLanguage: String? {
        return UserDefaults.VxHub_prefferedLanguage ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    public func isSimulator() -> Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    public func start(restoreTransactions: Bool = false,completion: (@Sendable(Bool) -> Void)? = nil) {
        self.startHub(restoreTransactions: restoreTransactions ,completion: completion)
    }
    
    public var supportedLanguages : [String] {
        return self.deviceInfo?.appConfig?.supportedLanguages ?? []
    }
    
    public var appStoreId: String {
        return deviceInfo?.thirdPartyInfos?.appStoreAppId ?? ""
    }
    
    public func logAppsFlyerEvent(eventName: String, values: [String: Any]?) {
        VxProviderRegistry.shared.attributionProvider?.logEvent(eventName: eventName, values: values)
    }

    public func logAmplitudeEvent(eventName: String, properties: [AnyHashable: Any]) {
        VxProviderRegistry.shared.analyticsProvider?.logEvent(eventName: eventName, properties: properties)
    }
        
    public func purchase(_ productToBuy: any VxPurchaseProduct, completion: (@Sendable (Bool) -> Void)? = nil) {
        guard let provider = VxProviderRegistry.shared.purchaseProvider else {
            VxLogger.shared.warning("Purchase provider not registered")
            completion?(false)
            return
        }
        provider.purchase(productToBuy) { success, transaction in
            DispatchQueue.main.async {
                let manager = VxNetworkManager()
                guard let transactionId = transaction?.transactionIdentifier,
                      let productId = transaction?.productIdentifier else {
                    VxLogger.shared.log("Identifiers nil transactionid: \(transaction?.transactionIdentifier ?? "??") - productId: \(transaction?.productIdentifier ?? "??")", level: .error)
                    self.handlePurchaseResult(productToBuy, success: false, completion: completion)
                    return
                }

                manager.checkPurchaseStatus(transactionId: transactionId, productId: productId) { isSuccess, premiumStatus, balance in
                    self.handlePurchaseResult(productToBuy, success: isSuccess, completion: completion)
                    if let balance {
                        VxHub.shared.balance = balance
                    }
                    if let isPremium = premiumStatus {
                        VxHub.shared.isPremium = isPremium
                    }
                }
            }
        }
    }
    
    public func restorePurchases(completion: (@Sendable (Bool, Bool, String?) -> Void)? = nil) {
        guard let provider = VxProviderRegistry.shared.purchaseProvider else {
            VxLogger.shared.warning("Purchase provider not registered")
            completion?(false, false, "Purchase provider not registered")
            return
        }
        provider.restorePurchases { hasActiveSubscription, hasActiveNonConsumable, error in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                if let error {
                    completion?(false, false, error)
                    return
                } else {
                    completion?(hasActiveSubscription, hasActiveNonConsumable, nil)
                }
            }
        }
    }
    
    #if canImport(UIKit)
    public func showEula(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        if isConnectedToInternet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard let urlString = self.deviceInfo?.appConfig?.eulaUrl else { return }
                guard let topVc = UIApplication.shared.topViewController() else { return }
                guard let url = URL(string: urlString) else { return }

                if topVc.isModal && topVc is VxWebViewer {
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
        } else {
            VxHub.shared.showBanner(VxLocalizables.InternetConnection.checkYourInternetConnection, type: .error, font: .rounded)
        }
    }
    #elseif os(macOS)
    public func showEula() {
        guard let urlString = self.deviceInfo?.appConfig?.eulaUrl,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    #endif
    
    #if canImport(UIKit)
    public func showPrivacy(isFullScreen: Bool = false, showCloseButton: Bool = false) {
        if isConnectedToInternet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard let urlString = self.deviceInfo?.appConfig?.privacyUrl else { return }
                guard let topVc = UIApplication.shared.topViewController() else { return }
                guard let url = URL(string: urlString) else { return }
                if topVc.isModal && topVc is VxWebViewer {
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
        } else {
            VxHub.shared.showBanner(VxLocalizables.InternetConnection.checkYourInternetConnection, type: .error, font: .rounded)
        }
    }
    #elseif os(macOS)
    public func showPrivacy() {
        guard let urlString = self.deviceInfo?.appConfig?.privacyUrl,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    #endif
    
    #if canImport(UIKit)
    public func presentWebUrl(url: URL, isFullScreen: Bool = false, showCloseButton: Bool = false) {
        DispatchQueue.main.async {
            VxWebViewer.shared.present(url: url,
                                       isFullscreen: isFullScreen,
                                       showCloseButton: showCloseButton)
        }
    }
    #elseif os(macOS)
    public func presentWebUrl(url: URL) {
        NSWorkspace.shared.open(url)
    }
    #endif
    
    public func changePreferredLanguage(to languageCode: String, completion: @Sendable @escaping(Bool) -> Void) {
        //        guard let supportedLanguages = self.deviceInfo?.appConfig?.supportedLanguages else { return }
        //        guard supportedLanguages.contains(languageCode) else { return }
        
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
                                           thirdPartyInfos: response?.thirdParty,
                                           support: response?.support,
                                           social: response?.social)
            
            self.remoteConfig = remoteConfig ?? [:]
            
            self.downloadManager.downloadLocalizables(from: response?.config?.localizationUrl) { [weak self] error  in
                self?.config?.responseQueue.async { [weak self] in
                    guard self != nil else {
                        completion(false)
                        return }
                    completion(true)
                }
            }
        }
    }
    
    #if os(iOS)
    public func requestAttPerm() {
        self.requestAtt()
    }
    #endif
    
    public func isDownloaded(url: URL) -> Bool {
        return UserDefaults.VxHub_downloadedUrls.contains(url.absoluteString)
    }
    
    //MARK: - Video helpers
    public func downloadVideo(from url: String, completion: @escaping @Sendable (Error?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            downloadManager.downloadVideo(from: url) { [weak self] error in
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
        let path = VxFileManager().pathForVideo(named: urlKey)
        return path
    }
    
    //MARK: - Image helpers
    #if canImport(UIKit)
    public func vxSetImage(
        on imageView: UIImageView,
        with url: URL?,
        activityIndicatorTintColor: UIColor = .gray,
        placeholderImage: UIImage? = nil,
        showLoadingIndicator: Bool = true,
        indicatorSize: Int = 4,
        completion: (@Sendable (UIImage?, Error?) -> Void)? = nil
    ) {
        guard let provider = VxProviderRegistry.shared.imageCachingProvider else {
            VxLogger.shared.warning("Image caching provider not registered")
            completion?(nil, nil)
            return
        }
        provider.setImage(
            on: imageView,
            with: url,
            activityIndicatorTintColor: activityIndicatorTintColor,
            placeholderImage: placeholderImage,
            showLoadingIndicator: showLoadingIndicator,
            indicatorSize: indicatorSize,
            completion: completion
        )
    }
    #endif
    
    public func downloadImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (Error?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            downloadManager.downloadImage(from: url, isLocalized: isLocalized) { [weak self] error in
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    completion(error)
                }
            }
        }
    }
    
    public func downloadImages(from urls: [String], isLocalized: Bool = false, completion: @escaping @Sendable ([String]) -> Void) {
        let downloadGroup = DispatchGroup()
        nonisolated(unsafe) var downloadedUrls = Array(repeating: "", count: urls.count)
        let lock = NSLock()

        for (index, url) in urls.enumerated() {
            downloadGroup.enter()
            downloadManager.downloadImage(from: url, isLocalized: isLocalized) { error in
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

        downloadGroup.notify(queue: .main) {
            completion(downloadedUrls.filter { !$0.isEmpty })
        }
    }
    
    #if canImport(UIKit)
    public func getDownloadedImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            VxFileManager().getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    #endif
    
    public func getDownloadedImage(from url: String, isLocalized: Bool = false, completion: @escaping @Sendable (Image?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            VxFileManager().getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    #if canImport(UIKit)
    public func getImages(from urls: [String], isLocalized: Bool = false, completion: @escaping @Sendable ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            nonisolated(unsafe) var images = [UIImage]()
            let imageLock = NSLock()
            let group = DispatchGroup()

            for url in urls {
                guard let url = URL(string: url) else { continue }
                group.enter()
                VxFileManager().getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                    if let image = image {
                        imageLock.lock()
                        images.append(image)
                        imageLock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(images)
            }
        }
    }
    #endif
    
    public func getImages(from urls: [String], isLocalized: Bool, completion: @escaping @Sendable ([Image]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            nonisolated(unsafe) var images = [Image]()
            let imageLock = NSLock()
            let group = DispatchGroup()

            for url in urls {
                guard let url = URL(string: url) else { continue }
                group.enter()
                VxFileManager().getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
                    if let image = image {
                        imageLock.lock()
                        images.append(image)
                        imageLock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(images)
            }
        }
    }
    
    //MARK: - Image Compresser
    #if canImport(UIKit)
    public func compressImage(
        _ image: UIImage,
        maxDimension: CGFloat = 2048,
        quality: CGFloat = 1.0,
        maxSize: Int = 2 * 1024 * 1024 // 2MB
    ) -> UIImage {
        let compresser = VxImageCompresser(maxDimension: maxDimension)
        return compresser.compressImage(
            image,
            maxSize: maxSize,
            quality: quality
        )
    }
    #endif
    
    //MARK: - Facebook helpers
    #if os(iOS)
    public func openFbUrlIfNeeded(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            VxProviderRegistry.shared.facebookProvider?.openFacebookUrl(url, application: UIApplication.shared)
        }
    }
    #endif
    
    //    //MARK: - Microphone helpers
    //    public func requestMicrophonePermission(
    //        from viewController: UIViewController?,
    //        title: String = VxLocalizables.Permission.microphoneAccessRequiredTitle,
    //        message: String = VxLocalizables.Permission.microphoneAccessRequiredMessage,
    //        askAgainIfDenied: Bool = true,
    //        completion: @escaping @Sendable (Bool) -> Void
    //    ) {
    //        VxPermissionManager().requestMicrophonePermission(from: viewController, title: title, message: message, askAgainIfDenied: askAgainIfDenied, completion: completion)
    //    }
    //
    //    public func isMicrophonePermissionGranted() -> Bool {
    //        return VxPermissionManager().isMicrophonePermissionGranted()
    //    }
    //
    //    //MARK: - Camera helpers
    //    public func requestCameraPermission(
    //        from viewController: UIViewController?,
    //        title: String = VxLocalizables.Permission.cameraAccessRequiredTitle,
    //        message: String = VxLocalizables.Permission.cameraAccessRequiredMessage,
    //        askAgainIfDenied: Bool = true,
    //        completion: @escaping @Sendable (Bool) -> Void
    //    ) {
    //        VxPermissionManager().requestCameraPermission(from: viewController, title: title, message: message, askAgainIfDenied: askAgainIfDenied, completion: completion)
    //    }
    //
    //    public func isCameraPermissionGranted() -> Bool {
    //        return VxPermissionManager().isCameraPermissionGranted()
    //    }
    //
    //    public func requestPhotoLibraryPermission(
    //        from viewController: UIViewController?,
    //        title: String = VxLocalizables.Permission.photoLibraryAccessRequiredTitle,
    //        message: String = VxLocalizables.Permission.photoLibraryAccessRequiredMessage,
    //        askAgainIfDenied: Bool = true,
    //        completion: @escaping @Sendable (Bool) -> Void
    //    ) {
    //        VxPermissionManager().requestPhotoLibraryPermission(from: viewController, title: title, message: message, askAgainIfDenied: askAgainIfDenied, completion: completion)
    //    }
    //
    //    public func isPhotoLibraryPermissionGranted() -> Bool {
    //        return VxPermissionManager().isPhotoLibraryPermissionGranted()
    //    }
    //
    //MARK: - Lottie helpers
    #if canImport(UIKit)
    public func createAndPlayAnimation(
        name: String,
        in view: UIView,
        tag: Int,
        removeOnFinish: Bool = true,
        loopAnimation: Bool = false,
        animationSpeed: CGFloat = 1,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        completion: (@Sendable () -> Void)? = nil
    ) {
        VxProviderRegistry.shared.animationProvider?.createAndPlayAnimation(
            name: name,
            in: view,
            tag: tag,
            removeOnFinish: removeOnFinish,
            loopAnimation: loopAnimation,
            animationSpeed: animationSpeed,
            contentMode: contentMode,
            completion: completion)
    }
    #endif

    #if canImport(UIKit)
    public func removeAnimation(with tag: Int) {
        VxProviderRegistry.shared.animationProvider?.clearAnimation(with: tag)
    }

    public func removeAllAnimations() {
        VxProviderRegistry.shared.animationProvider?.clearAllAnimations()
    }

    public func stopAnimation(with tag: Int) {
        VxProviderRegistry.shared.animationProvider?.stopAnimation(with: tag)
    }

    public func stopAllAnimations() {
        VxProviderRegistry.shared.animationProvider?.stopAllAnimations()
    }

    public func downloadLottieAnimation(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
        guard let provider = VxProviderRegistry.shared.animationProvider else {
            VxLogger.shared.warning("Animation provider not registered")
            completion(nil)
            return
        }
        provider.downloadAnimation(from: urlString, completion: completion)
    }
    #endif
    
    //MARK: - Reachability Helpers
    public func setupReachability() {
        reachabilityManager = VxReachabilityManager()
        self.isConnectedToInternet = reachabilityManager?.isConnected ?? false
        reachabilityManager?.delegate = self
        reachabilityManager?.startMonitoring()
    }
    
    public func resetReachability() {
        reachabilityManager?.stopMonitoring()
        reachabilityManager?.delegate = nil
        reachabilityManager = nil
        reachabilityManager = VxReachabilityManager()
        reachabilityManager?.delegate = self
        reachabilityManager?.startMonitoring()
    }
    
    public func killReachability() {
        reachabilityManager?.stopMonitoring()
        reachabilityManager?.delegate = nil
        reachabilityManager = nil
    }
    
    //MARK: - Build Configurations
    public func buildConfigValue(for key: String) -> String? {
        let buildConfig = BuildConfiguration()
        let value = buildConfig.value(for: key)
        return value
    }
    
    //MARK: - Request Review
    public func requestReview() {
        if UserDefaults.shouldRequestReview() {
            requestInApp()
            UserDefaults.updateLastReviewRequestDate()
        } else {
            requestInStorePage()
        }
    }
    
    #if canImport(UIKit)
    private func requestInApp() {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    #elseif os(macOS)
    private func requestInApp() {
        // macOS StoreKit review requires different API
    }
    #endif
    
    private func requestInStorePage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let appId = self.deviceInfo?.thirdPartyInfos?.appStoreAppId else { return }
            if let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") {
                #if canImport(UIKit)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                #elseif os(macOS)
                NSWorkspace.shared.open(url)
                #endif
            }
        }
    }
    
    //MARK: - Sentry
    public func startSentry(dsn: String, config: VxSentryConfig? = nil) {
        guard let provider = VxProviderRegistry.shared.crashReportingProvider else {
            VxLogger.shared.warning("Crash reporting provider not registered")
            return
        }
        let sentryConfig = config ?? VxSentryConfig(environment: self.config?.environment ?? .stage)
        provider.start(
            dsn: dsn,
            environment: sentryConfig.environment,
            enableDebug: sentryConfig.enableDebug,
            tracesSampleRate: sentryConfig.tracesSampleRate,
            profilesSampleRate: sentryConfig.profilesSampleRate,
            attachScreenshot: sentryConfig.attachScreenshot,
            attachViewHierarchy: sentryConfig.attachViewHierarchy
        )
        provider.setUserId(self.deviceId)
    }

    public func stopSentry() {
        VxProviderRegistry.shared.crashReportingProvider?.stop()
    }
    
    //MARK: - Paywall
    #if canImport(UIKit)
    public func showMainPaywall(
        from vc: UIViewController,
        configuration: VxMainPaywallConfiguration,
        presentationStyle: Int = VxPaywallPresentationStyle.present.rawValue,
        completion: @escaping @Sendable (Bool, String?) -> Void,
        onRestoreStateChange: @escaping @Sendable (Bool) -> Void,
        onReedemCodeButtonTapped: @escaping @Sendable () -> Void) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let viewModel = VxMainSubscriptionViewModel(
                    configuration: configuration,
                    onPurchaseSuccess: { productIdentifier in
                        DispatchQueue.main.async {
                            self.isPremium = true
                            completion(true, productIdentifier)
                            switch presentationStyle {
                            case 0:
                                vc.dismiss(animated: true)
                            case 1:
                                return
                                //                            vc.navigationController?.popViewController(animated: true)
                            default: return
                            }
                        }
                    },
                    onDismissWithoutPurchase: {
                        DispatchQueue.main.async {
                            completion(false, nil)
                        }
                    },
                    onRestoreAction: { restoreSuccess in
                        DispatchQueue.main.async {
                            onRestoreStateChange(restoreSuccess)
                        }
                    },
                    onReedemCodaButtonTapped: {
                        DispatchQueue.main.async {
                            onReedemCodeButtonTapped()
                        }
                    }
                )
                let subscriptionVC = VxMainSubscriptionViewController(viewModel: viewModel)

                switch presentationStyle {
                case 0:
                    subscriptionVC.modalPresentationStyle = .overFullScreen
                    vc.present(subscriptionVC, animated: true)
                case 1:
                    vc.navigationController?.pushViewController(subscriptionVC, animated: true)
                default: return
                }
            }
        }
    #endif
    
    #if canImport(UIKit)
    public func showPromoOffer(
        from vc: UIViewController,
        productIdentifier: String? = nil,
        productToCompareIdentifier: String?,
        presentationStyle: Int = VxPaywallPresentationStyle.present.rawValue,
        type: PromoOfferType = .v1,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            let viewModel = PromoOfferViewModel(
                productIdentifier: productIdentifier,
                productToCompareIdentifier: productToCompareIdentifier,
                onPurchaseSuccess: {
                    DispatchQueue.main.async {
                        self.isPremium = true
                        completion(true)
                        vc.dismiss(animated: true)
                    }
                },
                onDismissWithoutPurchase: {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                })
            let viewController = PromoOfferViewController(viewModel: viewModel, type: type)
            if presentationStyle == VxPaywallPresentationStyle.present.rawValue {
                viewController.modalPresentationStyle = .overFullScreen
                vc.present(viewController, animated: true)
            }else{
                vc.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    #endif
    
    #if canImport(UIKit)
    public func showContactUs(
        from vc: UIViewController,
        configuration: VxSupportConfiguration? = nil
    ) {
        DispatchQueue.main.async {
            let viewModel = VxSupportViewModel(
                appController: vc,
                configuration: configuration ?? VxSupportConfiguration()
            )
            let controller = VxSupportViewController(viewModel: viewModel)
            if let navController = vc.navigationController {
                controller.hidesBottomBarWhenPushed = true
                navController.pushViewController(controller, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .fullScreen
                vc.present(navController, animated: true)
            }
        }
    }
    #endif
    
    public func getProducts() {
        let network = VxNetworkManager()
        network.getProducts { products in
            
        }
    }
    
    //MARK: - Google Auth
    #if canImport(UIKit)
    public func signInWithGoogle(
        presenting viewController: UIViewController,
        completion: @escaping @Sendable (_ isSuccess: Bool?, _ error: Error?) -> Void
    ) {
        guard let clientID = self.deviceInfo?.thirdPartyInfos?.googleClientKey else {
            VxLogger.shared.log("Could not find Google Client Key In Response", level: .error, type: .error)
            completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find Google Client Key In Response"]))
            return
        }

        guard let provider = VxProviderRegistry.shared.googleSignInProvider else {
            VxLogger.shared.warning("Google Sign-In provider not registered")
            completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In provider not registered"]))
            return
        }

        provider.signIn(clientID: clientID, presenting: viewController) { userID, idToken, name, email, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard let idToken = idToken else {
                completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"]))
                return
            }

            let accountId = userID ?? ""
            let unwrappedEmail = email ?? ""

            VxNetworkManager().signInRequest(provider: VxSignInMethods.google.rawValue, token: idToken, accountId: accountId, name: name, email: unwrappedEmail) { response, error in
                if let error = error {
                    completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    return
                }

                if response?.social?.status == true {
                    completion(true, nil)
                    VxProviderRegistry.shared.purchaseProvider?.setEmail(unwrappedEmail)
                    VxProviderRegistry.shared.purchaseProvider?.setDisplayName(name)
                    #if os(iOS)
                    if !unwrappedEmail.isEmpty {
                        VxProviderRegistry.shared.pushProvider?.addEmail(unwrappedEmail)
                    }
                    #endif
                    VxProviderRegistry.shared.analyticsProvider?.setLoginDatas(name, unwrappedEmail)
                    VxLogger.shared.success("Sign in with Google success")
                } else {
                    completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                    VxLogger.shared.error("Sign in with Google failed")
                }
            }
        }
    }
    #endif
    
    //MARK: - Apple Auth
    private var appleSignInCompletion: ((_ isSuccess: Bool?, _ error: Error?) -> Void)?
    #if canImport(UIKit)
    public func signInWithApple(
        presenting viewController: UIViewController,
        completion: @escaping @Sendable (_ isSuccess: Bool?, _ error: Error?) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            VxLogger.shared.error("Sign in with Apple request: \(request)")

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self

            self.appleSignInCompletion = completion

            authorizationController.performRequests()
        }
    }
    #elseif os(macOS)
    public func signInWithApple(
        completion: @escaping @Sendable (_ isSuccess: Bool?, _ error: Error?) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self

            self.appleSignInCompletion = completion

            authorizationController.performRequests()
        }
    }
    #endif
    
    
    public func handleLogout(completion: (@Sendable ((any VxPurchaseCustomerInfo)?, Bool) -> Void)? = nil) {
        guard let vid = VxHub.shared.deviceInfo?.vid else {
            completion?(nil, false)
            return
        }

        if self.deviceInfo?.thirdPartyInfos?.appsflyerDevKey != nil,
           self.deviceInfo?.thirdPartyInfos?.appsflyerAppId != nil {
            VxProviderRegistry.shared.attributionProvider?.changeVid(customerUserID: vid)
        }

        #if os(iOS)
        if self.deviceInfo?.thirdPartyInfos?.onesignalAppId != nil {
            VxProviderRegistry.shared.pushProvider?.changeVid(for: vid)
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxProviderRegistry.shared.pushProvider?.playerId ?? ""
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxProviderRegistry.shared.pushProvider?.playerToken ?? ""
        }
        #endif

        if self.deviceInfo?.thirdPartyInfos?.amplitudeApiKey != nil {
            VxProviderRegistry.shared.analyticsProvider?.changeVid(vid: vid)
        }

        guard let purchaseProvider = VxProviderRegistry.shared.purchaseProvider else {
            VxLogger.shared.warning("Purchase provider not registered")
            completion?(nil, false)
            return
        }

        purchaseProvider.logOut { err in
            if let err {
                VxLogger.shared.error("Revenue cat logout error \(err)")
            }
            purchaseProvider.logIn(vid) { info, success, err in
                if let err {
                    VxLogger.shared.error("Revenue cat login error \(err)")
                }
                purchaseProvider.syncPurchases { info, err in
                    completion?(info, success)
                }
            }
        }
    }
    
    //MARK: - Delete Account
    public func deleteAccount(completion: @escaping @Sendable (Bool, String?) -> Void) {
        VxNetworkManager().deleteAccount { [weak self] isSuccess, errorMessage in
            guard self != nil else { return }
            if isSuccess {
                VxHub.shared.start(restoreTransactions: true) { [weak self] isSuccess in
                    guard self != nil else { return }
                    completion(isSuccess, errorMessage)
                }
            } else {
                completion(isSuccess, errorMessage)
                #if os(iOS)
                VxHub.shared.showBanner(errorMessage ?? "", type: .error, font: .custom("Manrope"))
                #endif
            }
        }
    }
    
    //MARK: - QRLogin
    public func validateQrCode(token: String, completion: @escaping @Sendable (Bool, String?) -> Void) {
        let network = VxNetworkManager()
        network.approveQrCode(token: token, completion: { isSuccess, errorMessage in
            completion(isSuccess, errorMessage)
        })
    }
    
    //MARK: - Promo code
    public func usePromoCode(_ code: String, completion: @escaping @Sendable (VxPromoCode) -> Void) {
        VxNetworkManager().validatePromoCode(code: code) { data in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                completion(data)
            }
        }
    }
    
    //MARK: - Tickets Unseen Status
    public func getTicketsUnseenStatus(completion: @escaping @Sendable (Bool, String?) -> Void) {
        VxNetworkManager().getTicketsUnseenStatus { isSuccess, errorMessage in
            completion(isSuccess, errorMessage)
        }
    }
    
    //MARK: - Claim Retention Coin
    public func claimRetentionCoinGift(completion: @escaping @Sendable (VxClaimRetentionCoinGiftResponse?, String?) -> Void) {
        VxNetworkManager().claimRetentionCoinGift { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let errorResponse):
                completion(nil, errorResponse.message)
            }
        }
    }
    
    // MARK: - Marks that the Retention Coin has been given to the user.
    public func markRetentionCoinAsGiven() {
        let keychainManager = VxKeychainManager()
        keychainManager.markRetentionCoinGiven()
    }
    
    // MARK: - Checks whether the Retention Coin has already been given to the user.
    public func hasGivenRetentionCoin() -> Bool {
        let keychainManager = VxKeychainManager()
        return keychainManager.hasGivenRetentionCoin()
    }

    //MARK: - Banner
    #if os(iOS)
    public func showBanner(_ message: String, type: VxBannerTypes = .success, font: VxFont, buttonLabel: String? = nil, action: (@Sendable () -> Void)? = nil) {
        DispatchQueue.main.async {
            VxProviderRegistry.shared.bannerProvider?.showBanner(message, type: type, font: font, buttonLabel: buttonLabel, action: action)
        }
    }
    #endif
    
    //MARK: - Device Insets Configuration
    #if canImport(UIKit)
    public func configureDeviceInset() {
        DispatchQueue.main.async {
            self.deviceBottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
    }
    #endif
    
    public func saveNonConsumablePurchase(productIdentifier: String) {
        let manager = VxKeychainManager()
        manager.setNonConsumable(productIdentifier, isActive: true)
        #if DEBUG && os(iOS)
        self.showBanner("\(productIdentifier) Claimed.", font: .rounded)
        #endif
    }
    
    public func getRevenueCatPremiumState(completion: @escaping @Sendable (Bool) -> Void) {
        guard let provider = VxProviderRegistry.shared.purchaseProvider else {
            VxLogger.shared.warning("Purchase provider not registered")
            completion(false)
            return
        }
        provider.getCustomerInfo { info, error in
            if info?.activeSubscriptions.isEmpty == false {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

internal extension VxHub {
    func configureRegisterResponse(_ response: DeviceRegisterResponse, _ remoteConfig: [String: Any]) {
        self.deviceInfo = VxDeviceInfo(vid: response.vid,
                                       deviceProfile: response.device,
                                       appConfig: response.config,
                                       thirdPartyInfos: response.thirdParty,
                                       support: response.support,
                                       social: response.social)
        self.remoteConfig = remoteConfig
        self.isPremium = deviceInfo?.deviceProfile?.premiumStatus == true
        self.balance = deviceInfo?.deviceProfile?.balance ?? 0
    }
}

private extension VxHub {
    #if canImport(UIKit)
    private func configureHub(application: UIApplication? = nil, scene: UIScene? = nil) { // { Cold Start } Only for didFinishLaunchingWithOptions
        self.setDeviceConfig { [weak self] in
            guard let self else { return }

            self.setupReachability()
            VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)
            #if os(iOS)
            if let application {
                VxProviderRegistry.shared.facebookProvider?.setupFacebook(
                    application: application,
                    didFinishLaunching: launchOptions)
            }
            #endif
            let networkManager = VxNetworkManager()
            networkManager.registerDevice { response, remoteConfig, error in
                if error != nil {
                    VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                    self.delegate?.vxHubDidFailWithError(error: error)
                    return
                }

                if response?.device?.banStatus == true {
                    self.delegate?.vxHubDidReceiveBanned()
                    return
                }

                self.checkForceUpdate(response: response) { stopProcess in
                    if stopProcess {
                        return
                    } else {
                        self.setFirstLaunch(from: response)
                        if response?.thirdParty?.appsflyerDevKey != nil,
                           response?.thirdParty?.appsflyerAppId != nil {
                            VxProviderRegistry.shared.attributionProvider?.start()
                        }
                        self.downloadExternalAssets(from: response)
                    }
                }
            }
        }
    }
    #else
    private func configureHub() {
        self.setDeviceConfig { [weak self] in
            guard let self else { return }

            self.setupReachability()
            VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)
            let networkManager = VxNetworkManager()
            networkManager.registerDevice { response, remoteConfig, error in
                if error != nil {
                    VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                    self.delegate?.vxHubDidFailWithError(error: error)
                    return
                }

                if response?.device?.banStatus == true {
                    self.delegate?.vxHubDidReceiveBanned()
                    return
                }

                self.checkForceUpdate(response: response) { stopProcess in
                    if stopProcess {
                        return
                    } else {
                        self.setFirstLaunch(from: response)
                        self.downloadExternalAssets(from: response)
                    }
                }
            }
        }
    }
    #endif

    private func checkForceUpdate(response: DeviceRegisterResponse?, completion: @escaping @Sendable (Bool) -> Void) {
        guard let forceUpdate = response?.config?.forceUpdate,
              let serverStoreVersion = response?.config?.storeVersion,
              forceUpdate == true else {
            completion(false)
            return
        }
        let networkManager = VxNetworkManager()
        networkManager.getAppStoreVersion() { [weak self] appStoreVersion in

            guard let self = self,
                  let appStoreVersion = appStoreVersion else {
                completion(false)
                return
            }

            if appStoreVersion == serverStoreVersion {
                self.delegate?.vxHubDidReceiveForceUpdate()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func setFirstLaunch(from response: DeviceRegisterResponse?) {
        guard self.isFirstLaunch == true else { return }

        if let appsFlyerDevKey = response?.thirdParty?.appsflyerDevKey,
           let appsFlyerAppId = response?.thirdParty?.appsflyerAppId {
            VxProviderRegistry.shared.attributionProvider?.initialize(
                devKey: appsFlyerDevKey,
                appID: appsFlyerAppId,
                delegate: self,
                customerUserID: deviceInfo?.vid ?? deviceConfig?.UDID ?? "",
                currentDeviceLanguage: deviceConfig?.deviceLang ?? "en")
        }

        #if os(iOS)
        if let fbAppId = response?.thirdParty?.facebookAppId,
           let fcClientToken = response?.thirdParty?.facebookClientToken {
            var appName: String?
            if let appNameResponse = response?.thirdParty?.facebookApplicationName {
                appName = appNameResponse
            } else {
                appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            }
            VxProviderRegistry.shared.facebookProvider?.initSdk(appId: fbAppId, clientToken: fcClientToken, appName: appName)
        }

        if let oneSignalAppId = response?.thirdParty?.onesignalAppId {
            VxProviderRegistry.shared.pushProvider?.initialize(appId: oneSignalAppId, launchOptions: self.launchOptions)
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxProviderRegistry.shared.pushProvider?.playerId ?? ""
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxProviderRegistry.shared.pushProvider?.playerToken ?? ""
        }
        #endif

        if let amplitudeKey = response?.thirdParty?.amplitudeApiKey {
            let deploymentKey = response?.thirdParty?.amplitudeDeploymentKey ?? ""
            VxProviderRegistry.shared.analyticsProvider?.initialize(
                userId: deviceInfo?.vid ?? deviceConfig?.UDID ?? "",
                apiKey: amplitudeKey,
                deploymentKey: deploymentKey,
                deviceId: deviceConfig?.UDID ?? "",
                isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
        }

        if let sentryDsn = response?.thirdParty?.sentryDsn {
            self.startSentry(dsn: sentryDsn)
        }

        if let revenueCatId = response?.thirdParty?.revenueCatId {
            guard let purchaseProvider = VxProviderRegistry.shared.purchaseProvider else {
                VxLogger.shared.warning("RevenueCat key found but VxHubRevenueCat module not registered")
                return
            }
            purchaseProvider.setLogLevel(.warn)
            purchaseProvider.configure(apiKey: revenueCatId, appUserID: deviceInfo?.vid ?? deviceConfig?.UDID ?? "")

            #if os(iOS)
            if let oneSignalId = VxProviderRegistry.shared.pushProvider?.playerId {
                purchaseProvider.setOnesignalID(oneSignalId)
            }
            #endif
            purchaseProvider.setAttributes(["$amplitudeDeviceId": deviceConfig?.UDID ?? ""])
            purchaseProvider.setAttributes(["$amplitudeUserId": "\(deviceInfo?.vid ?? deviceConfig?.UDID ?? "")"])

            #if os(iOS)
            purchaseProvider.setFBAnonymousID(VxProviderRegistry.shared.facebookProvider?.anonymousId ?? "")
            purchaseProvider.setAppsflyerID(VxProviderRegistry.shared.attributionProvider?.attributionUID ?? "")
            #endif
            purchaseProvider.syncAttributesAndOfferingsIfNeeded {}
        }
    }
    
    private func downloadExternalAssets(from response: DeviceRegisterResponse?, completion: (() -> Void)? = nil) {
        let assetGroup = DispatchGroup()
        assetGroup.enter()
        downloadManager.downloadLocalizables(from: response?.config?.localizationUrl) { error in
            defer { assetGroup.leave() }
            self.config?.responseQueue.async { [weak self] in
                guard self != nil else { return }
            }
        }

        if isFirstLaunch {
            assetGroup.enter()
            downloadManager.downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "") { url, error in
                defer { assetGroup.leave() }
                self.config?.responseQueue.async { [weak self] in
                    guard self != nil else { return }

                    if let firebaseProvider = VxProviderRegistry.shared.firebaseProvider {
                        if let url {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                firebaseProvider.configure(path: url)
                                VxProviderRegistry.shared.purchaseProvider?.setFirebaseAppInstanceID(firebaseProvider.appInstanceId)
                            }
                        } else {
                            let fileName = "GoogleService-Info.plist"
                            let manager = VxFileManager()
                            let savedFileURL = manager.vxHubDirectoryURL(for: .thirdPartyDir).appendingPathComponent(fileName)
                            firebaseProvider.configure(path: savedFileURL)
                            VxProviderRegistry.shared.purchaseProvider?.setFirebaseAppInstanceID(firebaseProvider.appInstanceId)
                        }
                    }
                }
            }
        }

        assetGroup.enter()
        if let purchaseProvider = VxProviderRegistry.shared.purchaseProvider, purchaseProvider.isConfigured {
            let productGroup = DispatchGroup()
            let productLock = NSLock()
            nonisolated(unsafe) var rcProducts: [any VxPurchaseProduct] = []
            nonisolated(unsafe) var networkProducts: [VxGetProductsResponse]? = nil

            productGroup.enter()
            purchaseProvider.requestProducts { products in
                productLock.lock()
                rcProducts = products
                productLock.unlock()
                productGroup.leave()
            }

            productGroup.enter()
            VxNetworkManager().getProducts { products in
                productLock.lock()
                networkProducts = products
                productLock.unlock()
                productGroup.leave()
            }

            productGroup.enter()
            purchaseProvider.getCustomerInfo { _, _ in
                productGroup.leave()
            }

            productGroup.notify(queue: self.config?.responseQueue ?? .main) { [weak self] in
                guard let self = self else { return }

                if UserDefaults.lastRestoredDeviceVid != VxHub.shared.deviceInfo?.vid,
                   self.isSimulator() == false {
                    VxLogger.shared.log("Restoring purchases for fresh account", level: .info)
                    UserDefaults.lastRestoredDeviceVid = VxHub.shared.deviceInfo?.vid
                }

                nonisolated(unsafe) var vxProducts = [VxStoreProduct]()
                let vxProductsLock = NSLock()
                let discountGroup = DispatchGroup()
                let keychain = VxKeychainManager()

                for product in rcProducts {
                    if let matchingNetworkProduct = networkProducts?.first(where: { $0.storeIdentifier == product.productIdentifier }) {
                        let productType = VxProductType(rawValue: product.productType.rawValue) ?? .consumable
                        let isNonConsumable = productType == .nonConsumable

                        if isNonConsumable && keychain.isNonConsumableActive(product.productIdentifier) {
                            continue
                        }

                        discountGroup.enter()
                        purchaseProvider.checkTrialOrIntroDiscountEligibility(product: product) { isEligible in
                            let vxProduct = VxStoreProduct(
                                storeProduct: product,
                                isDiscountOrTrialEligible: isEligible,
                                initialBonus: matchingNetworkProduct.initialBonus,
                                renewalBonus: matchingNetworkProduct.renewalBonus,
                                vxProductType: productType
                            )
                            vxProductsLock.lock()
                            vxProducts.append(vxProduct)
                            vxProductsLock.unlock()
                            discountGroup.leave()
                        }
                    }
                }

                discountGroup.notify(queue: self.config?.responseQueue ?? .main) {
                    self.revenueCatProducts = vxProducts
                    assetGroup.leave()
                }
            }
        } else {
            assetGroup.leave()
        }

        assetGroup.notify(queue: self.config?.responseQueue ?? .main) {
            if self.isFirstLaunch {
                self.isFirstLaunch = false
                completion?()
                VxLogger.shared.success("Initialized successfully")
            } else {
                completion?()
                VxLogger.shared.success("Started successfully")
            }
            self.delegate?.vxHubDidInitialize()
        }
    }
        
    private func isProductAlreadyPurchased(productIdentifier: String, customerInfo: (any VxPurchaseCustomerInfo)?, keychainManager: VxKeychainManager) -> Bool {
        guard let customerInfo = customerInfo else { return false }
        let hasPurchased = customerInfo.nonSubscriptionProductIdentifiers.contains(productIdentifier)
        if keychainManager.isNonConsumableActive(productIdentifier) {
            keychainManager.setNonConsumable(productIdentifier, isActive: true)
        }
        return hasPurchased
    }
    
    func checkAppStoreAccess() {
        let payment = SKPayment(product: SKProduct())
        let paymentQueue = SKPaymentQueue.default()
        
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.add(payment) // Test için bir ödeme başlatabilirsiniz
        }
    }
    
    
    func startHub(restoreTransactions: Bool = false, completion: (@Sendable (Bool) -> Void)? = nil) {  // { Warm Start } Only for applicationDidBecomeActive
        guard isFirstLaunch == false else {
            completion?(false)
            return
        }
        let networkManager = VxNetworkManager()
        networkManager.registerDevice { response, remoteConfig, error in
            if self.deviceInfo?.thirdPartyInfos?.appsflyerDevKey != nil,
               self.deviceInfo?.thirdPartyInfos?.appsflyerAppId != nil {
                VxProviderRegistry.shared.attributionProvider?.start()
            }
            if error != nil {
                self.delegate?.vxHubDidFailWithError(error: error)
                completion?(false)
                return
            }
            if restoreTransactions {
                self.downloadExternalAssets(from: response) {
                    completion?(true)
                }
            } else {
                completion?(true)
            }
        }
    }
    
    #if os(iOS)
    private func requestAtt() {
        let manager = VxPermissionManager()
        manager.requestAttPermission { state in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                VxProviderRegistry.shared.facebookProvider?.setAttFlag()
                switch state {
                case .granted:
                    VxProviderRegistry.shared.purchaseProvider?.collectDeviceIdentifiers()
                default:
                    return
                }
            }
        }
    }
    #endif
    
    #if canImport(UIKit)
    private func setDeviceConfig(completion: @escaping @Sendable() -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            var keychainManager = VxKeychainManager()
            keychainManager.appleId = (UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString).replacingOccurrences(of: "-", with: "")

            let appNames = ThirdPartyApps.allCases.map { $0.rawValue }
            var installedApps: [String: Bool] = [:]

            for appName in appNames {
                let appScheme = "\(appName)://"


                if let appUrl = URL(string: appScheme) {
                    installedApps[appName] = UIApplication.shared.canOpenURL(appUrl)
                } else {
                    installedApps[appName] = false
                }
            }


            let deviceConfig = VxDeviceConfig(
                carrier_region: "",
                os: UIDevice.current.systemVersion,
                battery: UIDevice.current.batteryLevel * 100,
                deviceOsVersion: UIDevice.current.systemVersion,
                deviceName: UIDevice.current.name.removingWhitespaces(),
                UDID: keychainManager.UDID,
                deviceModel: UIDevice.VxModelName.removingWhitespaces(),
                resolution: UIScreen.main.resolution,
                appleId: (UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString).replacingOccurrences(of: "-", with: ""),
                idfaStatus: VxPermissionManager().getIDFA() ?? "",
                installedApps: installedApps
            )
            self?.deviceConfig = deviceConfig
            completion()
        }
    }
    #elseif os(macOS)
    private func setDeviceConfig(completion: @escaping @Sendable() -> Void) {
        var keychainManager = VxKeychainManager()
        keychainManager.appleId = UUID().uuidString.replacingOccurrences(of: "-", with: "")

        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let modelName = {
            var size = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var model = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.model", &model, &size, nil, 0)
            return String(cString: model)
        }()
        let resolution = {
            if let screen = NSScreen.main {
                let size = screen.frame.size
                let scale = screen.backingScaleFactor
                return "\(Int(size.width * scale))x\(Int(size.height * scale))"
            }
            return "unknown"
        }()

        let deviceConfig = VxDeviceConfig(
            carrier_region: "",
            os: osVersionString,
            battery: 100,
            deviceOsVersion: osVersionString,
            deviceName: {
                var hostname = [CChar](repeating: 0, count: 256)
                gethostname(&hostname, 256)
                let name = String(cString: hostname)
                return name.isEmpty ? "Mac" : name.removingWhitespaces()
            }(),
            UDID: keychainManager.UDID,
            deviceModel: modelName.removingWhitespaces(),
            resolution: resolution,
            appleId: UUID().uuidString.replacingOccurrences(of: "-", with: ""),
            idfaStatus: "",
            devicePlatform: "MACOS",
            deviceType: "desktop"
        )
        self.deviceConfig = deviceConfig
        completion()
    }
    #endif
    
    
    // MARK: - Private Helper Methods

    private func handlePurchaseResult(_ product: any VxPurchaseProduct, success: Bool, completion: (@Sendable (Bool) -> Void)?) {
        guard success else {
            completion?(false)
            return
        }

        switch product.productType {
        case .autoRenewableSubscription, .nonRenewableSubscription:
            completion?(true)
        case .nonConsumable:
            saveNonConsumablePurchase(productIdentifier: product.productIdentifier)
            completion?(true)
        default:
            completion?(true)
        }
    }
}


//MARK: - Protocols
extension VxHub: VxAttributionDelegate {
    public func onConversionDataSuccess(_ info: [AnyHashable: Any]) {
        self.delegate?.onConversionDataSuccess(info)
    }

    public func onConversionDataFail(_ error: any Error) {
        self.delegate?.onConversionDataFail(error)
    }
}

extension VxHub: VxReachabilityDelegate{
    public func reachabilityStatusChanged(_ userInfo: [String : Any]) {
        guard let isConnected = userInfo["isConnected"] as? Bool
        else {
            VxLogger.shared.error("Reachability status changed with invalid userInfo")
            return
        }
        
        self.isConnectedToInternet = isConnected
        self.delegate?.vxHubDidChangeNetworkStatus(
            isConnected: isConnected,
            connectionType: currentConnectionType
        )
    }
}

extension VxHub: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let token = String(data: identityToken, encoding: .utf8) else {
            appleSignInCompletion?(nil, NSError(domain: "VxHub", code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Failed to get identity token"]))
            return
        }
        
        let keychainManager = VxKeychainManager()
        let accountId = appleIDCredential.user
        var displayName: String?
        if let givenName = appleIDCredential.fullName?.givenName,
           let lastName = appleIDCredential.fullName?.familyName {
            displayName = "\(givenName) \(lastName)"
        }else{
            displayName = keychainManager.getAppleLoginFullName()
        }
        
        let appleIdCredentialMail = appleIDCredential.email
        var jwtDecodedMail: String?
        if let identityTokenData = appleIDCredential.identityToken,
           let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            if let payload = VxHub.decodeJWTPayload(identityTokenString) {
                jwtDecodedMail = payload["email"] as? String ?? keychainManager.getAppleEmail()
            }
        }
        
        let unwrappedMail = appleIdCredentialMail ?? jwtDecodedMail
        VxNetworkManager().signInRequest(provider: VxSignInMethods.apple.rawValue, token: token, accountId: accountId, name: displayName, email: unwrappedMail) { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.appleSignInCompletion?(nil, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    VxLogger.shared.error("Sign in with Apple failed: \(error)")
                    return
                }
                
                if response?.social?.status == true {
                    let keychainManager = VxKeychainManager()
                    keychainManager.setAppleLoginDatas(displayName, unwrappedMail)
                    self.appleSignInCompletion?(true, nil)
                    VxProviderRegistry.shared.purchaseProvider?.setDisplayName(displayName)
                    VxProviderRegistry.shared.purchaseProvider?.setEmail(unwrappedMail)
                    #if os(iOS)
                    if let unwrappedMail {
                        VxProviderRegistry.shared.pushProvider?.addEmail(unwrappedMail)
                    }
                    #endif
                    VxProviderRegistry.shared.analyticsProvider?.setLoginDatas(displayName, unwrappedMail)
                    VxLogger.shared.success("Sign in with Apple success")
                } else {
                    self.appleSignInCompletion?(nil, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                    VxLogger.shared.error("Sign in with Apple failed")
                }
                self.appleSignInCompletion = nil
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithError error: Error) {
        appleSignInCompletion?(nil, error)
        appleSignInCompletion = nil
    }
}

extension VxHub: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if canImport(UIKit)
        return UIApplication.shared.topViewController()?.view.window ?? UIWindow()
        #elseif os(macOS)
        return NSApplication.shared.keyWindow ?? NSWindow()
        #endif
    }
}

// MARK: - JWT Decode Helper
extension VxHub {
    static func decodeJWTPayload(_ jwt: String) -> [String: Any]? {
        let segments = jwt.split(separator: ".")
        guard segments.count >= 2 else { return nil }
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}

public enum VxPaywallPresentationStyle: Int {
    case present
    case push
}

// MARK: - Async/Await Public API
public extension VxHub {

    #if canImport(UIKit)
    func initialize(
        config: VxHubConfig,
        delegate: VxHubDelegate? = nil,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        application: UIApplication
    ) async throws -> VxHubInitResult {
        self.config = config
        self.delegate = delegate
        self.launchOptions = launchOptions
        return try await configureHubAsync(application: application)
    }
    #else
    func initialize(
        config: VxHubConfig,
        delegate: VxHubDelegate? = nil
    ) async throws -> VxHubInitResult {
        self.config = config
        self.delegate = delegate
        return try await configureHubAsync()
    }
    #endif

    func start(restoreTransactions: Bool = false) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            self.startHub(restoreTransactions: restoreTransactions) { success in
                continuation.resume(returning: success)
            }
        }
    }

    func purchase(_ productToBuy: any VxPurchaseProduct) async -> Bool {
        await withCheckedContinuation { continuation in
            self.purchase(productToBuy) { success in
                continuation.resume(returning: success)
            }
        }
    }

    func restorePurchases() async throws -> (Bool, Bool, String?) {
        try await withCheckedThrowingContinuation { continuation in
            self.restorePurchases { hasActiveSubscription, hasActiveNonConsumable, error in
                continuation.resume(returning: (hasActiveSubscription, hasActiveNonConsumable, error))
            }
        }
    }

    func downloadVideo(from url: String) async throws {
        try await downloadManager.downloadVideo(from: url)
    }

    func downloadImage(from url: String, isLocalized: Bool = false) async throws {
        try await downloadManager.downloadImage(from: url, isLocalized: isLocalized)
    }

    func downloadImages(from urls: [String], isLocalized: Bool = false) async -> [String] {
        await withCheckedContinuation { continuation in
            self.downloadImages(from: urls, isLocalized: isLocalized) { downloadedUrls in
                continuation.resume(returning: downloadedUrls)
            }
        }
    }

    #if canImport(UIKit)
    func getDownloadedImage(from url: String, isLocalized: Bool = false) async -> UIImage? {
        guard let parsedUrl = URL(string: url) else { return nil }
        return await VxFileManager().getUiImage(url: parsedUrl.absoluteString, isLocalized: isLocalized)
    }
    #endif

    func getDownloadedImage(from url: String, isLocalized: Bool = false) async -> Image? {
        guard let parsedUrl = URL(string: url) else { return nil }
        return await VxFileManager().getImage(url: parsedUrl.absoluteString, isLocalized: isLocalized)
    }

    #if canImport(UIKit)
    func getImages(from urls: [String], isLocalized: Bool = false) async -> [UIImage] {
        await withTaskGroup(of: UIImage?.self) { group in
            for url in urls {
                group.addTask {
                    guard let parsedUrl = URL(string: url) else { return nil }
                    return await VxFileManager().getUiImage(url: parsedUrl.absoluteString, isLocalized: isLocalized)
                }
            }
            var images = [UIImage]()
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
    #endif

    func getImages(from urls: [String], isLocalized: Bool) async -> [Image] {
        await withTaskGroup(of: Image?.self) { group in
            for url in urls {
                group.addTask {
                    guard let parsedUrl = URL(string: url) else { return nil }
                    return await VxFileManager().getImage(url: parsedUrl.absoluteString, isLocalized: isLocalized)
                }
            }
            var images = [Image]()
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }

    #if canImport(UIKit)
    func signInWithGoogle(
        presenting viewController: UIViewController
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.signInWithGoogle(presenting: viewController) { isSuccess, error in
                if let error = error {
                    continuation.resume(throwing: VxHubError.signInFailed(provider: "Google", reason: error.localizedDescription))
                } else {
                    continuation.resume(returning: isSuccess ?? false)
                }
            }
        }
    }
    #endif

    #if canImport(UIKit)
    func signInWithApple(
        presenting viewController: UIViewController
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.signInWithApple(presenting: viewController) { isSuccess, error in
                if let error = error {
                    continuation.resume(throwing: VxHubError.signInFailed(provider: "Apple", reason: error.localizedDescription))
                } else {
                    continuation.resume(returning: isSuccess ?? false)
                }
            }
        }
    }
    #elseif os(macOS)
    func signInWithApple() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.signInWithApple { isSuccess, error in
                if let error = error {
                    continuation.resume(throwing: VxHubError.signInFailed(provider: "Apple", reason: error.localizedDescription))
                } else {
                    continuation.resume(returning: isSuccess ?? false)
                }
            }
        }
    }
    #endif

    func deleteAccount() async throws -> (Bool, String?) {
        try await withCheckedThrowingContinuation { continuation in
            self.deleteAccount { isSuccess, errorMessage in
                continuation.resume(returning: (isSuccess, errorMessage))
            }
        }
    }

    func handleLogout() async throws -> ((any VxPurchaseCustomerInfo)?, Bool) {
        try await withCheckedThrowingContinuation { continuation in
            self.handleLogout { info, success in
                continuation.resume(returning: (info, success))
            }
        }
    }

    func validateQrCode(token: String) async throws -> (Bool, String?) {
        try await withCheckedThrowingContinuation { continuation in
            self.validateQrCode(token: token) { isSuccess, errorMessage in
                continuation.resume(returning: (isSuccess, errorMessage))
            }
        }
    }

    func usePromoCode(_ code: String) async -> VxPromoCode {
        await withCheckedContinuation { continuation in
            self.usePromoCode(code) { promoCode in
                continuation.resume(returning: promoCode)
            }
        }
    }

    func getTicketsUnseenStatus() async throws -> (Bool, String?) {
        try await withCheckedThrowingContinuation { continuation in
            self.getTicketsUnseenStatus { isSuccess, errorMessage in
                continuation.resume(returning: (isSuccess, errorMessage))
            }
        }
    }

    func claimRetentionCoinGift() async throws -> VxClaimRetentionCoinGiftResponse {
        try await VxNetworkManager().claimRetentionCoinGift()
    }

    func changePreferredLanguage(to languageCode: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.changePreferredLanguage(to: languageCode) { success in
                continuation.resume(returning: success)
            }
        }
    }

    #if canImport(UIKit)
    func downloadLottieAnimation(from urlString: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            VxLottieManager.shared.downloadAnimation(from: urlString) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    #endif

    func getRevenueCatPremiumState() async -> Bool {
        await withCheckedContinuation { continuation in
            self.getRevenueCatPremiumState { isPremium in
                continuation.resume(returning: isPremium)
            }
        }
    }
}

// MARK: - Async Internal Implementation
private extension VxHub {

    #if canImport(UIKit)
    func configureHubAsync(application: UIApplication? = nil) async throws -> VxHubInitResult {
        await setDeviceConfigAsync()

        self.setupReachability()
        VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)
        #if os(iOS)
        if let application {
            VxProviderRegistry.shared.facebookProvider?.setupFacebook(
                application: application,
                didFinishLaunching: launchOptions)
        }
        #endif

        let networkManager = VxNetworkManager()
        let (response, _) = try await networkManager.registerDevice()

        if response.device?.banStatus == true {
            self.delegate?.vxHubDidReceiveBanned()
            return .banned
        }

        let shouldForceUpdate = try await checkForceUpdateAsync(response: response)
        if shouldForceUpdate {
            return .forceUpdateRequired
        }

        self.setFirstLaunch(from: response)
        if response.thirdParty?.appsflyerDevKey != nil,
           response.thirdParty?.appsflyerAppId != nil {
            VxProviderRegistry.shared.attributionProvider?.start()
        }
        try await downloadExternalAssetsAsync(from: response)

        VxLogger.shared.success("Initialized successfully")
        self.delegate?.vxHubDidInitialize()
        return .success
    }
    #else
    func configureHubAsync() async throws -> VxHubInitResult {
        await setDeviceConfigAsync()

        self.setupReachability()
        VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)

        let networkManager = VxNetworkManager()
        let (response, _) = try await networkManager.registerDevice()

        if response.device?.banStatus == true {
            self.delegate?.vxHubDidReceiveBanned()
            return .banned
        }

        let shouldForceUpdate = try await checkForceUpdateAsync(response: response)
        if shouldForceUpdate {
            return .forceUpdateRequired
        }

        self.setFirstLaunch(from: response)
        try await downloadExternalAssetsAsync(from: response)

        VxLogger.shared.success("Initialized successfully")
        self.delegate?.vxHubDidInitialize()
        return .success
    }
    #endif

    func setDeviceConfigAsync() async {
        await withCheckedContinuation { continuation in
            setDeviceConfig {
                continuation.resume()
            }
        }
    }

    func checkForceUpdateAsync(response: DeviceRegisterResponse?) async throws -> Bool {
        guard let forceUpdate = response?.config?.forceUpdate,
              let serverStoreVersion = response?.config?.storeVersion,
              forceUpdate == true else {
            return false
        }

        let networkManager = VxNetworkManager()
        let appStoreVersion = try await networkManager.getAppStoreVersion()

        guard let appStoreVersion = appStoreVersion else {
            return false
        }

        if appStoreVersion == serverStoreVersion {
            await MainActor.run {
                self.delegate?.vxHubDidReceiveForceUpdate()
            }
            return true
        }

        return false
    }

    func downloadExternalAssetsAsync(from response: DeviceRegisterResponse?) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Download localizables
            group.addTask {
                try await self.downloadManager.downloadLocalizables(from: response?.config?.localizationUrl)
            }

            // Download Google Service Info Plist (only first launch)
            if isFirstLaunch {
                group.addTask {
                    let url = try await self.downloadManager.downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "")

                    await MainActor.run {
                        if let firebaseProvider = VxProviderRegistry.shared.firebaseProvider {
                            if let url {
                                firebaseProvider.configure(path: url)
                                VxProviderRegistry.shared.purchaseProvider?.setFirebaseAppInstanceID(firebaseProvider.appInstanceId)
                            } else {
                                let fileName = "GoogleService-Info.plist"
                                let manager = VxFileManager()
                                let savedFileURL = manager.vxHubDirectoryURL(for: .thirdPartyDir).appendingPathComponent(fileName)
                                firebaseProvider.configure(path: savedFileURL)
                                VxProviderRegistry.shared.purchaseProvider?.setFirebaseAppInstanceID(firebaseProvider.appInstanceId)
                            }
                        }
                    }
                }
            }

            // Fetch and process products
            group.addTask {
                await self.fetchAndProcessProductsAsync()
            }

            try await group.waitForAll()
        }

        if self.isFirstLaunch {
            self.isFirstLaunch = false
        }
    }

    func fetchAndProcessProductsAsync() async {
        guard let purchaseProvider = VxProviderRegistry.shared.purchaseProvider else { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            purchaseProvider.requestProducts { products in
                let networkManager = VxNetworkManager()
                networkManager.getProducts { networkProducts in
                    self.config?.responseQueue.async { [weak self] in
                        guard let self = self else {
                            continuation.resume()
                            return
                        }

                        purchaseProvider.getCustomerInfo { (purchaserInfo, error) in
                            @Sendable func processProducts(with customerInfo: (any VxPurchaseCustomerInfo)?) {
                                nonisolated(unsafe) var vxProducts = [VxStoreProduct]()
                                let vxProductsLock = NSLock()
                                let discountGroup = DispatchGroup()
                                let keychain = VxKeychainManager()
                                for product in products {
                                    if let matchingNetworkProduct = networkProducts?.first(where: { $0.storeIdentifier == product.productIdentifier }) {
                                        let productType = VxProductType(rawValue: product.productType.rawValue) ?? .consumable
                                        let isNonConsumable = productType == .nonConsumable

                                        if isNonConsumable && keychain.isNonConsumableActive(product.productIdentifier) {
                                            continue
                                        }

                                        discountGroup.enter()
                                        purchaseProvider.checkTrialOrIntroDiscountEligibility(product: product) { isEligible in
                                            let vxProduct = VxStoreProduct(
                                                storeProduct: product,
                                                isDiscountOrTrialEligible: isEligible,
                                                initialBonus: matchingNetworkProduct.initialBonus,
                                                renewalBonus: matchingNetworkProduct.renewalBonus,
                                                vxProductType: productType
                                            )
                                            vxProductsLock.lock()
                                            vxProducts.append(vxProduct)
                                            vxProductsLock.unlock()
                                            discountGroup.leave()
                                        }
                                    }
                                }

                                discountGroup.notify(queue: self.config?.responseQueue ?? .main) {
                                    self.revenueCatProducts = vxProducts
                                    continuation.resume()
                                }
                            }

                            if UserDefaults.lastRestoredDeviceVid != VxHub.shared.deviceInfo?.vid,
                               self.isSimulator() == false {
                                VxLogger.shared.log("Restoring purchases for fresh account", level: .info)
                                UserDefaults.lastRestoredDeviceVid = VxHub.shared.deviceInfo?.vid
                                processProducts(with: purchaserInfo)
                            } else {
                                processProducts(with: purchaserInfo)
                            }
                        }
                    }
                }
            }
        }
    }
}
