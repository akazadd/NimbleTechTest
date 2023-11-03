//
//  TokenResponseModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

struct TokenResponseBase: Codable {
    let data: TokenResponse?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        data = try value.decodeIfPresent(TokenResponse.self, forKey: .data)
    }
}

struct TokenResponse: Codable {
    let id: String?
    let type: String?
    let attributes: Attributes?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        id = try value.decodeIfPresent(String.self, forKey: .id)
        type = try value.decodeIfPresent(String.self, forKey: .type)
        attributes = try value.decodeIfPresent(Attributes.self, forKey: .attributes)
    }
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

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
        tokenType = try values.decodeIfPresent(String.self, forKey: .tokenType)
        expiresIn = try values.decodeIfPresent(Int.self, forKey: .expiresIn)
        refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
        createdAt = try values.decodeIfPresent(Int.self, forKey: .createdAt)
    }
}
