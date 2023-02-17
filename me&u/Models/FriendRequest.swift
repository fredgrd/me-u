//
//  FriendRequest.swift
//  me&us
//
//  Created by Federico on 09/02/23.
//

import Foundation

enum FriendRequestUpdate: String {
    case accept = "accept"
    case reject = "reject"
}

struct FriendRequestUserDetails: Codable {
    let name: String
    let avatar_url: String
}

struct FriendRequest: Codable, Hashable {
    let id: String
    let from: String
    let from_user: FriendRequestUserDetails
    let to: String
    let to_user: FriendRequestUserDetails
    
    static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
