//
//  UserAPI.swift
//  me&us
//
//  Created by Federico on 07/02/23.
//

import Foundation

final class UserAPI {
    
    let baseUrl: String = "https://api.dinolab.one"
    
    /**
     Creates a user.

     - Parameter name: The user's name.

     - Returns: A new `Result<User, APIError>`.
     */
    func createUser(withName name: String) async -> Result<User, APIError> {
        guard let url = URL(string: baseUrl+"/user/create"), let data = try? JSONEncoder().encode(["name": name]) else {
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
                guard let user = try? JSONDecoder().decode(User.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(user)
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
     Fetch user.
     
     - Returns: A new `Result<User, APIError>`.
     */
    func fetchUser() async -> Result<User, APIError> {
        guard let url = URL(string: baseUrl+"/user/fetch") else {
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
                guard let user = try? JSONDecoder().decode(User.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(user)
            } else if (response.statusCode == 400 || response.statusCode == 403) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/fetchUser error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Update user status.
     
     - Parameter status: The status emoji.
     
     - Returns: A new `Result<User, APIError>`.
     */
    func updateStatus(withStatus status: String) async -> Result<User, APIError> {
        guard let url = URL(string: baseUrl+"/user/update-status"), let data = try? JSONEncoder().encode(["status": status]) else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let user = try? JSONDecoder().decode(User.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(user)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/updateUser error: \(error)")
            return .failure(.badRequest)
       }
    }
    
    /**
     Update user avatar.
     
     - Parameter url: The avatar url.
     
     - Returns: A new `Result<User, APIError>`.
     */
    func updateAvatar(withURL avatarURL: String) async -> Result<User, APIError> {
        guard let url = URL(string: baseUrl+"/user/update-avatar"), let data = try? JSONEncoder().encode(["avatar_url": avatarURL]) else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let user = try? JSONDecoder().decode(User.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(user)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/updateUser error: \(error)")
            return .failure(.badRequest)
       }
    }
    
    /**
     Delete the friend from the user's friends.
     
     - Parameter id: The friend id.
     
     - Returns: A new `Result<User, APIError>`.
     */
    func deleteFriend(withID id: String) async -> Result<User, APIError> {
        guard let url = URL(string: baseUrl+"/user/delete-friend"), let data = try? JSONEncoder().encode(["friend_id": id]) else {
            return .failure(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }
            
            if (response.statusCode == 200) {
                guard let user = try? JSONDecoder().decode(User.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(user)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/updateUser error: \(error)")
            return .failure(.badRequest)
       }
    }
    
    /**
     Fetch friend details.
     
     - Parameter id: The friend id.
     
     - Returns: A new `Result<FriendDetails, APIError>`.
     */
    func fetchFriendDetails(withID id: String) async -> Result<FriendDetails, APIError> {
        guard let url = URL(string: baseUrl+"/user/fetch-friend?friend_id=\(id)") else {
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
                guard let details = try? JSONDecoder().decode(FriendDetails.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(details)
            } else if (response.statusCode == 400 || response.statusCode == 403) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/fetchFriendDetails error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Parse contacts numbers.

     - Parameter contacts: The user's contacts numbers.

     - Returns: A new `Result<[String], APIError>`.
     */
    func parseContacts(withContacts contacts: [String]) async -> Result<[String], APIError> {
        guard let url = URL(string: baseUrl+"/user/parse-contacts"), let data = try? JSONEncoder().encode(["contacts": contacts]) else {
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
                guard let parsedContacts = try? JSONDecoder().decode([String].self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(parsedContacts)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/filterContacts error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Create friend request.

     - Parameter to: The friend's number.

     - Returns: A new `Result<FriendRequest, APIError>`.
     */
    func createFriendRequest(withTarget target: String) async -> Result<FriendRequest, APIError> {
        guard let url = URL(string: baseUrl+"/friend-request/create"), let data = try? JSONEncoder().encode(["to": target]) else {
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
                guard let friendRequest = try? JSONDecoder().decode(FriendRequest.self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(friendRequest)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createFriendRequest error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Update a friend request.

     - Parameter to: The friend's number.

     - Returns: A new `Result<FriendRequestUpdate, APIError>`.
     */
    func updateFriendRequest(withID id: String, update: FriendRequestUpdate) async -> Result<FriendRequestUpdate, APIError> {
        guard let url = URL(string: baseUrl+"/friend-request/update"), let data = try? JSONEncoder().encode(["request_id": id, "update": update.rawValue]) else {
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
                return .success(update)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createFriendRequest error: \(error)")
            return .failure(.badRequest)
        }
    }
    
    /**
     Fetch friend requests.

     - Parameter to: The friend's number.

     - Returns: A new `Result<[FriendRequest], APIError>`.
     */
    func fetchFriendRequests() async -> Result<[FriendRequest], APIError> {
        guard let url = URL(string: baseUrl+"/friend-request/fetch") else {
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
                guard let friendRequest = try? JSONDecoder().decode([FriendRequest].self, from: responseData) else {
                    return .failure(.badResponse)
                }
                
                return .success(friendRequest)
            } else if (response.statusCode == 400) {
                return .failure(.userError)
            } else {
                return .failure(.serverError)
            }
        } catch {
            print("UserAPI/createFriendRequest error: \(error)")
            return .failure(.badRequest)
        }
    }
}
