//
//  LoginViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//
/*
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
 
 func validateInput(_ email: String?, password: String?, completion: @escaping (Bool, String?) -> Void) {
 if let email = email, !email.isEmpty {
 if !email.isValidEmail() {
 completion(false, InputErrorMessage.emptyEmail.rawValue)
 
 return
 }
 }  else {
 completion(false, InputErrorMessage.emptyEmail.rawValue)
 
 return
 }
 
 if let password = password, password.isEmpty {
 completion(false, InputErrorMessage.emptyPassword.rawValue)
 
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
 
 apiManager.callApi(urlString: urlString, method: "POST", parameters: postParameters) { [weak self] (result: Result<TokenResponseBase, APIError>) in
 
 guard let self = self else { return }
 
 switch result {
 case .success(let response):
 print("response: \(response)")
 self.apiManager.saveAccessToken(response.data?.attributes?.accessToken ?? "")
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
 
 */
import Foundation
import KeychainAccess

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
	
	var onLoginSuccess: (() -> Void)?
	var onLoginFailure: ((String) -> Void)?
	
	func validateAndLogin(email: String?, password: String?) {
		validateInput(email: email, password: password) { [weak self] valid, message in
			guard let self = self else { return }
			
			if valid {
				let loginRequestInfo = LoginRequestInfo(email: email!, password: password!)
				self.login(requestInfo: loginRequestInfo)
			} else {
				DispatchQueue.main.async {
					self.onLoginFailure?(message ?? "Validation failed")
				}
			}
		}
	}
	
	private func validateInput(email: String?, password: String?, completion: @escaping (Bool, String?) -> Void) {
		guard let email = email, !email.isEmpty else {
			DispatchQueue.main.async { [weak self] in
				self?.onLoginFailure?(InputErrorMessage.emptyEmail.rawValue)
			}
			return
		}
		
		guard email.isValidEmail() else {
			DispatchQueue.main.async { [weak self] in
				self?.onLoginFailure?(InputErrorMessage.invalidEmail.rawValue)
			}
			return
		}
		
		guard let password = password, !password.isEmpty else {
			DispatchQueue.main.async { [weak self] in
				self?.onLoginFailure?(InputErrorMessage.emptyPassword.rawValue)
			}
			return
		}
		
		completion(true, nil)
	}
	
	private func login(requestInfo: LoginRequestInfo) {
		let urlString = Constants.baseUrl.rawValue
		
		let postParameters = [
			"grant_type": GrantType.password.rawValue,
			"email": requestInfo.email,
			"password": requestInfo.password,
			"client_id": Constants.clientId.rawValue,
			"client_secret": Constants.clientSecret.rawValue
		]
		
		apiManager.callApi(urlString: urlString, method: .post, parameters: postParameters) { [weak self] (result: Result<TokenResponseBase, APIError>) in
			guard let self = self else { return }
			
			switch result {
				case .success(let response):
					apiManager.tokenManager.saveRefreshToken((response.data?.attributes?.refreshToken)!)
					DispatchQueue.main.async { [weak self] in
						self?.onLoginSuccess?()
					}
				case .failure(let error):
					var errorMessage = ""
					switch error {
						case .accessTokenExpired:
							errorMessage = "Access token Expired"
						case .networkError:
							errorMessage = "Network error"
						case .parsingError:
							errorMessage = "Parsing error"
						case .noNetwork:
							errorMessage = "No internet connection"
						case .invalidGrant:
							errorMessage = "Your email or password is incorrect"
						case .notFound:
							errorMessage = "Not found"
					}
					DispatchQueue.main.async { [weak self] in
						self?.onLoginFailure?(errorMessage + ", please try again!")
					}
			}
		}
	}
}
