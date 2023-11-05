//
//  ForgotPasswordResponseModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 6/11/23.
//

import Foundation

struct ForgotPasswordResponse: Codable {
    let meta: Meta
    
    struct Meta: Codable {
        let message: String
    }
}
