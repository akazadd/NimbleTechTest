//
//  ForgotPasswordViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 6/11/23.
//

import Foundation

class ForgotPasswordViewModel {
    // MARK: - Properties
    
    var apiManager = ApiManager()
        
    var email: String = ""
    
    func isValidEmail() -> Bool {
        email.isValidEmail()
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<String, APIError>) -> Void) {
        let urlString = Constants.forgotPasswordUrl.rawValue
        
        let parameters = [
            "user": ["email": email],
            "client_id": Constants.clientId.rawValue,
            "client_secret": Constants.clientSecret.rawValue
        ] as [String : Any]
        
		apiManager.callApi(urlString: urlString, method: .post, parameters: parameters) { (result: Result<ForgotPasswordResponse, APIError>) in
            switch result {
            case .success(let response):
                let message = response.meta.message
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
