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
        let buttonColor = UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1.0)
        let configuration = VxMainPaywallConfiguration(
            font: .system("SF Pro Rounded"),
            topImage: UIImage(named:"atom_logo")!,
            title: "ATOM AI",
            descriptionItems: [
                (image: "atom_1", text: "Unlimited Access to All Features"),
                (image: "atom_2", text: "Ad-Free Experience"),
                (image: "atom_3", text: "Premium Support 24/7"),
                (image: "atom_4", text: "Cloud Sync Enabled")
            ],
            freeTrialStackBorderColor: .systemBlue,
            subscriptionProductsBorderColor: .systemPurple,
            mainButtonColor: buttonColor,
            backgroundColor: .black,
            backgroundImage: UIImage(named:"atom_bg_2"),
            isLightMode: false,
            textColor: .white
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
