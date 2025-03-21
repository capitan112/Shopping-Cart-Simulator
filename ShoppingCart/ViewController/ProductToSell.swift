//
//  ProductToSell.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Foundation

struct ProductToSell: Hashable {
    let id: String
    var name: String
    let price: Double
    var quantity: Int = 0
}
