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
                    return .failure(.badDecoding)
                }
                
                return .success(room)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("RoomAPI/createRoom error: \(error)")
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
            print("RoomAPI/deleteRoom error: \(error)")
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
                    return .failure(.badDecoding)
                }
                
                return .success(room)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("RoomAPI/fetchRooms error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Fetch the room.

     - Parameters
        - id: The room id.

     - Returns: A new `Result<Room, APIError>`.
     */
    func fetchRoom(withID id: String) async -> Result<Room, APIError> {
        guard let url = URL(string: baseUrl+"/room/fetch?room_id=\(id)") else {
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
                guard let room = try? JSONDecoder().decode(Room.self, from: responseData) else {
                    return .failure(.badDecoding)
                }
                
                return .success(room)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("RoomAPI/fetchRoom error: \(error)")
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
                    return .failure(.badDecoding)
                }
                
                return .success(messages)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("RoomAPI/fetchMessages error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    
    struct AudioResponse: Decodable {
        let audio_url: String
    }
    
    /**
     Uploads an audio message.

     - Parameters
        - audioData: The audio Data..

     - Returns: A new `Result<String, APIError>`.
     */
    func uploadAudio(_ audioData: Data) async -> Result<String, APIError> {
        let paramName: String = "audiofile"
        guard let url = URL(string: baseUrl+"/room/audio-upload") else {
            return .failure(APIError.badURL)
        }
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        
        // Generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Construct the form data
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"audio\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        
        // Append audio data
        data.append(audioData)
        
        // Ending
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = data
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                return .failure(APIError.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let audio = try? JSONDecoder().decode(AudioResponse.self, from: responseData) else {
                    return .failure(APIError.badDecoding)
                }
                
                return .success(audio.audio_url)
            } else if (response.statusCode == 400) {
                return .failure(APIError.userError)
            } else {
                return .failure(APIError.serverError)
            }
        } catch {
            print("RoomAPI/uploadAudio error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    struct ImageResponse: Decodable {
        let image_url: String
    }
    
    /**
     Uploads an image message.

     - Parameters
        - imageData: The image Data.

     - Returns: A new `Result<String, APIError>`.
     */
    func uploadImage(_ imageData: Data) async -> Result<String, APIError> {
        let paramName: String = "imagefile"
        guard let url = URL(string: baseUrl+"/room/image-upload") else {
            return .failure(APIError.badURL)
        }
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        
        // Generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Construct the form data
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"image\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        
        // Append image data
        data.append(imageData)
        
        // Ending
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = data
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                return .failure(APIError.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let image = try? JSONDecoder().decode(ImageResponse.self, from: responseData) else {
                    return .failure(APIError.badDecoding)
                }
                
                return .success(image.image_url)
            } else if (response.statusCode == 400) {
                return .failure(APIError.userError)
            } else {
                return .failure(APIError.serverError)
            }
        } catch {
            print("RoomAPI/uploadImage error: \(error)")
            return .failure(.badRequest)
        }
    }
}
