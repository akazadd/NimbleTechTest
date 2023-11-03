//
//  LoginViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

struct LoginRequestInfo {
    var email: String
    var password: String
}

enum InputErrorMessage: String {
    case emptyEmail = "Please Enter Email"
    case emptyPassword = "Please Enter Password"
    case invalidEmail = "Enter a valid email"
}

class LoginViewModel {
    
    private let apiManager = ApiManager()
    
    typealias completionHandler = (Bool, InputErrorMessage?) -> Void
    
    func validateInput(_ email: String?, password: String?, completion: completionHandler) {
        if let email = email, !email.isEmpty {
            if !email.isValidEmail() {
                completion(false, InputErrorMessage.emptyEmail)
                
                return
            }
        }  else {
            completion(false, InputErrorMessage.emptyEmail)
            
            return
        }
        
        if let password = password, password.isEmpty {
            completion(false, InputErrorMessage.emptyPassword)
            
            return
        }
        
        completion(true, nil)
    }
    
    func login(_ requestInfo: LoginRequestInfo, competion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = Constants.baseUrl.rawValue
        
        let postParameters = ["grant_type": GrantType.password.rawValue,
                              "email": requestInfo.email,
                              "password": requestInfo.password,
                              "client_id": Constants.clientId.rawValue,
                              "client_secret": Constants.clientSecret.rawValue]
        
        apiManager.callApi(urlString: urlString, method: "POST", parameters: postParameters) { (result: Result<TokenResponseBase, APIError>) in
            switch result {
            case .success(let response):
                print("response: \(response)")
                UserDefaults.standard.set(response.data?.attributes?.accessToken, forKey: defaultKeys.accessToken)
                competion(.success(()))
            case .failure(let error):
                if error == .accessTokenExpired {
                    self.handleAccessTokenExpired()
                }
                competion(.failure(error))
            }
        }
    }
    
    func handleAccessTokenExpired() {
        apiManager.refreshAccessToken { result in
            switch result {
            case .success:
                print("successfully refreshed access token")
            case .failure:
                print("failed to refresh access token")
            }
        }
    }
}

