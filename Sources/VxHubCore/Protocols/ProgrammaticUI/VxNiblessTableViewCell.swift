#if canImport(UIKit)
//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit

open class VxNiblessTableViewCell: UITableViewCell {

  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  // MARK: - Restricted Init
  @available(*, unavailable,
  message: "Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  public required init?(coder: NSCoder) {
    fatalError("Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  }
}
#endif
