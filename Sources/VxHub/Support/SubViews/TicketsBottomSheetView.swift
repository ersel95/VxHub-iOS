//
//  TicketsBottomSheetView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 6.02.2025.
//

import UIKit
import Combine

final class TicketsBottomSheetView: UIView {
    private let configuration: VxSupportConfiguration
    private let tickets: [String]
    private var onTicketSelected: ((String) -> Void)?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(TicketCell.self, forCellReuseIdentifier: TicketCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 51
        table.estimatedRowHeight = 51
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    init(configuration: VxSupportConfiguration, onTicketSelected: @escaping (String) -> Void) {
        self.configuration = configuration
        self.tickets = VxHub.shared.deviceInfo?.support?.categories ?? []
        self.onTicketSelected = onTicketSelected
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = configuration.ticketSheetBackgroundColor
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = configuration.ticketSheetShadowColor.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 10
        addSubview(tableView)
        setupConstraints()
        setupTableView()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TicketCell.self, forCellReuseIdentifier: TicketCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .gray.withAlphaComponent(0.3)
    }
}

extension TicketsBottomSheetView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TicketCell.identifier, for: indexPath) as? TicketCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: tickets[indexPath.row], configuration: configuration)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onTicketSelected?(tickets[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tickets.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = .zero
        }
    }
} 
