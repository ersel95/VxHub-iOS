//
//  File.swift
//  VxHub
//
//  Created by furkan on 9.01.2025.
//

import UIKit

extension UITableView {

  // MARK: - Register Cell
  public func registerCell<T: UITableViewCell>(cellType: T.Type) {
    let identifier = cellType.dequeuIdentifier
    register(cellType, forCellReuseIdentifier: identifier)
  }

  // MARK: - Dequeing
  public func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
    return self.dequeueReusableCell(withIdentifier: type.dequeuIdentifier, for: indexPath) as! T
  }
    
    public func pin(to view: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        ])
    }
}
