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
	case noNetwork
	case invalidGrant
	case notFound
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

struct Connectivity {
	static let sharedInstance = NetworkReachabilityManager()!
	static var isConnectedToInternet:Bool {
		return self.sharedInstance.isReachable
	}
}

class ApiManager {
	var tokenManager = TokenManager()
	
	func callApi<T: Decodable>(urlString: String,
							   method: HTTPMethod,
							   parameters: Parameters?,
							   completion: @escaping (Result<T, APIError>) -> Void) {
		
		guard Connectivity.isConnectedToInternet else {
			completion(.failure(.noNetwork))
			return
		}
		
		// Function to update Authorization header
		func updateAuthorizationHeader(_ accessToken: String) -> HTTPHeaders {
			return HTTPHeaders(["Authorization": "Bearer \(accessToken)"])
		}
		
		
		AF.request(urlString,
				   method: method,
				   parameters: parameters,
				   encoding: JSONEncoding.default,
				   headers: updateAuthorizationHeader(tokenManager.getAccessToken()))
		.validate()
		.responseDecodable(of: T.self) { [weak self] response in
			guard let self = self else { return }
			
			switch response.result {
				case .success(let decodedObject):
					completion(.success(decodedObject))
					
				case .failure(let error):
					print("error: \(error)")
					
					if let statusCode = response.response?.statusCode, statusCode == 401 {
						self.handleTokenExpiration(urlString: urlString, method: method, parameters: parameters, completion: completion)
					} else if let statusCode = response.response?.statusCode, statusCode == 400 {
						completion(.failure(.invalidGrant))
					} else if let statusCode = response.response?.statusCode, statusCode == 404 {
						completion(.failure(.notFound))
					} else {
						completion(.failure(.parsingError))
					}
					
			}
		}
	}
	
	private func handleTokenExpiration<T: Decodable>(urlString: String, method: HTTPMethod,parameters: Parameters?,completion: @escaping (Result<T, APIError>) -> Void) {
		guard !tokenManager.isRefreshingToken else {
			completion(.failure(.accessTokenExpired))
			return
		}
		
		tokenManager.isRefreshingToken = true
		
		tokenManager.refreshAccessToken { result in
			self.tokenManager.isRefreshingToken = false
			
			switch result {
				case .success:
					// Retry the original request with the new access token
					self.callApi(urlString: urlString, method: method, parameters: parameters, completion: completion)
					
				case .failure(let refreshError):
					print("Token refresh failed with error: \(refreshError)")
					completion(.failure(.accessTokenExpired))
			}
		}
	}
}



