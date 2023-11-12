//
//  HomeViewModelTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest
import Alamofire

class HomeViewModelTests: XCTestCase {

	var homeViewModel: HomeViewModel!
	var mockApiManager: MockApiManager!

	override func setUpWithError() throws {
		homeViewModel = HomeViewModel()
		mockApiManager = MockApiManager()
		UserDefaults.standard.removeObject(forKey: defaultKeys.cachedSurveyData)
	}

	override func tearDownWithError() throws {
		homeViewModel = nil
	}

	func testFetchSurveysSuccess() {
		// Given
		let expectation = XCTestExpectation(description: "Fetch Surveys Success")
		let mockDelegate = MockHomeViewModelDelegate(expectation: expectation)
		homeViewModel.delegate = mockDelegate
		let successResponse = SurveyListModel(
			surveyList: [
				Survey(id: "1", type: "survey_simple", attributes: nil, relationships: nil),
				Survey(id: "2", type: "survey_simple", attributes: nil, relationships: nil),
				Survey(id: "3", type: "survey_simple", attributes: nil, relationships: nil),
				Survey(id: "4", type: "survey_simple", attributes: nil, relationships: nil)
			],
			meta: Meta(page: 1, pages: 4, pageSize: 5, records: 20)
		)
		mockApiManager.successResponse = successResponse
		homeViewModel.apiManager = mockApiManager

		// When
		homeViewModel.fetchSurveys()

		// Then
		wait(for: [expectation], timeout: 10.0)

		// Assertions
		XCTAssertEqual(homeViewModel.totalPages, successResponse.meta?.pages, "Total pages should be updated")
		XCTAssertEqual(homeViewModel.responseData, successResponse.surveyList, "Response data should be updated")
		XCTAssertTrue(mockApiManager.isCallApiMethodCalled, "callApi method should be called")
	}

	func testShouldPaginationBeCalled() {
		homeViewModel.totalPages = 5

		homeViewModel.pageNumber = 3
		XCTAssertTrue(homeViewModel.shouldPaginationBeCalled(), "Pagination should be called when pageNumber is less than or equal to totalPages")

		homeViewModel.pageNumber = 6
		XCTAssertFalse(homeViewModel.shouldPaginationBeCalled(), "Pagination should not be called when pageNumber is greater than totalPages")
	}

	func testLoadCachedSurveys() {
		let cachedSurveys: [Survey] = [/* Add some sample surveys */]
		let encodedData = try? JSONEncoder().encode(cachedSurveys)
		UserDefaults.standard.set(encodedData, forKey: defaultKeys.cachedSurveyData)

		homeViewModel.loadCachedSurveys()

		XCTAssertEqual(homeViewModel.responseData, cachedSurveys, "Cached surveys should be loaded correctly")
	}

	func testIncrementPageNumber() {
		homeViewModel.pageNumber = 1

		homeViewModel.incrementPageNumber()

		XCTAssertEqual(homeViewModel.pageNumber, 2, "Page number should be incremented")
	}
}

// Mock API Manager for simulating success and failure scenarios
class MockApiManager: ApiManager {

	var successResponse: SurveyListModel?
	var failureError: APIError?
	var isCallApiMethodCalled = false

	override func callApi<T>(
		urlString: String,
		method: HTTPMethod,
		parameters: Parameters?,
		completion: @escaping (Result<T, APIError>) -> Void
	) where T: Decodable {
		isCallApiMethodCalled = true

		if let error = failureError {
			completion(.failure(error))
		} else if let response = successResponse as? T {
			completion(.success(response))
		} else {
			fatalError("Invalid response type")
		}
	}
}

// Mock delegate to capture the asynchronous callback
class MockHomeViewModelDelegate: HomeViewModelDelegate {
	let expectation: XCTestExpectation

	init(expectation: XCTestExpectation) {
		self.expectation = expectation
	}

	func surveysFetched() {
		expectation.fulfill()
	}
}

