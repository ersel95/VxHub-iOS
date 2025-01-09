//
//  File.swift
//  VxHub
//
//  Created by furkan on 9.01.2025.
//

import UIKit

public protocol Dequeuable {
  static var dequeuIdentifier: String { get }
}

extension Dequeuable where Self: UIView {
  public static var dequeuIdentifier: String {
    return String(describing: self)
  }
}

extension UITableViewCell: Dequeuable { }

extension UICollectionViewCell: Dequeuable { }
