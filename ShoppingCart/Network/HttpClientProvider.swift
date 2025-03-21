//
//  HttpClientProvider.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Combine
import Foundation

import Combine
import Foundation

protocol HttpClientProtocol {
    func getProducts() async throws -> ProductsDataResponse
    func purchaseProducts(items: [PurchaseItem]) async throws -> PurchaseResponse
}

struct HttpClientProvider: HttpClientProtocol {
    let baseURL: String
    let client: APIClient

    func getProducts() async throws -> ProductsDataResponse {
        try await client.request(
            request: ProductClientAPIProvider(baseURL: baseURL,
                                              request: .getProducts)
        )
    }

    func purchaseProducts(items: [PurchaseItem]) async throws -> PurchaseResponse {
        try await client.request(request: ProductClientAPIProvider(baseURL: baseURL,
                                                                   request: .postProducts(items: items)))
    }
}
