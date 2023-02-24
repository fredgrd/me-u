//
//  HTTPAPI.swift
//  me&u
//
//  Created by Federico on 23/02/23.
//

import Foundation
import os

class CoreAPI {
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PATCH = "PATCH"
    }
    
    private let baseUrl: String = "https://api.dinolab.one"
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: UserManager.self))
    
    func request<T: Decodable>(to url: String, method: HTTPMethod = .GET, data: Data? = nil) async -> Result<T, APIError> {
        guard let url = URL(string: baseUrl + url) else {
            return .failure(.badURL)
        }
        
        // Form Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        
        // Add Data
        if let data = data {
            request.httpBody = data
        }
        
        guard let (responseData, response) = try? await URLSession.shared.data(for: request), let response = response as? HTTPURLResponse else {
            return .failure(.badResponse)
        }
        
        if (response.statusCode == 200) {
            guard let object = try? JSONDecoder().decode(T.self, from: responseData) else {
                return .failure(.badDecoding)
            }
            
            return .success(object)
        } else if (response.statusCode == 400) {
            return .failure(APIError.userError)
        } else if (response.statusCode == 403) {
            return .failure(APIError.authError)
        } else {
            return .failure(APIError.serverError)
        }
    }
}
