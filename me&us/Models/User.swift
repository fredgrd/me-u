//
//  User.swift
//  me&us
//
//  Created by Federico on 06/02/23.
//

import Foundation

struct UserFriendDetails: Codable {
    let id: String
    let number: String
    let name: String
}

struct User: Codable {
    let id: String
    let name: String
    let number: String
    let avatar_url: String
    let friends: [UserFriendDetails]
    let created_at: String
}
