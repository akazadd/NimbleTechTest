//
//  HomeViewModelTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest

class HomeViewModelTests: XCTestCase {

	// Mock for testing the ApiManager
	class MockApiManager: ApiManager {
		var expectation: XCTestExpectation?
		
		func callApi(urlString: String, method: String, parameters: [String: Any]?, completion: @escaping (Result<SurveyListModel, APIError>) -> Void) {
			// Simulating the API call with a test expectation
			expectation?.fulfill()
		}
	}
	
	var homeViewModel: HomeViewModel!
	var mockApiManager: MockApiManager!
	
	override func setUp() {
		super.setUp()
		mockApiManager = MockApiManager()
		homeViewModel = HomeViewModel()
		homeViewModel.apiManager = mockApiManager
	}

	override func tearDown() {
		homeViewModel = nil
		mockApiManager = nil
		super.tearDown()
	}
    
    //testFetchSurveyListAPI() will be passed after successfully login

	func testFetchSurveyListAPI() {
		let expectation = self.expectation(description: "Fetching survey list from API")
		mockApiManager.expectation = expectation

		homeViewModel.fetchServeyListFromAPI(pageNumber: 1, pageSize: 5) {
			expectation.fulfill()
		}

		waitForExpectations(timeout: 5) { error in
			XCTAssertNil(error, "API call timed out.")
			XCTAssertNotNil(self.homeViewModel.responseData, "Response data is nil")
		}
	}
}

