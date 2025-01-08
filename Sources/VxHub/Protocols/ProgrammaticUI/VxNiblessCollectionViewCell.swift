//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit

open class VxNiblessCollectionViewCell: UICollectionViewCell { //TODO: - Move to VxHub

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable,
  message: "Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  public required init?(coder aDecoder: NSCoder) {
    fatalError("Loading this view Cell from a nib is unsupported in favor of initializer dependency injection.")
  }
}
