// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import RevenueCat
import AppTrackingTransparency
import SwiftUICore
import FacebookCore
import StoreKit
import FirebaseAuth
import GoogleSignIn
import Combine
import AuthenticationServices
import CloudKit

@objc public protocol VxHubDelegate: AnyObject {
    // Core methods (required)
    @objc func vxHubDidInitialize()
    @objc func vxHubDidStart()
    @objc func vxHubDidFailWithError(error: String?)
    
    // Optional SDK-specific methods
    @objc optional func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])
    @objc optional func onConversionDataFail(_ error: Error)
    @objc optional func oneSignalDidReceiveNotification(_ info: [String: Any])
    @objc optional func vxHubDidReceiveForceUpdate()
    @objc optional func vxHubDidReceiveBanned()
    
    @objc optional func onPurchaseComplete(didSucceed: Bool, error: String?)
    @objc optional func onRestorePurchases(didSucceed: Bool, error: String?)
    @objc optional func onFetchProducts(products: [StoreProduct]?, error: String?)
    @objc optional func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String)
}


final public class VxHub : NSObject, @unchecked Sendable{
    public static let shared = VxHub()
    
    public private(set) var config: VxHubConfig?
    public private(set) var deviceInfo: VxDeviceInfo?
    public private(set) var deviceConfig: VxDeviceConfig?
    public private(set) var remoteConfig = [String: Any]()
    
    public var isPremium: Bool = false
    public var balance: Int = 0
    
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
    
