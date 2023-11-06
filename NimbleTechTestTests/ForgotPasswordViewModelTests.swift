//
//  ForgotPasswordViewModelTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest

class ForgotPasswordViewModelTests: XCTestCase {
	
	var forgotPasswordViewModel: ForgotPasswordViewModel!
	
	override func setUp() {
		super.setUp()
		forgotPasswordViewModel = ForgotPasswordViewModel()
	}

	override func tearDown() {
		forgotPasswordViewModel = nil
		super.tearDown()
	}

	func testIsValidEmail() {
		// Test for a valid email
		forgotPasswordViewModel.email = "test@example.com"
		XCTAssertTrue(forgotPasswordViewModel.isValidEmail(), "Email is valid")

		// Test for an invalid email
		forgotPasswordViewModel.email = "invalid_email"
		XCTAssertFalse(forgotPasswordViewModel.isValidEmail(), "Email is invalid")
	}

	func testForgotPassword() {
		let expectation = self.expectation(description: "Forgot password API call")
		var apiResult: Result<String, APIError>?
		
		forgotPasswordViewModel.forgotPassword(email: "test@example.com") { result in
			apiResult = result
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5) { error in
			XCTAssertNil(error, "API call timed out.")
			
			switch apiResult {
			case .success(let message):
				XCTAssertEqual(message, "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.")
			case .failure(let error):
				XCTFail("API call failed with error: \(error)")
			case .none:
				XCTFail("API call result is nil")
			}
		}
	}
}

