//
//  DataResponse.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Foundation

struct ProductsDataResponse: Decodable {
    let data: DataClass
}

// MARK: - DataClass

struct DataClass: Decodable {
    let products: [Product]
    let prices: [Price]
}

// MARK: - Price

struct Price: Decodable {
    let id: String
    let price: Double
}

// MARK: - Product

struct Product: Decodable {
    let id, name: String
}

struct PurchaseRequest: Encodable {
    let products: [PurchaseItem]
}

struct PurchaseItem: Encodable {
    let id: String
    let amount: Int
}

public struct PurchaseResponse: Decodable, Equatable {
    let message: String
}
