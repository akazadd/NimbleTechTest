//
//  LoginViewModelTests.swift
//  NimbleTechTestTests
//
//  Created by A K Azad on 4/11/23.
//

import XCTest
@testable import NimbleTechTest

class LoginViewModelTests: XCTestCase {
    
    var loginViewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        loginViewModel = LoginViewModel()
    }
    
    override func tearDown() {
        loginViewModel = nil
        super.tearDown()
    }
	
	func testValidLogin() {
		let expectation = XCTestExpectation(description: "Login Success")
		loginViewModel.onLoginSuccess = {
			expectation.fulfill()
		}
		loginViewModel.onLoginFailure = { _ in
			XCTFail("Login should be successful")
		}

		loginViewModel.validateAndLogin(email: "x@g.co", password: "123456")

		// Wait for 5 seconds, adjust this based on the expected delay in your login process
		wait(for: [expectation], timeout: 5.0)
	}
	
	func testInvalidEmail() {
		let expectation = XCTestExpectation(description: "Invalid Email Failure")
		loginViewModel.onLoginSuccess = {
			XCTFail("Login should fail for invalid email")
		}
		loginViewModel.onLoginFailure = { message in
			XCTAssertEqual(message, InputErrorMessage.invalidEmail.rawValue)
			expectation.fulfill()
		}
		
		loginViewModel.validateAndLogin(email: "invalidemail", password: "password")
		
		wait(for: [expectation], timeout: 5.0)
	}
	
	func testEmptyPassword() {
		let expectation = XCTestExpectation(description: "Empty Password Failure")
		loginViewModel.onLoginSuccess = {
			XCTFail("Login should fail for empty password")
		}
		loginViewModel.onLoginFailure = { message in
			XCTAssertEqual(message, InputErrorMessage.emptyPassword.rawValue)
			expectation.fulfill()
		}
		
		loginViewModel.validateAndLogin(email: "test@example.com", password: "")
		
		wait(for: [expectation], timeout: 5.0)
	}
}
