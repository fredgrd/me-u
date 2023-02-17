//
//  Room.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import Foundation


enum RoomKind: Hashable {
    case main
}

struct Room: Codable, Hashable {
    let id: String
    let user: String
    let name: String
    let description: String
}

struct RoomMessage: Codable, Hashable {
    let id: String
    let sender: String
    let sender_name: String
    let sender_number: String
    let sender_thumbnail: String
    let message: String
    let timestamp: String
}

enum RoomUpdateKind: String, Codable {
    case typing = "typing"
}

struct RoomUpdate: Codable {
    let kind: RoomUpdateKind
    let sender_name: String
}
