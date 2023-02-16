//
//  RoomAPI.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import Foundation

final class RoomAPI {
    let baseUrl: String = "https://api.dinolab.one"
    
    /**
     Creates a room.

     - Parameters
        - name: The room name.
        - descrtiption: The room description.

     - Returns: A new `Result<Room, APIError>`.
     */
    func createRoom(withName name: String, description: String) async -> Result<Room, APIError> {
        guard let url = URL(string: baseUrl+"/room/create"), let data = try? JSONEncoder().encode(["name": name, "description": description]) else {
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
                guard let room = try? JSONDecoder().decode(Room.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(room)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createUser error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Deletes a room.

     - Parameters
        - roomID: The room id.

     - Returns: A new `Result<String, APIError>`.
     */
    func deleteRoom(withID roomID: String) async -> Result<String?, APIError> {
        guard let url = URL(string: baseUrl+"/room/delete"), let data = try? JSONEncoder().encode(["room_id": roomID]) else {
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
                return .success(roomID)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createUser error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Fetches the user's rooms.

     - Parameters
        - user: The user id.

     - Returns: A new `Result<[Room], APIError>`.
     */
    func fetchRooms(forUser user: String) async -> Result<[Room], APIError> {
        guard let url = URL(string: baseUrl+"/room/rooms/fetch?user_id=\(user)") else {
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
                guard let room = try? JSONDecoder().decode([Room].self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(room)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createUser error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Fetches the room's message history.

     - Parameters
        - room: The room id.

     - Returns: A new `Result<[RoomMessage], APIError>`.
     */
    func fetchMessages(forRoom room: String) async -> Result<[RoomMessage], APIError> {
        guard let url = URL(string: baseUrl+"/room/messages?room_id=\(room)") else {
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
                guard let messages = try? JSONDecoder().decode([RoomMessage].self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(messages)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createUser error: \(error)")
            return .failure(.badRequest)
        }
    }
}
