//
//  APIOperationResult.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import Foundation

struct APIOperationResult {
    let success: Bool
    let status: Int?
    let message: String?
    
    init(success: Bool, status: Int? = nil, message: String? = nil) {
        self.success = success
        self.status = status
        self.message = message
    }
}
