import Foundation
import UIKit.UIImage
import Combine

protocol PromoOfferViewModelDelegate: AnyObject {
    nonisolated func promoOfferDidClose()
    nonisolated func promoOfferDidClaim()
}

final public class PromoOfferViewModel: @unchecked Sendable {
    
    // MARK: - Properties
    weak var delegate: PromoOfferViewModelDelegate?
    var categories: [SpecialOfferCategories] = SpecialOfferCategories.allCases
    let loadingStatePublisher = CurrentValueSubject<Bool, Never>(false)
    var product: SubData?
    var productToCompare: SubData?
    
    var onPurchaseSuccess: (@Sendable() -> Void)?
    var onDismissWithoutPurchase: (@Sendable() -> Void)?
        
    public init(
        productIdentifier: String? = nil,
        productToCompareIdentifier: String?,
        onPurchaseSuccess: @escaping @Sendable () -> Void,
        onDismissWithoutPurchase: @escaping @Sendable () -> Void) {
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismissWithoutPurchase = onDismissWithoutPurchase
        let paywallUtil = VxPaywallUtil()
        if let productIdentifier,
           let product = paywallUtil.storeProducts[.all]?.first(where: {$0.identifier == productIdentifier}) {
            self.product = product
        } else if let product = paywallUtil.storeProducts[.welcomeOffer]?.first {
            self.product = product
        } else {
            let data = paywallUtil.storeProducts[.all] ?? [SubData]()
            self.product = data.first
        }
            
        if let productToCompareIdentifier {
            productToCompare = paywallUtil.storeProducts[.all]?.first(where: {$0.identifier == productToCompareIdentifier })
        }else{
            productToCompare = paywallUtil.storeProducts[.all]?.first
        }
    }
    
    // MARK: - Public Methods
    func dismiss() {
        delegate?.promoOfferDidClose()
    }
    
    func claimOffer() {
        delegate?.promoOfferDidClaim()
    }
    
    func purchaseAction() {
        guard self.loadingStatePublisher.value == false else { return }
        guard let revenueCatProduct = VxHub.shared.revenueCatProducts.first(where: {$0.storeProduct.productIdentifier == self.product?.identifier }) else {
            return
        }
        self.loadingStatePublisher.send(true)

        VxHub.shared.purchase(revenueCatProduct.storeProduct) { [weak self] success in
            if success {
                self?.onPurchaseSuccess?()
                self?.loadingStatePublisher.send(false)
            }else{
                self?.loadingStatePublisher.send(false)
            }
        }
    }
    
    func restoreAction() {
        guard self.loadingStatePublisher.value == false else { return }
        self.loadingStatePublisher.send(true)
        VxHub.shared.restorePurchases { hasActiveSubscription, hasActiveNonConsumable, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.loadingStatePublisher.send(false)
                if hasActiveSubscription == true {
                    self.onPurchaseSuccess?()
                } else {
                    if let topVc = UIApplication.shared.topViewController() {
                        VxAlertManager.shared.present(
                            title: VxLocalizables.Subscription.nothingToRestore,
                            message: VxLocalizables.Subscription.nothingToRestoreDescription,
                            buttonTitle: VxLocalizables.Subscription.nothingToRestoreButtonLabel,
                            from: topVc)
                    }
                }
            }
        }
    }
    
    var calculateDiscountPercentage : String {
        guard let product else { return "0" }
        guard let nonDiscountedProduct = productToCompare else { return "0" }
                
        guard let discountedPrice = product.price else { return "0" }
        guard let nonDiscountedPrice = nonDiscountedProduct.price else { return "0" }
        
        let discount = (nonDiscountedPrice - discountedPrice) / nonDiscountedPrice * 100
        let discountDouble = NSDecimalNumber(decimal: discount).doubleValue
        
        if discountDouble < 0 {
            debugPrint("Warning: New price is higher than old price, returning 0")
            return "0"
        }
        let discountInt = Int(discountDouble.rounded())
        return String(format: "%d%%", discountInt)
    }
    
}

enum SpecialOfferCategories: CaseIterable {
    case scam, travel, education, community, shopping, bet, ads, lifestyle, finance, network
    
    var image: UIImage {
        switch self {
        case .scam: return UIImage(named: "special_offer_scam") ?? UIImage()
        case .travel: return UIImage(named: "special_offer_travel") ?? UIImage()
        case .education: return UIImage(named: "special_offer_education") ?? UIImage()
        case .community: return UIImage(named: "special_offer_community") ?? UIImage()
        case .shopping: return UIImage(named: "special_offer_shopping") ?? UIImage()
        case .bet: return UIImage(named: "special_offer_bet") ?? UIImage()
        case .ads: return UIImage(named: "special_offer_ads") ?? UIImage()
        case .lifestyle: return UIImage(named: "special_offer_lifestyle") ?? UIImage()
        case .finance: return UIImage(named: "special_offer_finance") ?? UIImage()
        case .network: return UIImage(named:"special_offer_network") ?? UIImage()
        }
    }
    
    var title: String {
        switch self {
        case .scam: return "PromoOffer_Scam".localize()
        case .travel: return "PromoOffer_Travel".localize()
        case .education: return "PromoOffer_Education".localize()
        case .community: return "PromoOffer_Community".localize()
        case .shopping: return "PromoOffer_Shopping".localize()
        case .bet: return "PromoOffer_Bet".localize()
        case .ads: return "PromoOffer_Ads".localize()
        case .lifestyle: return "PromoOffer_Lifestyle".localize()
        case .finance: return "PromoOffer_Finance".localize()
        case .network: return "PromoOffer_Network".localize()
        }
    }
    
    var gradientColors: (UIColor, UIColor) {
        switch self {
        case .scam: return (UIColor.colorConverter("E84F66", alpha: 1.0), UIColor.colorConverter("A4293A", alpha: 1.0))
        case .travel: return (UIColor.colorConverter("E453F5", alpha: 1.0), UIColor.colorConverter("AD25BE", alpha: 1.0))
        case .education: return (UIColor.colorConverter("82C437", alpha: 1.0), UIColor.colorConverter("436B22", alpha: 1.0))
        case .community: return (UIColor.colorConverter("EED745", alpha: 1.0), UIColor.colorConverter("DFC836", alpha: 1.0))
        case .shopping: return (UIColor.colorConverter("1BBBB7", alpha: 1.0), UIColor.colorConverter("147C75", alpha: 1.0))
        case .bet: return (UIColor.colorConverter("9B51F1", alpha: 1.0), UIColor.colorConverter("5D1AAA", alpha: 1.0))
        case .ads: return (UIColor.colorConverter("F69956", alpha: 1.0), UIColor.colorConverter("BA5B17", alpha: 1.0))
        case .lifestyle: return (UIColor.colorConverter("C43774", alpha: 1.0), UIColor.colorConverter("A2295F", alpha: 1.0))
        case .finance: return (UIColor.colorConverter("375AC4", alpha: 1.0), UIColor.colorConverter("2D388A", alpha: 1.0))
        case .network: return (UIColor.colorConverter("3789C4", alpha: 1.0), UIColor.colorConverter("3473B1", alpha: 1.0))
        }
    }
}

