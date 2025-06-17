//
//  AuthRepositoryImplTests.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 16/6/25.
//

import XCTest
import Combine
import FirebaseAuth
@testable import Cartly

final class AuthRepositoryImplTests: XCTestCase {
    
    var repository: AuthRepositoryImpl!
    var mockFirebaseService: MockFirebaseServices!
    var mockShopifyService: MockShopifyServices!
    var mockUserSessionService: MockUserSessionService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockFirebaseServices()
        mockShopifyService = MockShopifyServices()
        mockUserSessionService = MockUserSessionService()
        repository = AuthRepositoryImpl(
            firebaseAuthClient: mockFirebaseService,
            shopifyAuthClient: mockShopifyService,
            userSessionServices: mockUserSessionService
        )
        cancellables = []
    }
    
    override func tearDown() {
        repository = nil
        mockFirebaseService = nil
        mockShopifyService = nil
        mockUserSessionService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Sign In With Google Tests
//    
//    func testSignInWithGoogle_whenServiceSucceeds_returnsUser() {
//        // Arrange
//        let expectation = XCTestExpectation(description: "Google sign in succeeds")
//        let mockUser = MockFirebaseUser(uid: "google123", email: "user@gmail.com", displayName: "Google User")
//        var receivedUser: User?
//        
//        // Act
//        repository.signInWithGoogle()
//            .sink(
//                receiveCompletion: { completion in
//                    if case .failure(let error) = completion {
//                        XCTFail("Expected success but got error: \(error)")
//                    }
//                    expectation.fulfill()
//                },
//                receiveValue: { user in
//                    receivedUser = user
//                }
//            )
//            .store(in: &cancellables)
//        
//        // Control
//        mockFirebaseService.signInWithGoogleSubject.send(mockUser)
//        mockFirebaseService.signInWithGoogleSubject.send(completion: .finished)
//        
//        // Assert
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(mockFirebaseService.signInWithGoogleCallCount, 1)
//        XCTAssertNotNil(receivedUser)
//        XCTAssertEqual(receivedUser?.uid, "google123")
//    }
    
    // MARK: - Sign Up Tests
    
    func testSignup_whenBothServicesSucceed_returnsCustomerResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign up succeeds")
        let signUpData = SignUpData.mock()
        let expectedCustomerResponse = CustomerResponse.mock()
        var receivedCustomerResponse: CustomerResponse?
        
        // Act
        repository.signup(signUpData: signUpData)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { response in
                    receivedCustomerResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Control - Shopify succeeds first
        mockShopifyService.signupSubject.send(expectedCustomerResponse)
        mockShopifyService.signupSubject.send(completion: .finished)
        
        // Then Firebase succeeds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mockFirebaseService.signupSubject.send("firebase123")
            self?.mockFirebaseService.signupSubject.send(completion: .finished)
        }
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockShopifyService.signupCallCount, 1)
        XCTAssertEqual(mockShopifyService.lastSignUpData?.email, signUpData.email)
        XCTAssertEqual(mockFirebaseService.signupCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastSignupCredentials?.email, signUpData.email)
        XCTAssertNotNil(receivedCustomerResponse)
        XCTAssertEqual(receivedCustomerResponse?.customer?.email, expectedCustomerResponse.customer?.email)
    }
    
    func testSignup_whenShopifyFails_returnsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign up fails at Shopify")
        let signUpData = SignUpData.mock()
        var receivedError: Error?
        
        // Act
        repository.signup(signUpData: signUpData)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Control - Shopify fails
        mockShopifyService.signupSubject.send(completion: .failure(MockError.generic))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockShopifyService.signupCallCount, 1)
        XCTAssertEqual(mockFirebaseService.signupCallCount, 0, "Firebase signup should not be called if Shopify fails")
        XCTAssertNotNil(receivedError)
    }
    
    func testSignup_whenShopifySucceedsButFirebaseFails_returnsFirebaseError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign up fails at Firebase")
        let signUpData = SignUpData.mock()
        let expectedCustomerResponse = CustomerResponse.mock()
        var receivedError: Error?
        
        // Act
        repository.signup(signUpData: signUpData)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Control - Shopify succeeds
        mockShopifyService.signupSubject.send(expectedCustomerResponse)
        mockShopifyService.signupSubject.send(completion: .finished)
        
        // Then Firebase fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mockFirebaseService.signupSubject.send(completion: .failure(MockError.generic))
        }
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockShopifyService.signupCallCount, 1)
        XCTAssertEqual(mockFirebaseService.signupCallCount, 1)
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is AuthError)
    }
    
    // MARK: - Create Shopify User Tests
    
    func testCreateShopifyUser_whenServiceSucceeds_returnsCustomerResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Create Shopify user succeeds")
        let signUpData = SignUpData.mock()
        let expectedCustomerResponse = CustomerResponse.mock()
        var receivedCustomerResponse: CustomerResponse?
        
        // Act
        repository.createShopifyUser(signupData: signUpData)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { response in
                    receivedCustomerResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockShopifyService.signupSubject.send(expectedCustomerResponse)
        mockShopifyService.signupSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockShopifyService.signupCallCount, 1)
        XCTAssertEqual(mockShopifyService.lastSignUpData?.email, signUpData.email)
        XCTAssertNotNil(receivedCustomerResponse)
    }
    
    // MARK: - Sign In Tests
    
    func testSignIn_whenServiceSucceeds_returnsUserId() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign in succeeds")
        let credentials = EmailCredentials(email: "test@example.com", password: "password123")
        let expectedUserId = "user123"
        var receivedUserId: String?
        
        // Act
        repository.signIn(credentials: credentials)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { userId in
                    receivedUserId = userId
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.signInSubject.send(expectedUserId)
        mockFirebaseService.signInSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.signInCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastSignInCredentials?.email, credentials.email)
        XCTAssertEqual(receivedUserId, expectedUserId)
    }
    
    func testSignIn_whenServiceReturnsNil_returnsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign in fails with nil response")
        let credentials = EmailCredentials(email: "test@example.com", password: "password123")
        var receivedError: Error?
        
        // Act
        repository.signIn(credentials: credentials)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.signInSubject.send(nil)
        mockFirebaseService.signInSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is AuthError)
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut_whenServiceSucceeds_completesSuccessfully() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign out succeeds")
        var completionReceived = false
        
        // Act
        repository.signOut()
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        completionReceived = true
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.signOutSubject.send(())
        mockFirebaseService.signOutSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived)
        XCTAssertEqual(mockFirebaseService.signOutCallCount, 1)
    }
    
    func testSignOut_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Sign out fails")
        var receivedError: Error?
        
        // Act
        repository.signOut()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.signOutSubject.send(completion: .failure(MockError.generic))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(mockFirebaseService.signOutCallCount, 1)
    }
    
    // MARK: - Get Current User Info Tests
    
    func testGetCurrentLoggedInUserId_returnsUserIdFromSession() {
        // Arrange
        let expectedUserId = "user123"
        mockUserSessionService.currentUserIdToReturn = expectedUserId
        
        // Act
        let result = repository.getCurrentLoggedInUserId()
        
        // Assert
        XCTAssertEqual(result, expectedUserId)
    }
    
    func testGetCurrentLoggedInUserId_returnsNilWhenNoUser() {
        // Arrange
        mockUserSessionService.currentUserIdToReturn = nil
        
        // Act
        let result = repository.getCurrentLoggedInUserId()
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testGetCurrentUserEmail_returnsEmailFromSession() {
        // Arrange
        let expectedEmail = "test@example.com"
        mockUserSessionService.currentUserEmailToReturn = expectedEmail
        
        // Act
        let result = repository.getCurrentUserEmail()
        
        // Assert
        XCTAssertEqual(result, expectedEmail)
    }
    
    func testGetCurrentUserEmail_returnsNilWhenNoEmail() {
        // Arrange
        mockUserSessionService.currentUserEmailToReturn = nil
        
        // Act
        let result = repository.getCurrentUserEmail()
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testGetCurrentUserVerificationStatus_returnsStatusFromSession() {
        // Arrange
        mockUserSessionService.isUserEmailVerifiedToReturn = true
        
        // Act
        let result = repository.getCurrentUserVerificationStatus()
        
        // Assert
        XCTAssertEqual(result, true)
    }
    
    func testGetCurrentUserVerificationStatus_returnsFalseWhenNotVerified() {
        // Arrange
        mockUserSessionService.isUserEmailVerifiedToReturn = false
        
        // Act
        let result = repository.getCurrentUserVerificationStatus()
        
        // Assert
        XCTAssertEqual(result, false)
    }
    
    func testIsUserLoggedIn_returnsTrueWhenLoggedIn() {
        // Arrange
        mockUserSessionService.isUserLoggedInToReturn = true
        
        // Act
        let result = repository.isUserLoggedIn()
        
        // Assert
        XCTAssertEqual(result, true)
    }
    
    func testIsUserLoggedIn_returnsFalseWhenNotLoggedIn() {
        // Arrange
        mockUserSessionService.isUserLoggedInToReturn = false
        
        // Act
        let result = repository.isUserLoggedIn()
        
        // Assert
        XCTAssertEqual(result, false)
    }
    
    func testGetCurrentUsername_returnsUsernameFromSession() {
        // Arrange
        let expectedUsername = "John Doe"
        mockUserSessionService.currentUserNameToReturn = expectedUsername
        
        // Act
        let result = repository.getCurrentUsrname()
        
        // Assert
        XCTAssertEqual(result, expectedUsername)
    }
    
    func testGetCurrentUsername_returnsNilWhenNoUsername() {
        // Arrange
        mockUserSessionService.currentUserNameToReturn = nil
        
        // Act
        let result = repository.getCurrentUsrname()
        
        // Assert
        XCTAssertNil(result)
    }
}

