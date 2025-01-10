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
        }
    }
}

struct PaywallViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> VxMainSubscriptionViewController {
        // Create test configuration
        let configuration = VxMainPaywallConfiguration(
            topImage: UIImage(systemName: "star.circle.fill")!,
            title: "Premium Features",
            titleFont: .systemFont(ofSize: 28, weight: .heavy),
            descriptionItems: [
                (image: "checkmark.circle.fill", text: "Unlimited Access to All Features"),
                (image: "checkmark.circle.fill", text: "Ad-Free Experience"),
                (image: "checkmark.circle.fill", text: "Premium Support 24/7"),
                (image: "checkmark.circle.fill", text: "Cloud Sync Enabled")
            ],
            descriptionItemFont: .systemFont(ofSize: 18, weight: .medium),
            freeTrialStackBorderColor: .systemBlue,
            subscriptionProductsBorderColor: .systemPurple,
            mainButtonColor: .systemGreen,
            mainButtonFont: .systemFont(ofSize: 20, weight: .bold),
            backgroundColor: .systemBackground
        )
        
        let viewModel = VxMainSubscriptionViewModel(configuration: configuration)
        let controller = VxMainSubscriptionViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VxMainSubscriptionViewController, context: Context) {
        // Updates can be handled here if needed
    }
}
