//
//  AlamofireNetworkLayer.swift
//  NimbleTechTest
//
//  Created by Abul Kalam Azad on 12/11/23.
//

import Foundation
import Alamofire

protocol NetworkLayer {
	var lastStatusCode: Int? { get set }
	func request<T: Decodable>(_ urlString: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders, completion: @escaping (Result<T, APIError>) -> Void)
}

class AlamofireNetworkLayer: NetworkLayer {
	var lastStatusCode: Int?
	
	func request<T: Decodable>(_ urlString: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders ,completion: @escaping (Result<T, APIError>) -> Void) {
		AF.request(urlString, method: method, parameters: parameters, headers: headers)
			.validate()
			.responseDecodable(of: T.self) { [weak self] response in
				switch response.result {
					case .success(let decodedObject):
						completion(.success(decodedObject))
						
					case .failure(_):
						if let statusCode = response.response?.statusCode {
							self?.lastStatusCode = statusCode
							switch statusCode {
								case 401:
									completion(.failure(.accessTokenExpired))
								case 400:
									completion(.failure(.invalidGrant))
								case 404:
									completion(.failure(.notFound))
								default:
									completion(.failure(.parsingError))
							}
						} else {
							completion(.failure(.parsingError))
						}
				}
			}
	}
}
