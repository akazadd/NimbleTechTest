//
//  ApiManager.swift
//  NimbleTechTest
//
//  Created by A K Azad on 2/11/23.
//

import Foundation
import KeychainAccess

enum APIError: Error {
    case accessTokenExpired
    case networkError
    //more error case as needed
}

class ApiManager {
    private let keychain = Keychain(service: "com.akazad.app.refreshToken")
    
    private let refreshTokenKey = "refreshToken"
    private var accessToken: String?
    
    enum Constants: String {
        case baseUrl = "https://survey-api.nimblehq.co/api/v1/oauth/token"
        case clientId = "ofzl-2h5ympKa0WqqTzqlVJUiRsxmXQmt5tkgrlWnOE"
        case clientSecret = "lMQb900L-mTeU-FVTCwyhjsfBwRCxwwbCitPob96cuU"
    }
    
    func callApi<T: Codable>(urlString: String,
                             method: String,
                             parameters: [String: String]?,
                             completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.networkError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        //Add JSON body for POST method
        if method == "POST", let parameters = parameters {
            // Set HTTP Request Headers
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                completion(.failure(.networkError))
                
                return
            }
            
            guard let data = data else {
                completion(.failure(.networkError))
                
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    self.refreshAccessToken { result in
                        switch result {
                        case .success:
                            //Retry the original request
                            self.callApi(urlString: urlString, method: method, parameters: parameters, completion: completion)
                        case .failure:
                            completion(.failure(.accessTokenExpired))
                        }
                    }
                } else {
                    completion(.failure(.networkError))
                }
            }
        }
        
        task.resume()
    }
    
    func refreshAccessToken(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let refreshToken = try? keychain.get(refreshTokenKey) else {
            completion(.failure(.accessTokenExpired))
            
            return
        }
        
        let refreshTokenUrl = Constants.baseUrl.rawValue
        
        let parameters = ["grant_type": "refresh_token",
                          "refresh_token": refreshToken,
                          "client_id": Constants.clientId.rawValue,
                          "client_secret": Constants.clientSecret.rawValue]
        
        guard let url = URL(string: refreshTokenUrl) else {
            completion(.failure(.networkError))
            
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                completion(.failure(.networkError))
                
                return
            }
            
            guard let data = data else {
                completion(.failure(.networkError))
                
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(TokenResponse.self, from: data)
                self.accessToken = decodedData.attributes?.accessToken
                
                completion(.success(()))
            } catch {
                completion(.failure(.accessTokenExpired))
            }
        }
        
        task.resume()
    }
    
    func saveRefreshToken(_ token: String) {
        do {
            try keychain.set(token, key: refreshTokenKey)
        } catch {
            print("Error saving refresh token to keychain: \(error)")
        }
    }
}



