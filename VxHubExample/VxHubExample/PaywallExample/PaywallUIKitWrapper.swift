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
        let label = "[color=#FF0000]What[/color] is [url=https://stage.app.volvoxhub.com]Spam[/url] [b]Police[/b]"
        let textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        let buttonColor = UIColor(red: 71/255, green: 138/255, blue: 255/255, alpha: 1.0)
        let freeStackBorder = UIColor(red: 223/255, green: 230/255, blue: 237/255, alpha: 1.0)
        let configuration = VxMainPaywallConfiguration(
            font: .rounded,
            topImage: UIImage(named:"spam_logo")!,
            titleText: "Spam Police",
            titleImage: UIImage(named:"spam_icon")!,
            titleImageHeight: 124,
            descriptionFont: .custom("Roboto"),
            descriptionItems: [
                (image: "spam_desc_icon", text: label),
                (image: "spam_desc_icon", text: "Ad-Free Experience"),
                (image: "spam_desc_icon", text: "Premium Support 24/7Premium Support 24/7Premium Support 24/7Premium Support 24/7Premium Support 24/7Premium Support 24/7Premium Support 24/7Premium Support 24/7"),
                (image: "spam_desc_icon", text: "Cloud Sync Enabled")
            ],
            freeTrialStackBorderColor: freeStackBorder,
            mainButtonColor: buttonColor,
            backgroundColor: .white,
            backgroundImage: UIImage(named:"spam_bg"),
            isLightMode: true,
            textColor: textColor,
            layoutConfiguration: .dynamicTitle
        )
        
        let viewModel = VxMainSubscriptionViewModel(configuration: configuration, onPurchaseSuccess: {}, onDismissWithoutPurchase: {})
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
