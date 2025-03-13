//
//  SupportUIKitWrapper.swift
//  VxHubExample
//
//  Created by Habip Yesilyurt on 5.02.2025.
//

import SwiftUI
import VxHub

struct SupportUIKitWrapper: View {
    @State private var isPresented = false
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundColor(.primary)
                Text("Support Test")
                    .foregroundColor(.primary)
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            SupportViewController()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct SupportViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let config = VxSupportConfiguration()
        let viewModel = VxSupportViewModel(appController: UIViewController(), configuration: config)
        let controller = VxSupportViewController(viewModel: viewModel)
        
        let dismissButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.dismissController)
        )
        dismissButton.tintColor = .label
        controller.navigationItem.leftBarButtonItem = dismissButton
        
        let navigationController = UINavigationController()
        navigationController.setViewControllers([controller], animated: false)
        return navigationController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SupportViewController
        
        init(_ parent: SupportViewController) {
            self.parent = parent
        }
        
        @objc func dismissController() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
