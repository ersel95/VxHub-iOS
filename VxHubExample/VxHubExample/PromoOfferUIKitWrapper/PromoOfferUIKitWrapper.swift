//
//  PromoOfferUIKitWrapper.swift
//  VxHubExample
//
//  Created by Furkan Alioglu on 12.02.2025.
//

import Foundation
import SwiftUI
import VxHub

struct PromoOfferUIKitWrapper: View {
    @State private var isPresented = false
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: "figure.ice.hockey.circle.fill")
                    .foregroundColor(.purple)
                Text("Promo Test")
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            SwiftUIPromoOfferViewController(onPurchaseSuccess: {
                isPresented = false
            }, onDismiss: {
                isPresented = false
            })
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct SwiftUIPromoOfferViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onPurchaseSuccess: () -> Void
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> PromoOfferViewController {
        let vm = PromoOfferViewModel(productToCompareIdentifier: "", onPurchaseSuccess: {}, onDismissWithoutPurchase: {})
        let controller = PromoOfferViewController(viewModel: vm, type: .v1)
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SwiftUIPromoOfferViewController
        
        init(_ parent: SwiftUIPromoOfferViewController) {
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
    
    func updateUIViewController(_ uiViewController: PromoOfferViewController, context: Context) {
    }
}
