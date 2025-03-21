//
//  ShoppingCartTests.swift
//  ShoppingCartTests
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Foundation
@testable import ShoppingCart
import XCTest

final class ShoppingCartTests: XCTestCase {
    var viewModel: ViewModel!
    var mockHttpClient: MockHttpClient!
    var mockHttpClientFactory: MockHttpClientFactory!

    override func setUpWithError() throws {
        mockHttpClient = MockHttpClient()
        mockHttpClientFactory = MockHttpClientFactory(client: mockHttpClient)
        viewModel = ViewModel(networkClientFactory: mockHttpClientFactory)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockHttpClient = nil
        mockHttpClientFactory = nil
    }

    func testFetchRequestSuccess() async {
        // Arrange
        let mockProductsResponse = ProductsDataResponse(
            data: DataClass(
                products: [Product(id: "1", name: "Product 1")],
                prices: [Price(id: "1", price: 10.0)]
            )
        )
        mockHttpClient.getProductsResult = .success(mockProductsResponse)

        // Act
        do {
            try await viewModel.fetchRequest()
        } catch {
            XCTFail("fetchRequest should not throw an error")
        }

        // Assert
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.name, "Product 1")
        XCTAssertEqual(viewModel.loadingState, .loaded(viewModel.products))
    }

    func testFetchRequestFailure() async {
        // Arrange
        let mockError = NSError(domain: "TestError", code: -1, userInfo: nil)
        mockHttpClient.getProductsResult = .failure(mockError)

        // Act
        do {
            try await viewModel.fetchRequest()
            // Assert
            XCTAssertEqual(viewModel.loadingState, .failed(mockError))
        } catch {
            XCTFail("fetchRequest should throw an error")
        }
    }

    func testPurchaseProductsSuccess() async {
        // Arrange
        let mockPurchaseResponse = PurchaseResponse(message: "Success")
        mockHttpClient.purchaseProductsResult = .success(mockPurchaseResponse)

        viewModel.updateQuantity(for: "1", newValue: 2)

        // Act
        do {
            try await viewModel.purchaseProducts()
        } catch {
            XCTFail("purchaseProducts should not throw an error")
        }

        // Assert
        XCTAssertEqual(viewModel.purchaseState, .purchased(mockPurchaseResponse))
    }

    func testPurchaseProductsFailure() async {
        // Arrange
        let mockError = NSError(domain: "TestError", code: -1, userInfo: nil)
        mockHttpClient.purchaseProductsResult = .failure(mockError)

        // Act
        do {
            try await viewModel.purchaseProducts()
            XCTFail("purchaseProducts should throw an error")
        } catch {
            // Assert
            XCTAssertEqual(viewModel.purchaseState, .failed(mockError))
        }
    }

    func testCalculateTotalSum() {
        // Arrange
        let product1 = ProductToSell(id: "1", name: "Product 1", price: 10.0)
        let product2 = ProductToSell(id: "2", name: "Product 2", price: 20.0)
        viewModel.products = [product1, product2]
        viewModel.updateQuantity(for: "1", newValue: 2)
        viewModel.updateQuantity(for: "2", newValue: 1)

        // Act
        let totalSum = viewModel.calculateTotalSum()

        // Assert
        XCTAssertEqual(totalSum, 40.0, "Total sum should be 40.0")
    }

    func testClearCart() {
        // Arrange
        let product1 = ProductToSell(id: "1", name: "Product 1", price: 10.0)
        viewModel.products = [product1]
        viewModel.updateQuantity(for: "1", newValue: 2)

        // Assert
        XCTAssertFalse(viewModel.isCartEmpty, "Cart should not be empty before clearing")

        // Act
        viewModel.clearCart()

        // Assert
        XCTAssertTrue(viewModel.isCartEmpty, "Cart should be empty after clearing")
        XCTAssertEqual(viewModel.products.count, 0, "Product list should be empty")
        XCTAssertEqual(viewModel.quantities.count, 0, "Quantities should be empty")
    }

    func testIsCartEmpty() {
        // Arrange & Act
        XCTAssertTrue(viewModel.isCartEmpty, "Cart should be empty initially")

        let product1 = ProductToSell(id: "1", name: "Product 1", price: 10.0)
        viewModel.products = [product1]

        // Assert: Cart is still empty because no quantity is assigned yet
        XCTAssertTrue(viewModel.isCartEmpty, "Cart should still be considered empty (no quantity assigned)")

        // Act: Update quantity for the product
        viewModel.updateQuantity(for: "1", newValue: 1)

        // Assert: Cart is not empty now
        XCTAssertFalse(viewModel.isCartEmpty, "Cart should not be empty after adding a product quantity")
    }

    func testIsBuyButtonEnable() {
        // Arrange
        let product1 = ProductToSell(id: "1", name: "Product 1", price: 10.0)
        viewModel.products = [product1]

        // Assert: Buy button should be disabled when no quantity is assigned
        XCTAssertFalse(viewModel.isBuyButtonEnable, "Buy button should be disabled when no quantity is assigned")

        // Act: Update quantity for the product
        viewModel.updateQuantity(for: "1", newValue: 1)

        // Assert: Buy button should be enabled now
        XCTAssertTrue(viewModel.isBuyButtonEnable, "Buy button should be enabled when a product quantity is set")
    }
}
