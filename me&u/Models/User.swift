//
//  User.swift
//  me&us
//
//  Created by Federico on 06/02/23.
//

import Foundation

struct UserFriendDetails: Codable, Hashable {
    let id: String
    let number: String
    let name: String
    let avatar_url: String
}

struct User: Codable {
    let id: String
    let fcm_token: String
    let name: String
    let number: String
    let avatar_url: String
    let status: String
    let friends: [UserFriendDetails]
    let created_at: String
}
