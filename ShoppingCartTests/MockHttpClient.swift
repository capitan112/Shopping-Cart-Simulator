//
//  MockHttpClient.swift
//  ShoppingCartTests
//
//  Created by Oleksiy Chebotarov on 22/03/2025.
//

import Foundation
@testable import ShoppingCart

extension LoadingState: @retroactive Equatable where T: Equatable {
    public static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        case let (.failed(lhsError), .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

extension PurchaseState: @retroactive Equatable {
    public static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.purchasing, .purchasing):
            return true
        case let (.purchased(lhsResponse), .purchased(rhsResponse)):
            return lhsResponse.message == rhsResponse.message
        case let (.failed(lhsError), .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

class MockHttpClient: HttpClientProtocol {
    var getProductsResult: Result<ProductsDataResponse, Error>?
    var purchaseProductsResult: Result<PurchaseResponse, Error>?

    func getProducts() async throws -> ProductsDataResponse {
        if let result = getProductsResult {
            switch result {
            case let .success(response):
                return response
            case let .failure(error):
                throw error
            }
        } else {
            throw NSError(domain: "MockHttpClient", code: -1, userInfo: nil)
        }
    }

    func purchaseProducts(items _: [PurchaseItem]) async throws -> PurchaseResponse {
        if let result = purchaseProductsResult {
            switch result {
            case let .success(response):
                return response
            case let .failure(error):
                throw error
            }
        } else {
            throw NSError(domain: "MockHttpClient", code: -1, userInfo: nil)
        }
    }
}
