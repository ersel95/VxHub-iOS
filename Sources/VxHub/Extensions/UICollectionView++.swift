//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioğlu on 9.04.2025.
//

import UIKit

public extension UICollectionView {
    
    // MARK: - Register Cell
    public func registerCell<T: UICollectionViewCell>(cellType: T.Type) {
        let identifier = cellType.dequeuIdentifier
        register(cellType, forCellWithReuseIdentifier: identifier)
    }
    
    // MARK: - Dequeuing
    public func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: type.dequeuIdentifier, for: indexPath) as! T
    }
}
