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
    
    var onPurchaseSuccess: (@Sendable() -> Void)?
    var onDismissWithoutPurchase: (@Sendable() -> Void)?
        
    public init(
        onPurchaseSuccess: @escaping @Sendable () -> Void,
        onDismissWithoutPurchase: @escaping @Sendable () -> Void) {
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismissWithoutPurchase = onDismissWithoutPurchase
        let paywallUtil = VxPaywallUtil()
        let data = paywallUtil.storeProducts[.promoOffer] ?? [SubData]()
        self.product = data.first
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
        guard let revenueCatProduct = VxHub.shared.revenueCatProducts.first(where: {$0.storeProduct.productIdentifier == self.product?.identifier }) else { return }
        self.loadingStatePublisher.send(true)
        
        VxHub.shared.purchase(revenueCatProduct.storeProduct) { [weak self] success in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if success {
                    VxHub.shared.start {
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.onPurchaseSuccess?()
                            self.loadingStatePublisher.send(false)
                        }
                    }
                }else{
                    self.loadingStatePublisher.send(false)
                }
            }
        }
    }
    
    func restoreAction() {
        self.loadingStatePublisher.send(true)
        VxHub.shared.restorePurchases { success in
            if success {
                VxHub.shared.start {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.loadingStatePublisher.send(false)
                        self.onPurchaseSuccess?()
                    }
                }
            }else{
                self.loadingStatePublisher.send(false)
            }
        }
    }
    
    func oldPriceString() -> String {
        let paywallUtil = VxPaywallUtil()
        let currentPeriod = self.product?.subPeriod
        
        if let mainPaywallProducts = paywallUtil.storeProducts[.mainPaywall],
           let matchingProduct = mainPaywallProducts.first(where: { $0.subPeriod == currentPeriod }) {
            return matchingProduct.localizedPrice ?? "???"
        }
        
        if let welcomeOfferProducts = paywallUtil.storeProducts[.welcomeOffer],
           let matchingProduct = welcomeOfferProducts.first(where: { $0.subPeriod == currentPeriod }) {
            return matchingProduct.localizedPrice ?? "???"
        }
        
        return "???"
    }
    
    func newPriceString() -> String {
        return self.product?.localizedPrice ?? "???"
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

