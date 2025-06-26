//
//  LoginViewModelTests.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import XCTest
import Combine
@testable import Cartly


class LoginViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    var mockLoginUseCase: MockFirebaseShopifyLoginUseCase!
    var mockGoogleLoginUseCase: MockAuthenticatingUserWithGoogleUseCase!
    var mockValidator: MockLoginValidator!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockLoginUseCase = MockFirebaseShopifyLoginUseCase()
        mockGoogleLoginUseCase = MockAuthenticatingUserWithGoogleUseCase()
        mockValidator = MockLoginValidator()
        
        sut = LoginViewModel(
            loginUseCase: mockLoginUseCase,
            validator: mockValidator,
            loginUsingGoogleUseCase: mockGoogleLoginUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockLoginUseCase = nil
        mockGoogleLoginUseCase = nil
        mockValidator = nil
        cancellables = nil
        super.tearDown()
    }
    

    func test_login_whenValidationFails_setsValidationErrorAndDoesNotCallUseCase() {
        // Arrange
        let validationError = ValidationError.invalidEmail
        mockValidator.validationResultToReturn = .invalid(validationError)
        sut.email = "bademail"
        
        // Act
        sut.login()
        
        // Assert
        XCTAssertEqual(sut.validationError, validationError.localizedDescription)
        XCTAssertFalse(mockLoginUseCase.executeWasCalled)
    }
    
    func test_login_whenValidationSucceeds_clearsValidationErrorAndCallsUseCase() {
        // Arrange
        mockValidator.validationResultToReturn = .valid
        sut.validationError = "An old error message"
        
        // Act
        sut.login()
        
        // Assert
        XCTAssertNil(sut.validationError)
        XCTAssertTrue(mockLoginUseCase.executeWasCalled)
    }
    
    // MARK: - Email Login Flow Tests

    func test_login_whenSuccessful_setsStateToLoadingThenSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "Result state should transition to success")
        
        // Act
        sut.login()
        
        if case .loading = sut.resultState {} else { XCTFail("State should be loading") }
        mockLoginUseCase.sendSuccess(customer: Customer(id: 1234, email: "email@gmail.com", createdAt: "", updatedAt: "", firstName: "John", lastName: "", ordersCount: 2, state: "", totalSpent: "", lastOrderId: 2, note: "", verifiedEmail: true, multipassIdentifier: "", taxExempt: false, tags: "", lastOrderName: "", currency: "", phone: "", addresses: [], emailMarketingConsent: nil, smsMarketingConsent: nil, adminGraphqlApiId: ""))
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .success(let userName) = self.sut.resultState {
                XCTAssertEqual(userName, "John")
                expectation.fulfill()
            } else {
                XCTFail("Final state should be .success")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_login_whenFails_setsStateToLoadingThenFailure() {
        // Arrange
        let expectation = XCTestExpectation(description: "Result state should transition to failure")
        let authError = AuthError.userNotFound
        
        // Act
        sut.login()
        
        // Assert
        if case .loading = sut.resultState {} else { XCTFail("State should be loading") }
        mockLoginUseCase.sendFailure(error: authError)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .failure(let errorMessage) = self.sut.resultState {
                XCTAssertEqual(errorMessage, authError.localizedDescription)
                expectation.fulfill()
            } else {
                XCTFail("Final state should be .failure")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func test_loginWithGoogle_whenSuccessful_updatesStateToSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "Google login should succeed")
        
        // Act
        sut.loginWithGoogle()
        
        // Assert
        XCTAssertTrue(mockGoogleLoginUseCase.executeWasCalled)
        if case .loading = sut.resultState {} else { XCTFail("State should be loading") }
        
        // Simulate success
        mockGoogleLoginUseCase.sendSuccess(customer: Customer(id: 1234, email: "email@gmail.com", createdAt: "", updatedAt: "", firstName: "Susan", lastName: "", ordersCount: 2, state: "", totalSpent: "", lastOrderId: 2, note: "", verifiedEmail: true, multipassIdentifier: "", taxExempt: false, tags: "", lastOrderName: "", currency: "", phone: "", addresses: [], emailMarketingConsent: nil, smsMarketingConsent: nil, adminGraphqlApiId: ""))
        
        // Assert final state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .success(let userName) = self.sut.resultState {
                XCTAssertEqual(userName, "Susan")
                expectation.fulfill()
            } else {
                XCTFail("Final state should be .success")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func test_loginWithGoogle_whenFails_updatesStateToFailure() {
        // Arrange
        let expectation = XCTestExpectation(description: "Google login should fail")
        let testError = AuthError.firebaseloginFailed
        
        // Act
        sut.loginWithGoogle()
        
        // Assert
        XCTAssertTrue(mockGoogleLoginUseCase.executeWasCalled)
        
        // Simulate failure
        mockGoogleLoginUseCase.sendFailure(error: testError)
        
        // Assert final state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .failure(let errorMessage) = self.sut.resultState {
                XCTAssertEqual(errorMessage, testError.localizedDescription)
                expectation.fulfill()
            } else {
                XCTFail("Final state should be .failure")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
