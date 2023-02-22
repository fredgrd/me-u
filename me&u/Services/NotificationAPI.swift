//
//  NotificationAPI.swift
//  me&u
//
//  Created by Federico on 19/02/23.
//

import Foundation

final class NotificationAPI {
    let baseUrl: String = "https://api.dinolab.one"
    
    /**
     Fetches user's notification.

     - Returns: A new `Result<[Notification], APIError>`.
     */
    func fetchNotifications() async -> Result<[Notification], APIError> {
        guard let url = URL(string: baseUrl+"/notification/fetch") else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let notifications = try? JSONDecoder().decode([Notification].self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(notifications)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("NotificationAPI/fetchNotifications error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Fetches user's notification.

     - Returns: A new `Result<String, APIError>`.
     */
    func updateNotification(withID id: String, status: NotificationStatus) async -> Result<String, APIError> {
        guard let url = URL(string: baseUrl+"/notification/update"), let data = try? JSONEncoder().encode(["status": status.rawValue, "notification_id": id])  else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
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
            print("NotificationAPI/fetchNotifications error: \(error)")
            return .failure(.badRequest)
        }
    }
}
