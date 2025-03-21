//
//  ProductClientAPIProvider.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Alamofire
import Foundation

enum ProductClientAPI {
    case getProducts
    case postProducts(items: [PurchaseItem])
}

struct ProductClientAPIProvider {
    let baseURL: String
    let request: ProductClientAPI
}

extension ProductClientAPIProvider: Endpoint {
    var path: String {
        switch request {
        case .getProducts: "/getAllProducts"
        case .postProducts: "/purchaseProducts"
        }
    }

    var parameters: [String: Any] {
        switch request {
        case .getProducts:
            return [:]
        case let .postProducts(items):
            return ["products": items.map { ["id": $0.id, "amount": $0.amount] }]
        }
    }

    var headers: HTTPHeaders {
        switch request {
        case .getProducts: []
        case .postProducts: ["Content-Type": "application/json; charset=utf-8"]
        }
    }

    var method: HTTPMethod {
        switch request {
        case .getProducts: .get
        case .postProducts: .post
        }
    }
}
