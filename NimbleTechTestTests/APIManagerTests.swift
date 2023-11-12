//
//  APIManagerTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest
import Alamofire

class ApiManagerTests: XCTestCase {
    
	var apiManager: ApiManager!
	var mockNetworkLayer: MockNetworkLayer!
    
	override func setUp() {
		super.setUp()
		apiManager = ApiManager()
		mockNetworkLayer = MockNetworkLayer()
		apiManager.networkLayer = mockNetworkLayer
	}
    
	override func tearDown() {
		apiManager = nil
		mockNetworkLayer = nil
		super.tearDown()
	}
	
	func testSuccessfulAPICall() {
		let expectation = XCTestExpectation(description: "Successful API Call")
		let urlString = "your_test_url_here"
		
		// Simulate API call failure by setting a dummy status code of 200
		mockNetworkLayer.lastStatusCode = 200
		apiManager.networkLayer = mockNetworkLayer
		
		apiManager.callApi(urlString: urlString, method: .get, parameters: nil) { (result: Result<MockTokenResponse, APIError>) in
			switch result {
				case .success(let response):
					// Add assertions for the success scenario
					XCTAssertNotNil(response, "API response should not be nil")
					expectation.fulfill()
				case .failure(let error):
					// Add assertions for the failure scenario
					XCTFail("API call failed with error: \(error)")
			}
		}
		
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testApiCallFailure() {
		let expectation = XCTestExpectation(description: "API Call Failure Test")
		let urlString = "your_test_url_here_api_failure"

		// Simulate API call failure by setting a dummy status code of 500
		mockNetworkLayer.lastStatusCode = 500
		apiManager.networkLayer = mockNetworkLayer

		apiManager.callApi(urlString: urlString, method: .get, parameters: nil) { (result: Result<MockTokenResponse, APIError>) in
			switch result {
			case .success:
				XCTFail("API call failure test should result in a failure")
			case .failure(let error):
				XCTAssertEqual(error, .parsingError, "Expected error to be .invalidGrant for status code 400")
				expectation.fulfill()
			}
		}

		wait(for: [expectation], timeout: 10.0)
	}
	
}

class MockNetworkLayer: NetworkLayer {
	var lastStatusCode: Int?
	
	func request<T: Decodable>(_ urlString: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders, completion: @escaping (Result<T, APIError>) -> Void) {
		
		if let mockResponse = self.createMockResponse(type: T.self) {
			if let statusCode = lastStatusCode, statusCode == 200 {
				completion(.success(mockResponse))
				
			}  else {
				completion(.failure(.parsingError))
			}
		}
	}
	
	private func createMockResponse<T: Decodable>(type: T.Type) -> T? {
		// Customize this method based on your specific mock data needs
		let mockTokenResponse = MockTokenResponse(
			data: TokenData(
				id: "27906",
				type: "token",
				attributes: TokenAttributes(
					access_token: "pYA4ItZv-AxJcWpN2slboRCH315Js0CRguz8iDMmeUI",
					token_type: "Bearer",
					expires_in: 7200,
					refresh_token: "qliYqHXvnP9sVuZJmcK0ObnureVbIRZcKJmQ_KfM1sw",
					created_at: 1699788140
				)
			)
		)
		
		let mockData: MockTokenResponse = mockTokenResponse
		
		return mockData as? T
	}
}

struct MockTokenResponse: Decodable {
	let data: TokenData
}

struct TokenData: Decodable {
	let id: String
	let type: String
	let attributes: TokenAttributes
}

struct TokenAttributes: Decodable {
	let access_token: String
	let token_type: String
	let expires_in: Int
	let refresh_token: String
	let created_at: TimeInterval
}






