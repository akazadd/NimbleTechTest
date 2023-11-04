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
    
    func testValidInput() {
        let expectation = XCTestExpectation(description: "Valid Input")
        
        loginViewModel.validateInput("test@example.com", password: "password") { isValid, error in
            XCTAssertTrue(isValid, "Input should be valid")
            XCTAssertNil(error, "Error should be nil for valid input")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testEmptyEmail() {
        let expectation = XCTestExpectation(description: "Empty Email")
        
        loginViewModel.validateInput("", password: "password") { isValid, error in
            XCTAssertFalse(isValid, "Input should be invalid for empty email")
            XCTAssertEqual(error, InputErrorMessage.emptyEmail, "Error should be empty email")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testInvalidEmailFormat() {
        let expectation = XCTestExpectation(description: "Invalid Email Format")
        
        loginViewModel.validateInput("invalidemail", password: "password") { isValid, error in
            XCTAssertFalse(isValid, "Input should be invalid for invalid email format")
            XCTAssertEqual(error, InputErrorMessage.emptyEmail, "Error should be empty email")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testEmptyPassword() {
        let expectation = XCTestExpectation(description: "Empty Password")
        
        loginViewModel.validateInput("test@example.com", password: "") { isValid, error in
            XCTAssertFalse(isValid, "Input should be invalid for empty password")
            XCTAssertEqual(error, InputErrorMessage.emptyPassword, "Error should be empty password")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoginSuccess() {
        let expectation = XCTestExpectation(description: "Login Success")
        
        let requestInfo = LoginRequestInfo(email: "test@example.com", password: "password")
        
        loginViewModel.login(requestInfo) { result in
            switch result {
            case .success:
                XCTAssert(true, "Login should be successful")
                expectation.fulfill()
            case .failure:
                XCTFail("Login should not fail for valid credentials")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
