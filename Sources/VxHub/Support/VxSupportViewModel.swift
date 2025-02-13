//
//  VxSupportViewModel.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit
import Combine

public enum SupportState: Sendable {
    case detail
    case list
}

public final class VxSupportViewModel: @unchecked Sendable {
    let configuration: VxSupportConfiguration
    let loadingStatePublisher = CurrentValueSubject<Bool, Never>(false)
    let loadingStateTicketMessagesPublisher = CurrentValueSubject<Bool, Never>(false)
    let loadingStateCreateMessagePublisher = CurrentValueSubject<Bool, Never>(false)
    let isPullToRefreshLoading = CurrentValueSubject<Bool, Never>(false)
    
    @Published private(set) var tickets: [VxGetTicketsResponse] = []
    @Published private(set) var currentTicket: VxCreateTicketSuccessResponse?
    @Published var ticketMessages: VxGetTicketMessagesResponse?
    @Published private(set) var ticketNewMessage: Message?
    @Published var isNewTicket: Bool = false
    
    var onStateChange: (@Sendable(SupportState) -> Void)?
    
    public init(
        configuration: VxSupportConfiguration,
        onStateChange: (@Sendable(SupportState) -> Void)?
    ) {
        self.configuration = configuration
        self.onStateChange = onStateChange
        fetchTickets()
    }
    
    public func fetchTickets(isPullToRefresh: Bool = false) {
        let publisher = isPullToRefresh ? isPullToRefreshLoading : loadingStatePublisher
        publisher.send(true)
        
        let networkManager = VxNetworkManager()
        networkManager.getTickets { [weak self] response in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if isPullToRefresh {
                    self.isPullToRefreshLoading.send(false)
                } else {
                    self.loadingStatePublisher.send(false)
                }
                
                if let tickets = response {
                    self.tickets = tickets
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
        loadingStateTicketMessagesPublisher.send(true)
        
        networkManager.getTicketMessagesById(ticketId: ticketId) { [weak self] response in
            DispatchQueue.main.async {
                self?.loadingStateTicketMessagesPublisher.send(false)
                if let messages = response {
                    self?.ticketMessages = messages
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func createNewMessage(ticketId: String, message: String, completion: @escaping @Sendable (Bool) -> Void) {
        let networkManager = VxNetworkManager()
        loadingStateCreateMessagePublisher.send(true)
        
        networkManager.createNewMessage(ticketId: ticketId, message: message) { [weak self] newMessage in
            if let newMessage = newMessage {
                if let currentTicketMessages = self?.ticketMessages {
                    var updatedMessages = currentTicketMessages.messages
                    updatedMessages.insert(newMessage, at: 0)
                    
                    let updatedTicketMessages = VxGetTicketMessagesResponse(
                        id: currentTicketMessages.id,
                        category: currentTicketMessages.category,
                        projectID: currentTicketMessages.projectID,
                        deviceID: currentTicketMessages.deviceID,
                        vid: currentTicketMessages.vid,
                        email: currentTicketMessages.email,
                        name: currentTicketMessages.name,
                        status: currentTicketMessages.status,
                        state: currentTicketMessages.state,
                        source: currentTicketMessages.source,
                        createdAt: currentTicketMessages.createdAt,
                        updatedAt: currentTicketMessages.updatedAt,
                        messages: updatedMessages
                    )
                    
                    self?.ticketMessages = updatedTicketMessages
                }
                
                self?.ticketNewMessage = newMessage
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func clearTicketMessages() {
        ticketMessages = nil
    }
}
