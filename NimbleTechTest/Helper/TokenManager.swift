//
//  TokenManager.swift
//  NimbleTechTest
//
//  Created by Abul Kalam Azad on 11/11/23.
//

import Foundation
import KeychainAccess
import Alamofire

class TokenManager {
	private let keychain = Keychain(service: "com.akazad.app.refreshToken")
	var isRefreshingToken = false

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

	private func saveRefreshToken(_ token: String) {
		do {
			try keychain.set(token, key: defaultKeys.refreshTokenKey)
		} catch {
			print("Error saving refresh token to keychain: \(error)")
		}
	}

	private func saveAccessToken(_ token: String) {
		do {
			try keychain.set(token, key: defaultKeys.accessTokenKey)
		} catch {
			print("Error saving access token to keychain: \(error)")
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
