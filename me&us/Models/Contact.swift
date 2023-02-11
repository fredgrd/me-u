//
//  Contact.swift
//  me&us
//
//  Created by Federico on 09/02/23.
//

import Foundation

struct Contact: Hashable {
    let id: String = UUID().uuidString
    let name: String
    let surname: String
    let number: String
    let imagedata: Data?
    var is_user: Bool = false
}
