//
//  Endpoint.swift
//  ShoppingCart
//
//  Created by Oleksiy Chebotarov on 20/03/2025.
//

import Alamofire
import Foundation

protocol Endpoint: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any] { get }
    var headers: HTTPHeaders { get }
}

extension Endpoint {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL.appending(path)) else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.headers = headers

        switch method {
        case .get:
            request = try URLEncoding.default.encode(request, with: parameters)
        case .post:
            request = try JSONEncoding.default.encode(request, with: parameters)
        default:
            break
        }

        return request
    }
}
