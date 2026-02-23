#if canImport(UIKit)
import Foundation
import Combine
import UIKit

protocol VxStoreViewModelDelegate: AnyObject {
    func dismiss()
}

public final class VxStoreViewModel: @unchecked Sendable {
    let storeType: VxStoreType
    let v1Configuration: VxStoreV1Configuration?
    let v2Configuration: VxStoreV2Configuration?
    var cellViewModels: [VxStoreDataSourceModel] = []
    private(set) var isDummyMode: Bool = false

    var selectedProductPublisher = CurrentValueSubject<VxStoreDataSourceModel?, Never>(nil)
    let loadingStatePublisher = CurrentValueSubject<Bool, Never>(false)
    let purchasedProductPublisher = PassthroughSubject<String, Never>()

    var onPurchaseSuccess: (@Sendable (String?) -> Void)?
    var onDismissWithoutPurchase: (@Sendable () -> Void)?

    weak var delegate: VxStoreViewModelDelegate?

    public init(
        v1Configuration: VxStoreV1Configuration? = nil,
        v2Configuration: VxStoreV2Configuration? = nil,
        onPurchaseSuccess: @escaping @Sendable (String?) -> Void,
        onDismissWithoutPurchase: @escaping @Sendable () -> Void
    ) {
        if let v1Config = v1Configuration {
            self.storeType = .v1
            self.v1Configuration = v1Config
            self.v2Configuration = nil
            let util = VxStoreUtil(
                hideAlreadyPurchased: v1Config.hideAlreadyPurchasedNonConsumables,
                font: v1Config.font,
                isLightMode: v1Config.isLightMode,
                textColor: v1Config.textColor,
                badges: v1Config.productBadges,
                images: v1Config.productImages,
                defaultImage: v1Config.defaultProductImage,
                dummyProducts: v1Config.dummyProducts
            )
            self.cellViewModels = util.storeProducts
            self.isDummyMode = util.isDummyMode
        } else if let v2Config = v2Configuration {
            self.storeType = .v2
            self.v1Configuration = nil
            self.v2Configuration = v2Config
            let util = VxStoreUtil(
                hideAlreadyPurchased: v2Config.hideAlreadyPurchasedNonConsumables,
                font: v2Config.font,
                isLightMode: v2Config.isLightMode,
                textColor: v2Config.textColor,
                badges: v2Config.productBadges,
                images: v2Config.productImages,
                defaultImage: v2Config.defaultProductImage,
                dummyProducts: v2Config.dummyProducts
            )
            self.cellViewModels = util.storeProducts
            self.isDummyMode = util.isDummyMode
        } else {
            self.storeType = .v1
            self.v1Configuration = nil
            self.v2Configuration = nil
        }

        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismissWithoutPurchase = onDismissWithoutPurchase

        if let first = cellViewModels.first {
            let purchaseMode = v1Configuration?.purchaseMode ?? v2Configuration?.purchaseMode ?? .perCard
            if purchaseMode == .selectAndBuy {
                handleProductSelection(identifier: first.identifier)
            }
        }
    }

    internal func dismiss() {
        self.delegate?.dismiss()
    }

    func handleProductSelection(identifier: String) {
        guard let _ = cellViewModels.first(where: { $0.identifier == identifier }) else { return }

        cellViewModels.indices.forEach { index in
            cellViewModels[index].isSelected = cellViewModels[index].identifier == identifier
        }

        let analyticsEvents = v1Configuration?.analyticsEvents ?? v2Configuration?.analyticsEvents
        if analyticsEvents?.contains(.select) == true {
            var eventProperties: [AnyHashable: Any] = ["product_identifier": identifier]
            eventProperties["page_name"] = "store"
            VxHub.shared.logAmplitudeEvent(eventName: AnalyticEvents.select.formattedName, properties: eventProperties)
        }

        selectedProductPublisher.send(cellViewModels.first(where: { $0.identifier == identifier }))
    }

    func purchaseAction(identifier: String? = nil) {
        // Dummy mode — no real purchase
        if isDummyMode {
            let productId = identifier ?? selectedProductPublisher.value?.identifier
            VxLogger.shared.warning("[VxStore] Dummy mode — purchase simulated for: \(productId ?? "nil")")
            if let productId {
                purchasedProductPublisher.send(productId)
                onPurchaseSuccess?(productId)
            }
            return
        }

        if VxHub.shared.isConnectedToInternet == false {
            DispatchQueue.main.async {
                guard let topVc = UIApplication.shared.topViewController() else { return }
                VxAlertManager.shared.present(
                    title: VxLocalizables.InternetConnection.checkYourInternetConnection,
                    message: VxLocalizables.InternetConnection.checkYourInternetConnectionDescription,
                    buttonTitle: VxLocalizables.InternetConnection.checkYourInternetConnectionButtonLabel,
                    from: topVc)
            }
            return
        }

        guard self.loadingStatePublisher.value == false else { return }

        let productIdentifier: String?
        if let identifier = identifier {
            productIdentifier = identifier
        } else {
            productIdentifier = selectedProductPublisher.value?.identifier
        }

        guard let productId = productIdentifier,
              let revenueCatProduct = VxHub.shared.revenueCatProducts.first(where: { $0.storeProduct.productIdentifier == productId }) else { return }

        self.loadingStatePublisher.send(true)
        VxHub.shared.purchase(revenueCatProduct.storeProduct) { [weak self] success in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if success {
                    if revenueCatProduct.storeProduct.productType == .nonConsumable {
                        VxHub.shared.saveNonConsumablePurchase(productIdentifier: productId)
                    }
                    self.purchasedProductPublisher.send(productId)
                    self.onPurchaseSuccess?(productId)
                    self.loadingStatePublisher.send(false)
                } else {
                    self.loadingStatePublisher.send(false)
                }
            }
        }
    }
}
#endif
