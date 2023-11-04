//
//  TokenResponseModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

struct TokenResponseBase: Codable {
    let data: TokenResponse?
}

struct TokenResponse: Codable {
    let id: String?
    let type: String?
    let attributes: Attributes?
}

struct Attributes: Codable {
    let accessToken : String?
    let tokenType : String?
    let expiresIn : Int?
    let refreshToken : String?
    let createdAt : Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
    }
}
