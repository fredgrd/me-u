//
//  AuthAPI.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import Foundation

final class AuthAPI {
    
    let baseUrl: String = "https://api.dinolab.one"
    

    
    func startVerification(withNumber number: String) async -> APIOperationResult {
        guard let url = URL(string: baseUrl+"/auth/start"), let data = try? JSONEncoder().encode(["number":number]) else {
            return APIOperationResult(success: false)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return APIOperationResult(success: false)
            }
            
            if (response.statusCode == 200) {
                let message = String(decoding: responseData, as: UTF8.self)
                return APIOperationResult(success: true, status: 200, message: message)
            } else {
                let message = String(decoding: responseData, as: UTF8.self)
                return APIOperationResult(success: false, status: response.statusCode, message:message)
            }
        } catch {
            print("AuthAPI error: \(error)")
            return APIOperationResult(success: false)
        }
    }
}
