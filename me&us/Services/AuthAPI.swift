//
//  AuthAPI.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import Foundation

final class AuthAPI {
    
    let baseUrl: String = "https://api.dinolab.one"
    
    /**
     Starts the phone number verification process.

     - Parameter number: The user's phone number.

     - Returns: A new `Result<String, APIError>`.
     */
    func startVerification(withNumber number: String) async -> Result<String, APIError> {
        guard let url = URL(string: baseUrl+"/auth/start"), let data = try? JSONEncoder().encode(["number":number]) else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }
            
            if (response.statusCode == 200) {
                return .success("OK")
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("AuthAPI/startVerification error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    struct CompleteVerificationResult: Decodable {
        let user: User?
        let new_user: Bool
    }
    
    /**
     Completes the phone number verification process.

     - Parameters
        - code: The OTP received by user.
        - number: The user's phone number.

     - Returns: A new `Result<CompleteVerificationResult, APIError>`.
     */
    func completeVerification(withCode code: String, number: String) async -> Result<CompleteVerificationResult, APIError> {
        guard let url = URL(string: baseUrl+"/auth/complete"), let data = try? JSONEncoder().encode(["number":number, "code": code]) else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }

            if (response.statusCode == 200) {
                guard let decoded = try? JSONDecoder().decode(CompleteVerificationResult.self, from: responseData) else {
                    return .failure(.badResponse)
                }

                return .success(decoded)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("AuthAPI/completeVerification error: \(error)")
            return .failure(.badRequest)
        }
    }
}
