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
            PaywallViewController()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct PaywallViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> VxMainSubscriptionViewController {
        let configuration = VxMainPaywallConfiguration(
            baseFont: ".SFUI-Regular",
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
            mainButtonColor: .systemGreen,
            backgroundColor: .systemBackground,
            backgroundImage: UIImage(named:"atom_bg_1")
        )
        
        let viewModel = VxMainSubscriptionViewModel(configuration: configuration)
        let controller = VxMainSubscriptionViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .overFullScreen
        controller.navigationController?.isNavigationBarHidden = true

        return controller
    }
    
    func updateUIViewController(_ uiViewController: VxMainSubscriptionViewController, context: Context) {
    }
}
