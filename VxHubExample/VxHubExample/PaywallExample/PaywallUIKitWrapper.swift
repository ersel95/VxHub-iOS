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
                Text("Paywall Test")
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            PaywallViewController(onPurchaseSuccess: {
                isPresented = false
            }, onDismiss: {
                isPresented = false
            })
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct PaywallViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onPurchaseSuccess: () -> Void
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> VxMainSubscriptionViewController {
        let label = "[color=#FF0000]{{value_1}}[/color] is [url=https://stage.app.volvoxhub.com]{{value_2}}[/url] [b]Police[/b]"
            .replaceValues(["Furkan", "Volvox"])
        let textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        let buttonColor = UIColor(red: 71/255, green: 138/255, blue: 255/255, alpha: 1.0)
        let config = VxMainPaywallConfiguration(
            appLogoImageName: "spam_logo",
            appNameImageName: "spam_icon",
            descriptionFont: .custom("Roboto"),
            descriptionItems: [
                    (image: "spam_desc_icon", text: label),
                    (image: "spam_desc_icon", text: "Ad-Free Experience"),
                    (image: "spam_desc_icon", text: "Premium Support 24/7"),
                    (image: "spam_desc_icon", text: "Cloud Sync Enabled")
                ],
            mainButtonColor: buttonColor,
            backgroundColor: .white,
            backgroundImageName: "spam_bg",
            isLightMode: true,
            textColor: textColor
        )
        let viewModel = VxMainSubscriptionViewModel(configuration: config, onPurchaseSuccess: {}, onDismissWithoutPurchase: {})
        let controller = VxMainSubscriptionViewController(
            viewModel: viewModel)
        controller.modalPresentationStyle = .overFullScreen
        controller.navigationController?.isNavigationBarHidden = true
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: PaywallViewController
        
        init(_ parent: PaywallViewController) {
            self.parent = parent
        }
        
        func onPurchaseComplete(didSucceed: Bool, error: String?) {
            if didSucceed {
                parent.onPurchaseSuccess()
            }
        }
        
        func onRestorePurchases(didSucceed: Bool, error: String?) {
            if didSucceed {
                parent.onPurchaseSuccess()
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: VxMainSubscriptionViewController, context: Context) {
    }
}
