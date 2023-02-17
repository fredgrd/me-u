//
//  APIError.swift
//  me&us
//
//  Created by Federico on 06/02/23.
//

import Foundation

enum APIError: Error {
    case badURL
    case badRequest
    case badResponse
    case serverError
    case userError
}
