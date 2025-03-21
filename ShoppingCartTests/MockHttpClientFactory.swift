//
//  MockHttpClientFactory.swift
//  ShoppingCartTests
//
//  Created by Oleksiy Chebotarov on 22/03/2025.
//

import Foundation
@testable import ShoppingCart

class MockHttpClientFactory: HttpClientFactoryProtocol {
    var baseURL: String = ""
    var apiClient: APIClient = .init()
    let client: HttpClientProtocol

    init(client: HttpClientProtocol) {
        self.client = client
    }

    func getProductClient() -> HttpClientProtocol {
        return client
    }
}
