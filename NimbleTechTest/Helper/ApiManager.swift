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

enum Constants: String {
    case baseUrl = "https://survey-api.nimblehq.co/api/v1/oauth/token"
    case surveyUrl = "https://survey-api.nimblehq.co/api/v1/surveys"
    case clientId = "ofzl-2h5ympKa0WqqTzqlVJUiRsxmXQmt5tkgrlWnOE"
    case clientSecret = "lMQb900L-mTeU-FVTCwyhjsfBwRCxwwbCitPob96cuU"
}

enum GrantType: String {
    case password = "password"
    case refreshToken = "refresh_token"
}

struct defaultKeys {
    static let accessToken = "accessToken"
}

class ApiManager {
    private let keychain = Keychain(service: "com.akazad.app.refreshToken")
    
    private let refreshTokenKey = "refreshToken"
    private var accessToken: String?
    
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
        
        if method == "GET" {
            let accessToken = UserDefaults.standard.string(forKey: defaultKeys.accessToken)
            request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
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
                // create json object from data or use JSONDecoder to convert to Model stuct
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                    
                    // handle json response
                } else {
                    print("data maybe corrupted or in wrong format")
                    throw URLError(.badServerResponse)
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
//                let _dData = try! decoder.decode(TokenResponseBase.self, from: data)
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
        
        let parameters = ["grant_type": GrantType.refreshToken.rawValue,
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
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard let self = self else { return }
            
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
                self.saveRefreshToken(decodedData.attributes?.refreshToken ?? "")
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



