//
//  VxSupportViewModel.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit
import Combine

public final class VxSupportViewModel: @unchecked Sendable {
    let configuration: VxSupportConfiguration
    let loadingStatePublisher = CurrentValueSubject<Bool, Never>(false)
    var isBottomSheetPresented = false
    
    @Published private(set) var tickets: [VxGetTicketsResponse] = []
    @Published private(set) var currentTicket: VxCreateTicketSuccessResponse?
    @Published private(set) var ticketMessages: VxGetTicketMessagesResponse?
    
    public init(configuration: VxSupportConfiguration) {
        self.configuration = configuration
        fetchTickets()
    }
    
    private func fetchTickets() {
        let networkManager = VxNetworkManager()
        loadingStatePublisher.send(true)
        
        networkManager.getTickets { [weak self] response in
            DispatchQueue.main.async {
                self?.loadingStatePublisher.send(false)
                if let tickets = response {
                    self?.tickets = tickets
                }
            }
        }
    }
    
    func createNewTicket(category: String, message: String, completion: @escaping @Sendable (Bool) -> Void) {
        let networkManager = VxNetworkManager()
        loadingStatePublisher.send(true)
        
        networkManager.createNewTicket(category: category, message: message) { [weak self] response in
            DispatchQueue.main.async {
                self?.loadingStatePublisher.send(false)
                if let response = response, response.state == "NEW" {
                    self?.currentTicket = response
                    completion(true)
                }
            }
        }
    }
    
    func getTicketMessagesById(ticketId: String, completion: @escaping @Sendable (Bool) -> Void) {
        let networkManager = VxNetworkManager()
        loadingStatePublisher.send(true)
        
        networkManager.getTicketMessagesById(ticketId: ticketId) { [weak self] response in
            DispatchQueue.main.async {
                self?.loadingStatePublisher.send(false)
                if let messages = response {
                    self?.ticketMessages = messages
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
