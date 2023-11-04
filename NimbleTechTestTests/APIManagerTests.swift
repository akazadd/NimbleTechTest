//
//  APIManagerTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest

class ApiManagerTests: XCTestCase {
    
    var apiManager: ApiManager!
    
    override func setUp() {
        super.setUp()
        apiManager = ApiManager()
    }
    
    override func tearDown() {
        apiManager = nil
        super.tearDown()
    }
    
    func testSuccessfulAPICall() {
        let expectation = XCTestExpectation(description: "Successful API Call")
        let urlString = Constants.surveyUrl.rawValue
        
        apiManager.callApi(urlString: urlString, method: "GET", parameters: nil) { (result: Result<SurveyListModel, APIError>) in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response, "API response should not be nil")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("API call failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAPIErrorHandling() {
        let expectation = XCTestExpectation(description: "API Error Handling")
        let urlString = "https://api.example.com/invalidEndpoint"
        
        apiManager.callApi(urlString: urlString, method: "GET", parameters: nil) { (result: Result<SurveyListModel, APIError>) in
            switch result {
            case .success:
                XCTFail("API call should fail for invalid endpoint")
            case .failure(let error):
                XCTAssertEqual(error, APIError.networkError, "Error should be network error")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTokenRefresh() {
        let expectation = XCTestExpectation(description: "Token Refresh")
        // Assuming you have a valid refresh token stored in keychain for testing
        
        apiManager.refreshAccessToken { result in
            switch result {
            case .success:
                XCTAssert(true, "Token refresh successful")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Token refresh failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testKeychainOperations() {
        let expectation = XCTestExpectation(description: "Keychain Operations")
        let refreshToken = "exampleRefreshToken"
        
        apiManager.saveRefreshToken(refreshToken)
        let retrievedToken = apiManager.getRefreshToken()
        
        XCTAssertEqual(retrievedToken, refreshToken, "Retrieved token should match saved token")
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5.0)
    }
}
