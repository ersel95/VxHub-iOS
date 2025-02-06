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
                    .foregroundColor(.black)
                Text("Support Test")
                    .foregroundColor(.black)
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
        let viewModel = VxSupportViewModel(configuration: config)
        let controller = VxSupportViewController(viewModel: viewModel)
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
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
