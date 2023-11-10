//
//  ApiManager.swift
//  NimbleTechTest
//
//  Created by A K Azad on 2/11/23.
//

import Foundation
import KeychainAccess
import Alamofire

enum APIError: Error {
    case accessTokenExpired
    case networkError
	case parsingError
    //more error case as needed
}

enum Constants: String {
    case baseUrl = "https://survey-api.nimblehq.co/api/v1/oauth/token"
    case surveyUrl = "https://survey-api.nimblehq.co/api/v1/surveys"
    case clientId = "ofzl-2h5ympKa0WqqTzqlVJUiRsxmXQmt5tkgrlWnOE"
    case clientSecret = "lMQb900L-mTeU-FVTCwyhjsfBwRCxwwbCitPob96cuU"
    case forgotPasswordUrl = "https://survey-api.nimblehq.co/api/v1/passwords"
}

enum GrantType: String {
    case password = "password"
    case refreshToken = "refresh_token"
}

struct defaultKeys {
    static let refreshTokenKey = "refreshToken"
    static let accessTokenKey = "accessToken"
    static let cachedSurveyData = "cachedSurveyData"
}

class ApiManager {
    private let keychain = Keychain(service: "com.akazad.app.refreshToken")
	private var isRefreshingToken = false
    
	func callApi<T: Decodable>(urlString: String,
							   method: HTTPMethod,
							   parameters: Parameters?,
							   completion: @escaping (Result<T, APIError>) -> Void) {
		// Function to update Authorization header
		func updateAuthorizationHeader(_ accessToken: String) -> HTTPHeaders {
			return HTTPHeaders(["Authorization": "Bearer \(accessToken)"])
		}

		AF.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: updateAuthorizationHeader(getAccessToken()))
			.validate()
			.responseDecodable(of: T.self) { [weak self] response in
				guard let self = self else { return }

				switch response.result {
				case .success(let decodedObject):
					completion(.success(decodedObject))

				case .failure(let error):
					print("error: \(error)")
					if let statusCode = response.response?.statusCode, statusCode == 401 {
						// Check if token refresh is not already in progress
						guard !self.isRefreshingToken else {
							completion(.failure(.accessTokenExpired))
							return
						}

						// Mark that token refresh is in progress
						self.isRefreshingToken = true

						self.refreshAccessToken { result in
							// Mark that token refresh is completed
							self.isRefreshingToken = false

							switch result {
							case .success:
								// Retry the original request with the new access token
								self.callApi(urlString: urlString, method: method, parameters: parameters, completion: completion)

							case .failure(let refreshError):
								print("Token refresh failed with error: \(refreshError)")
								completion(.failure(.accessTokenExpired))
							}
						}
					} else {
						completion(.failure(.networkError))
					}
				}
			}
	}

	func refreshAccessToken(completion: @escaping (Result<Void, APIError>) -> Void) {
		guard let refreshToken = try? keychain.get(defaultKeys.refreshTokenKey) else {
			completion(.failure(.accessTokenExpired))
			return
		}
		
		let refreshTokenUrl = Constants.baseUrl.rawValue
		
		struct RefreshTokenResponse: Decodable {
			let data: TokenResponse?
		}
		
		let parameters: Parameters = [
			"grant_type": GrantType.refreshToken.rawValue,
			"refresh_token": refreshToken,
			"client_id": Constants.clientId.rawValue,
			"client_secret": Constants.clientSecret.rawValue
		]
		
		AF.request(refreshTokenUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseDecodable(of: RefreshTokenResponse.self) { response in
				switch response.result {
				case .success(let refreshTokenResponse):
					if let tokenResponse = refreshTokenResponse.data {
						self.saveAccessToken(tokenResponse.attributes?.accessToken ?? "")
						self.saveRefreshToken(tokenResponse.attributes?.refreshToken ?? "")
						completion(.success(()))
					} else {
						completion(.failure(.parsingError))
					}
					
				case .failure:
					completion(.failure(.networkError))
				}
			}
	}
	
    func saveRefreshToken(_ token: String) {
        do {
            try keychain.set(token, key: defaultKeys.refreshTokenKey)
        } catch {
            print("Error saving refresh token to keychain: \(error)")
        }
    }
    
    func getRefreshToken() -> String {
        var refreshToken = ""
        do {
            refreshToken = try keychain.getString(defaultKeys.refreshTokenKey) ?? ""
        } catch {
            print("Error saving refresh token to keychain: \(error)")
        }
        
        return refreshToken
    }
    
    func saveAccessToken(_ token: String) {
        do {
            try keychain.set(token, key: defaultKeys.accessTokenKey)
        } catch {
            print("Error saving access token to keychain: \(error)")
        }
    }
    
    func getAccessToken() -> String {
        var accessToken = ""
        do {
            accessToken = try keychain.getString(defaultKeys.accessTokenKey) ?? ""
        } catch {
            print("Error getting access token")
        }
        
        return accessToken
    }
}



