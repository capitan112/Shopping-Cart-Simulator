//
//  File.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//
import Foundation

enum LoadingState<T> {
    case initial
    case loading
    case loaded(T)
    case failed(Error)
}

typealias ProductLoadingState = LoadingState<[ProductToSell]>

enum PurchaseState {
    case initial
    case purchasing
    case purchased(PurchaseResponse)
    case failed(Error)
}

protocol ViewModelProtocol: AnyObject {
    var products: [ProductToSell] { get }
    var isCartEmpty: Bool { get }
    var isBuyButtonEnable: Bool { get }
    var onStateChange: ((ProductLoadingState) -> Void)? { get set }
    var onPurchaseStateChange: ((PurchaseState) -> Void)? { get set }
    func updateQuantity(for productId: String, newValue: Int)
    func getQuantity(for productId: String) -> Int
    func calculateTotalSum() -> Double
    func fetchRequest()
    func purchaseProducts()
    func clearCart()
}

class ViewModel: ViewModelProtocol {
    private let client: HttpClientProtocol
    private var originalProducts: [ProductToSell] = []
    var products: [ProductToSell] = []
    var quantities: [String: Int] = [:]
    var isCartEmpty: Bool {
        quantities.isEmpty || quantities.allSatisfy { $0.value == 0 }
    }

    var isBuyButtonEnable: Bool {
        calculateTotalSum() > 0
    }

    private(set) var loadingState: ProductLoadingState = .initial {
        didSet {
            onStateChange?(loadingState)
        }
    }

    private(set) var purchaseState: PurchaseState = .initial {
        didSet {
            onPurchaseStateChange?(purchaseState)
        }
    }

    var onStateChange: ((ProductLoadingState) -> Void)?
    var onPurchaseStateChange: ((PurchaseState) -> Void)?

    init(networkClientFactory: HttpClientFactoryProtocol) {
        client = networkClientFactory.getProductClient()
    }

    func updateQuantity(for productId: String, newValue: Int) {
        quantities[productId] = newValue
    }

    func getQuantity(for productId: String) -> Int {
        return quantities[productId] ?? 0
    }

    func calculateTotalSum() -> Double {
        products.reduce(0.0) { sum, product in
            let quantity = quantities[product.id] ?? 0
            return sum + (product.price * Double(quantity))
        }
    }

    func fetchRequest() {
        loadingState = .loading

        Task {
            do {
                let result = try await client.getProducts()
                let products = mapProducts(from: result)
                self.products = products
                originalProducts = products
                loadingState = .loaded(products)
            } catch {
                loadingState = .failed(error)
            }
        }
    }

    private func mapProducts(from result: ProductsDataResponse) -> [ProductToSell] {
        var productsDict = result.data.prices.reduce(into: [String: ProductToSell]()) { dict, priceItem in
            dict[priceItem.id] = ProductToSell(id: priceItem.id, name: "#nomane", price: priceItem.price)
        }

        for productItem in result.data.products {
            if var productToSell = productsDict[productItem.id] {
                productToSell.name = productItem.name
                productsDict[productItem.id] = productToSell
            }
        }

        return Array(productsDict.values)
    }

    func purchaseProducts() {
        purchaseState = .purchasing

        Task {
            do {
                let items = createPurchaseItems()
                let response = try await client.purchaseProducts(items: items)
                purchaseState = .purchased(response)
            } catch {
                purchaseState = .failed(error)
                throw error
            }
        }
    }

    private func createPurchaseItems() -> [PurchaseItem] {
        return products.compactMap { product in
            if let quantity = quantities[product.id], quantity > 0 {
                return PurchaseItem(id: product.id, amount: quantity)
            }
            return nil
        }
    }

    func clearCart() {
        products = originalProducts
        quantities = [:]
    }
}
