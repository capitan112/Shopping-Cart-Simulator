//
//  HttpClientFactory.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Foundation

protocol HttpClientFactoryProtocol {
    var baseURL: String { get }
    var apiClient: APIClient { get }
    func getProductClient() -> HttpClientProtocol
}

struct HttpClientFactory: HttpClientFactoryProtocol {
    let baseURL: String
    let apiClient = APIClient()

    func getProductClient() -> HttpClientProtocol {
        HttpClientProvider(baseURL: baseURL, client: apiClient)
    }
}
