//
//  UITableViewCell+ReuseIdentifier.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 21/03/2025.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
