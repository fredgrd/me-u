//
//  Notification.swift
//  me&u
//
//  Created by Federico on 19/02/23.
//

import Foundation

enum NotificationStatus: String, Codable {
    case sent = "sent"
    case read = "read"
}

struct Notification: Codable, Hashable {
    let id: String
    let room_id: String
    let room_name: String
    let user_id: String
    let sender_id: String
    let sender_name: String
    let sender_avatar: String
    let fcm_id: String
    var status: NotificationStatus
    let message: String
    let type: String
    let timestamp: String
}