    var reachabilityManager: VxReachabilityManager?
    public var isConnectedToInternet: Bool = false
    public private(set) var currentConnectionType: String = VxConnection.unavailable.description
    
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
        return VxKeychainManager().UDID
    }
    
    internal var getOneSignalPlayerId: String {
        let manager = VxOneSignalManager()
        return manager.playerId ?? ""
    }
    
    internal var getOneSignalPlayerToken: String {
        let manager = VxOneSignalManager()
        return manager.playerToken ?? ""
    }
    
    public func getIDFA() -> String? {
        let manager = VxPermissionManager()
        return manager.getIDFA()
    }
    
    public nonisolated var preferredLanguage: String? {
        return UserDefaults.VxHub_prefferedLanguage ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    public func start(completion: (@Sendable(Bool) -> Void)? = nil) {
        self.startHub(completion: completion)
    }
    
    public var supportedLanguages : [String] {
        return self.deviceInfo?.appConfig?.supportedLanguages ?? []
    }
    
    public var appStoreId: String {
        return deviceInfo?.thirdPartyInfos?.appStoreAppId ?? ""
    }
    
    public func logAppsFlyerEvent(eventName: String, values: [String: Any]?) {
        VxAppsFlyerManager.shared.logAppsFlyerEvent(eventName: eventName, values: values)
    }
    
    public func logAmplitudeEvent(eventName: String, properties: [AnyHashable: Any]) {
        VxAmplitudeManager.shared.logEvent(eventName: eventName, properties: properties)
    }
    
    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool) -> Void)? = nil) {
        VxRevenueCat().purchase(productToBuy) { success in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                completion?(success)
            }
        }
    }
    
    public func restorePurchases(completion: (@Sendable (Bool) -> Void)? = nil) {
        VxRevenueCat().restorePurchases() { success in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                completion?(success)
            }
        }
    }
    
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
    
    public func presentWebUrl(url: URL, isFullScreen: Bool = false, showCloseButton: Bool = false) {
        DispatchQueue.main.async {
            VxWebViewer.shared.present(url: url,
                                       isFullscreen: isFullScreen,
                                       showCloseButton: showCloseButton)
        }
    }
    
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
            
            VxDownloader().downloadLocalizables(from: response?.config?.localizationUrl) { [weak self] error  in
                self?.config?.responseQueue.async { [weak self] in
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
            VxDownloader().downloadVideo(from: url) { [weak self] error in
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
            VxDownloader().downloadImage(from: url, isLocalized: isLocalized) { [weak self] error in
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
                VxDownloader().downloadImage(from: url,isLocalized: isLocalized) { [weak self] error in
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
            VxFileManager().getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
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
            VxFileManager().getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
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
                VxFileManager().getUiImage(url: url.absoluteString, isLocalized: isLocalized) { image in
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
                VxFileManager().getImage(url: url.absoluteString, isLocalized: isLocalized) { image in
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
    
    //MARK: - Image Compresser
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
    
    //MARK: - Facebook helpers
    public func openFbUrlIfNeeded(url:URL) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            VxFacebookManager().openFacebookUrl(url, application: UIApplication.shared)
        }
    }
    
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
        VxLottieManager.shared.createAndPlayAnimation(
            name: name,
            in: view,
            tag: tag,
            removeOnFinish: removeOnFinish,
            loopAnimation: loopAnimation,
            animationSpeed: animationSpeed,
            contentMode: contentMode,
            completion: completion)
    }
    
    public func removeAnimation(with tag: Int) {
        VxLottieManager.shared.clearAnimation(with: tag)
    }
    
    public func removeAllAnimations() {
        VxLottieManager.shared.clearAllAnimations()
    }
    
    public func stopAnimation(with tag: Int) {
        VxLottieManager.shared.stopAnimation(with: tag)
    }
    
    public func stopAllAnimations() {
        VxLottieManager.shared.stopAllAnimations()
    }
    
    public func downloadLottieAnimation(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
        VxLottieManager.shared.downloadAnimation(from: urlString, completion: completion)
    }
    
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
    
    private func requestInApp() {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    private func requestInStorePage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let appId = self.deviceInfo?.thirdPartyInfos?.appStoreAppId else { return }
            if let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: - Sentry
    public func startSentry(dsn: String, config: VxSentryConfig? = nil) {
        let sentryManager = VxSentryManager()
        sentryManager.start(dsn: dsn, config: config)
    }
    
    public func stopSentry() {
        let sentryManager = VxSentryManager()
        sentryManager.stop()
    }
    
    //MARK: - Paywall
    public func showMainPaywall(
        from vc: UIViewController,
        configuration: VxMainPaywallConfiguration,
        presentationStyle: Int = VxPaywallPresentationStyle.present.rawValue,
        completion: @escaping @Sendable (Bool) -> Void,
        onRestoreStateChange: @escaping @Sendable (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let viewModel = VxMainSubscriptionViewModel(
                configuration: configuration,
                onPurchaseSuccess: {
                    DispatchQueue.main.async {
                        self.isPremium = true
                        completion(true)
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
                        completion(false)
                    }
                },
                onRestoreAction: { restoreSuccess in
                    DispatchQueue.main.async {
                        onRestoreStateChange(restoreSuccess)
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
    
    public func showPromoOffer(
        from vc: UIViewController,
        productIdentifier: String? = nil,
        type: PromoOfferType = .v1,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            let viewModel = PromoOfferViewModel(
                productIdentifier: productIdentifier,
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
            viewController.modalPresentationStyle = .overFullScreen
            vc.present(viewController, animated: true)
        }
    }
    
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
            controller.hidesBottomBarWhenPushed = true
            vc.navigationController?.pushViewController(controller, animated: true)
        }
    }

    public func getProducts() {
        let network = VxNetworkManager()
        network.getProducts { products in
            
        }
    }
    
    //MARK: - Google Auth
    public func signInWithGoogle(
        presenting viewController: UIViewController,
        completion: @escaping @Sendable (_ isSuccess: Bool?, _ error: Error?) -> Void
    ) {
        guard let clientID = self.deviceInfo?.thirdPartyInfos?.googleClientKey else {
            VxLogger.shared.log("Could not find Google Client Key In Response", level: .error, type: .error)
            completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find Google Client Key In Response"]))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let signInResult = signInResult,
                  let idToken = signInResult.user.idToken?.tokenString
            else {
                completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"]))
                return
            }
            
            let accountId = signInResult.user.userID ?? ""
            let name = signInResult.user.profile?.name
            let email = signInResult.user.profile?.email ?? ""

            VxNetworkManager().signInRequest(provider: VxSignInMethods.google.rawValue, token: idToken, accountId: accountId, name: name, email: email) { response, error in
                if let error = error {
                    completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    return
                }
                
                if response?.social?.status == true {
                    completion(true, nil)
                    VxLogger.shared.success("Sign in with Google success")
                } else {
                    completion(false, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                    VxLogger.shared.error("Sign in with Google failed")
                }
            }
        }
    }
    
    //MARK: - Apple Auth
    private var appleSignInCompletion: ((_ isSuccess: Bool?, _ error: Error?) -> Void)?
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
    
    //MARK: - Delete Account
    public func deleteAccount(completion: @escaping @Sendable (Bool, String?) -> Void) {
        VxNetworkManager().deleteAccount { [weak self] isSuccess, errorMessage in
            guard let self else { return }
            completion(isSuccess, errorMessage)
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

    //MARK: - Banner
    public func showBanner(_ message: String, type: VxBannerTypes = .success, font: VxFont, buttonLabel: String? = nil, action: (@Sendable () -> Void)? = nil) {
        DispatchQueue.main.async {
            let model = VxBannerModel(id: UUID().uuidString, type: type, font: font, title: message, buttonLabel: buttonLabel, buttonAction: action)
            VxBannerManager.shared.addBannerToQuery(type: type, model: model)
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
    private func configureHub(application: UIApplication? = nil, scene: UIScene? = nil) { // { Cold Start } Only for didFinishLaunchingWithOptions
        self.setDeviceConfig { [weak self] in
            guard let self else { return }
            
            self.setupReachability()
            VxLogger.shared.setLogLevel(config?.logLevel ?? .verbose)
            if let application {
                VxFacebookManager().setupFacebook(
                    application: application,
                    didFinishLaunching: launchOptions)
            }
            let networkManager = VxNetworkManager()
            networkManager.registerDevice { response, remoteConfig, error in
                if error != nil {
                    VxLogger.shared.error("VxHub failed with error: \(String(describing: error))")
                    self.delegate?.vxHubDidFailWithError(error: error)
                    return
                }
                
                
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
                customerUserID: deviceInfo?.vid ?? deviceConfig?.UDID ?? "",
                currentDeviceLanguage:  deviceConfig!.deviceLang)
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
            VxFacebookManager().initFbSdk(appId: fbAppId, clientToken: fcClientToken, appName: appName)
        }
        
        
        if let oneSignalAppId = response?.thirdParty?.onesignalAppId {
            VxOneSignalManager().initialize(appId: oneSignalAppId, launchOptions: self.launchOptions)
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId = VxOneSignalManager().playerId ?? ""
            self.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken = VxOneSignalManager().playerToken ?? ""
        }
        
        if let amplitudeKey = response?.thirdParty?.amplitudeApiKey {
            if self.config?.environment == .stage {
                var deploymentKey: String
                if let key = response?.thirdParty?.amplitudeDeploymentKey {
                    deploymentKey = key
                }else{
                    deploymentKey = ""
                }
                VxAmplitudeManager.shared.initialize(
                    userId: deviceInfo?.vid ?? deviceConfig?.UDID ?? "",
                    apiKey: amplitudeKey,
                    deploymentKey: deploymentKey,
                    deviceId: deviceConfig?.UDID ?? "",
                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
            }else {
                var deploymentKey: String
                if let key = response?.thirdParty?.amplitudeDeploymentKey {
                    deploymentKey = key
                }else{
                    deploymentKey = ""
                }
                VxAmplitudeManager.shared.initialize(
                    userId: deviceInfo?.vid ?? deviceConfig?.UDID ?? "",
                    apiKey: amplitudeKey,
                    deploymentKey: deploymentKey,
                    deviceId: deviceConfig?.UDID ?? "",
                    isSubscriber: self.deviceInfo?.deviceProfile?.premiumStatus == true)
            }
        }
        
        if let sentryDsn = response?.thirdParty?.sentryDsn {
            self.startSentry(dsn: sentryDsn)
        }
        
        if let revenueCatId = response?.thirdParty?.revenueCatId {
            Purchases.logLevel = .warn
            Purchases.configure(withAPIKey: revenueCatId, appUserID: deviceInfo?.vid ?? deviceConfig?.UDID ?? "")
            
            if let oneSignalId = VxOneSignalManager().playerId {
                Purchases.shared.attribution.setOnesignalID(oneSignalId)
            }
            Purchases.shared.attribution.setAttributes(["$amplitudeDeviceId": deviceConfig?.UDID ?? ""])
            Purchases.shared.attribution.setAttributes(["$amplitudeUserId": "\(deviceInfo?.vid ?? deviceConfig?.UDID ?? "")"])
            
            Purchases.shared.attribution.setFBAnonymousID(VxFacebookManager().facebookAnonymousId)
            
            Purchases.shared.attribution.setAppsflyerID(VxAppsFlyerManager.shared.appsflyerUID)
            Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, publicError in }
            
        }
    }
    
    private func downloadExternalAssets(from response: DeviceRegisterResponse?) {
        
        dispatchGroup.enter()
        VxDownloader().downloadLocalizables(from: response?.config?.localizationUrl) { error  in
            defer { self.dispatchGroup.leave() }
            self.config?.responseQueue.async { [weak self] in
                guard self != nil else { return }
            }
        }
        
        if isFirstLaunch {
            dispatchGroup.enter()
            VxDownloader().downloadGoogleServiceInfoPlist(from: response?.thirdParty?.firebaseConfigUrl ?? "") { url, error in
                defer {  self.dispatchGroup.leave() }
                self.config?.responseQueue.async { [weak self] in
                    guard self != nil else { return }
                    if let url {
                        VxFirebaseManager().configure(path: url)
                        Purchases.shared.attribution.setFirebaseAppInstanceID(VxFirebaseManager().appInstanceId)
                    }
                }
            }
        }
        
        dispatchGroup.enter()
        VxRevenueCat().requestRevenueCatProducts { products in
            let networkManager = VxNetworkManager()
            networkManager.getProducts { networkProducts in
                self.config?.responseQueue.async { [weak self] in
                    guard let self = self else { return }
                    
                    Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                        @Sendable func processProducts(with customerInfo: CustomerInfo?) {
                            var vxProducts = [VxStoreProduct]()
                            let discountGroup = DispatchGroup()
                            
                            for product in products {
                                if let matchingNetworkProduct = networkProducts?.first(where: { $0.storeIdentifier == product.productIdentifier }) {
                                    let productType = VxProductType(rawValue: product.productType.rawValue) ?? .consumable
                                    let isNonConsumable = productType == .nonConsumable
                                    
                                    if isNonConsumable && self.isProductAlreadyPurchased(productIdentifier: product.productIdentifier, customerInfo: customerInfo) {
                                        continue
                                    }
                                    
                                    discountGroup.enter()
                                    Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product) { isEligible in
                                        let vxProduct = VxStoreProduct(
                                            storeProduct: product,
                                            isDiscountOrTrialEligible: isEligible.isEligible,
                                            initialBonus: matchingNetworkProduct.initialBonus,
                                            renewalBonus: matchingNetworkProduct.renewalBonus,
                                            vxProductType: productType
                                        )
                                        vxProducts.append(vxProduct)
                                        discountGroup.leave()
                                    }
                                }
                            }
                            
                            discountGroup.notify(queue: self.config?.responseQueue ?? .main) {
                                self.revenueCatProducts = vxProducts
                                self.dispatchGroup.leave()
                            }
                        }
                        
                        if UserDefaults.lastRestoredDeviceVid != VxHub.shared.deviceInfo?.vid,  // Is fresh account
                           self.isSimulator() == false {
                            Purchases.shared.syncPurchases { (restoredInfo, restoreError) in
                                VxLogger.shared.log("Restoring purchases for fresh account", level: .info)
                                UserDefaults.lastRestoredDeviceVid = VxHub.shared.deviceInfo?.vid
                                let networkManager = VxNetworkManager()
                                networkManager.registerDevice { response, remoteConfig, error in
                                    processProducts(with: restoredInfo)
                                }
                            }
                        } else {
                            processProducts(with: purchaserInfo)
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: self.config?.responseQueue ?? .main) {
            if self.isFirstLaunch {
                self.isFirstLaunch = false
                VxLogger.shared.success("Initialized successfully")
            } else {
                VxLogger.shared.success("Started successfully")
            }
            self.delegate?.vxHubDidInitialize()
        }
    }
    
    public func isSimulator() -> Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    func checkAppStoreAccess() {
        let payment = SKPayment(product: SKProduct())
        let paymentQueue = SKPaymentQueue.default()
        
        if SKPaymentQueue.canMakePayments() {
            print("Kullanıcı satın alma yapabilir, yani büyük olasılıkla App Store’a giriş yapmış.")
            paymentQueue.add(payment) // Test için bir ödeme başlatabilirsiniz
        } else {
            print("Kullanıcı satın alma yapamaz, App Store’a giriş yapmamış olabilir.")
        }
    }
    
    private func isProductAlreadyPurchased(productIdentifier: String, customerInfo: CustomerInfo?) -> Bool {
        guard let customerInfo = customerInfo else {
            debugPrint("PurchaseLog: customer info is nil")
            return false }
        let hasPurchased = customerInfo.nonConsumablePurchases.contains(productIdentifier) //Todo: find alternative
        debugPrint("PurchaseLog: has purchased for \(productIdentifier) is \(hasPurchased)")
        return hasPurchased
    }
    
    func startHub(completion: (@Sendable (Bool) -> Void)? = nil) {  // { Warm Start } Only for applicationDidBecomeActive
        guard isFirstLaunch == false else {
            completion?(false)
            return }
        let networkManager = VxNetworkManager()
        networkManager.registerDevice { response, remoteConfig, error in
            VxAppsFlyerManager.shared.start()
            if error != nil {
                self.delegate?.vxHubDidFailWithError(error: error)
                completion?(false)
                return
            }
            
            completion?(true)
            self.downloadExternalAssets(from: response)
        }
    }
    
    private func requestAtt() {
        let manager = VxPermissionManager()
        manager.requestAttPermission { state in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                VxFacebookManager().fbAttFlag()
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
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            var keychainManager = VxKeychainManager()
            keychainManager.appleId = UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "")
            
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
                appleId: UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""),
                idfaStatus: VxPermissionManager().getIDFA() ?? "",
                installedApps: installedApps
            )
            self?.deviceConfig = deviceConfig
            completion()
        }
    }
}


//MARK: - Protocols
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

extension VxHub: VxReachabilityDelegate{
    public func reachabilityStatusChanged(_ userInfo: [String : Any]) {
        guard let isConnected = userInfo["isConnected"] as? Bool
        else {
            VxLogger.shared.error("Reachability status changed with invalid userInfo")
            return
        }
        
        self.isConnectedToInternet = isConnected
        self.delegate?.vxHubDidChangeNetworkStatus?(
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
        let accountId = appleIDCredential.user
        let firstName = appleIDCredential.fullName?.givenName ?? ""
        let lastName = appleIDCredential.fullName?.familyName ?? ""
        let displayName = "\(firstName) \(lastName)"
        let email = appleIDCredential.email

        VxNetworkManager().signInRequest(provider: VxSignInMethods.apple.rawValue, token: token, accountId: accountId, name: displayName, email: email) { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.appleSignInCompletion?(nil, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                VxLogger.shared.error("Sign in with Apple failed: \(error)")
                return
            }
            
            if response?.social?.status == true {
                self.appleSignInCompletion?(true, nil)
                VxLogger.shared.success("Sign in with Apple success")
            } else {
                self.appleSignInCompletion?(nil, NSError(domain: "VxHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                VxLogger.shared.error("Sign in with Apple failed")
            }
            self.appleSignInCompletion = nil
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
        return UIApplication.shared.topViewController()?.view.window ?? UIWindow()
    }
}

// Add this enum above the function
public enum VxPaywallPresentationStyle: Int {
    case present
    case push
}
