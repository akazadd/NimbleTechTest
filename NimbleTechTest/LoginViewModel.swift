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
    
    func login(_ requestInfo: LoginRequestInfo, competion: @escaping (Result<Bool, Error>) -> Void) {
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
            case .failure(let failure):
                if failure == .accessTokenExpired {
                    self.handleAccessTokenExpired {
                        
                        //Call main function here
                        
                    }
                }
            }
        }
    }
    
    func handleAccessTokenExpired(completion: @escaping () -> Void) {
        //Implement your logic
        
        completion()
        
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
