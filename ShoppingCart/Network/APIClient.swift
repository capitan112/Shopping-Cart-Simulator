//
//  APIClient.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Alamofire
import Combine
import Foundation

enum NetworkError: Error {
    case badURL
    case invalidStatusCode(Int)
    case invalidResponse
}

struct APIClient {
    static var successRequst = false
    func request<T: Decodable>(request: Endpoint) async throws -> T {
        let data: Data

        switch request.method {
        case .get:
            try await Task.sleep(nanoseconds: 1_500_000_000)
            let jsonString = """
            {
              "data": {
                   "products": [
                     { "id": "7aa080fd-aafc-4cd7-9d26-030457708297", "name": "Wheat Bread" },
                     { "id": "05313b70-ffc8-40c0-958c-46f595b75ea9", "name": "Organic Milk" },
                     { "id": "d3eb4223-5104-426c-a456-5f5650b53e99", "name": "Free-Range Eggs" }
                   ],
                   "prices": [
                     { "id": "05313b70-ffc8-40c0-958c-46f595b75ea9", "price": 0.94 },
                     { "id": "d3eb4223-5104-426c-a456-5f5650b53e99", "price": 2.45 },
                     { "id": "7aa080fd-aafc-4cd7-9d26-030457708297", "price": 1.25 }
                   ]
                 }
               }
            """
            data = jsonString.data(using: .utf8)!
        case .post:
            APIClient.successRequst.toggle()
            try await Task.sleep(nanoseconds: 1_000_000_000)
            if APIClient.successRequst {
                let jsonString = """
                { "message": "Products purchased!" }
                """
                data = jsonString.data(using: .utf8)!
            } else {
                throw NetworkError.invalidResponse
            }

        default:
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
