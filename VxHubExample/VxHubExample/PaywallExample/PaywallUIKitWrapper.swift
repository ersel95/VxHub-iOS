import SwiftUI
import VxHub

struct PaywallUIKitWrapper: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: "creditcard")
                    .foregroundColor(.purple)
                Text("Paywall V3 Test")
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            VxPaywallV3View(
                configuration: VxMainPaywallV3Configuration(
                    font: .rounded,
                    heroImageName: nil,
                    backgroundColor: .white,
                    isLightMode: true,
                    headlineText: "Unlock Full Access",
                    subtitleText: "Start your free trial today",
                    featureItems: [
                        (icon: "checkmark.circle.fill", text: "Unlimited virtual try ons"),
                        (icon: "checkmark.circle.fill", text: "Ad free experience"),
                        (icon: "checkmark.circle.fill", text: "High definition renders"),
                        (icon: "checkmark.circle.fill", text: "Priority support")
                    ],
                    ratingValue: "4.8",
                    ratingCount: "150K+",
                    ctaButtonColor: UIColor(red: 71/255, green: 138/255, blue: 255/255, alpha: 1.0),
                    ctaGradientEndColor: UIColor(red: 120/255, green: 80/255, blue: 255/255, alpha: 1.0),
                    trustText: nil,
                    isCloseButtonEnabled: true,
                    closeButtonColor: .gray,
                    analyticsEvents: [.select, .purchased],
                    closeButtonDelay: 0
                ),
                onPurchaseSuccess: { _ in
                    isPresented = false
                },
                onDismiss: {
                    isPresented = false
                },
                onRestoreStateChange: { _ in },
                onRedeemCodeButtonTapped: {}
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}
