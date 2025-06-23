//
//  ShopifyServicesTests.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 19/6/25.
//

import Foundation
import Combine
import XCTest
@testable import Cartly

// MARK: - ShopifyServices Tests
class ShopifyServicesTests: XCTestCase {
    var sut: ShopifyServices!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = ShopifyServices(networkService: mockNetworkService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSignup_WithValidData_Success() {
        // Given
        let signupData = SignUpData(
            firstname: "John",
            lastname: "Doe",
            email: "john.doe@example.com",
            password: "password123",
            passwordConfirm: "password123",
            sendinEmailVerification: true
        )
        
        let expectedCustomer = CustomerResponse(
            customer: Customer(
                id: 123456,
                email: "john.doe@example.com",
                createdAt: "",
                updatedAt: "",
                firstName: "John",
                lastName: "Doe",
                ordersCount: 1,
                state: "",
                totalSpent: "",
                lastOrderId: 124,
                note: "",
                verifiedEmail: true,
                multipassIdentifier: "",
                taxExempt: nil,
                tags: "",
                lastOrderName: "",
                currency: "",
                phone: "",
                addresses: [],
                emailMarketingConsent: nil,
                smsMarketingConsent: nil,
                adminGraphqlApiId: ""
            )
        )
        
        let expectation = XCTestExpectation(description: "Signup success")
        
        // When
        sut.signup(userData: signupData)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Expected success but got failure: \(error)")
                    }
                },
                receiveValue: { response in
                    // Then
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.customer?.email, expectedCustomer.customer?.email)
                    XCTAssertEqual(response?.customer?.firstName, expectedCustomer.customer?.firstName)
                    XCTAssertEqual(response?.customer?.lastName, expectedCustomer.customer?.lastName)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Simulate the network response
        mockNetworkService.responseSubject.send(expectedCustomer)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignup_WithoutPassword_ParametersCorrect() {
        // Given
        let signupData = SignUpData(
            firstname: "Jane",
            lastname: "Smith",
            email: "jane.smith@example.com",
            password: nil,
            passwordConfirm: nil,
            sendinEmailVerification: false
        )
        
        let expectedCustomer = CustomerResponse(
            customer: Customer(
                id: 789012,
                email: "jane.smith@example.com",
                createdAt: "",
                updatedAt: "",
                firstName: "Jane",
                lastName: "Smith",
                ordersCount: 0,
                state: "",
                totalSpent: "",
                lastOrderId: nil,
                note: "",
                verifiedEmail: true,
                multipassIdentifier: "",
                taxExempt: nil,
                tags: "",
                lastOrderName: "",
                currency: "",
                phone: "",
                addresses: [],
                emailMarketingConsent: nil,
                smsMarketingConsent: nil,
                adminGraphqlApiId: ""
            )
        )
        
        let expectation = XCTestExpectation(description: "Signup without password")
        
        // When
        sut.signup(userData: signupData)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    // Then - Verify the request was made correctly
                    XCTAssertTrue(self.mockNetworkService.requestCalled)
                    XCTAssertNotNil(self.mockNetworkService.requestParameters)
                    
                    if let parameters = self.mockNetworkService.requestParameters?.parameters as? [String: Any],
                       let customerData = parameters["customer"] as? [String: Any] {
                        XCTAssertEqual(customerData["first_name"] as? String, "Jane")
                        XCTAssertEqual(customerData["last_name"] as? String, "Smith")
                        XCTAssertEqual(customerData["email"] as? String, "jane.smith@example.com")
                        XCTAssertNil(customerData["password"])
                        XCTAssertNil(customerData["password_confirmation"])
                        XCTAssertEqual(customerData["send_email_welcome"] as? Bool, false)
                    } else {
                        XCTFail("Parameters not formatted correctly")
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Simulate the network response
        mockNetworkService.responseSubject.send(expectedCustomer)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignup_WithNetworkError_Failure() {
        // Given
        let signupData = SignUpData(
            firstname: "Error",
            lastname: "Test",
            email: "error@test.com",
            password: "password",
            passwordConfirm: "password",
            sendinEmailVerification: true
        )
        
        enum TestError: Error {
            case networkError
        }
        
        let expectation = XCTestExpectation(description: "Signup failure")
        
        // When
        sut.signup(userData: signupData)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertNotNil(error)
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected failure but got success")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value on error")
                }
            )
            .store(in: &cancellables)
        
        // Simulate network error
        mockNetworkService.responseSubject.send(completion: .failure(TestError.networkError))
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignup_VerifyRequestPath() {
        // Given
        let signupData = SignUpData(
            firstname: "Path",
            lastname: "Test",
            email: "path@test.com",
            password: "password",
            passwordConfirm: "password",
            sendinEmailVerification: true
        )
        
        let expectation = XCTestExpectation(description: "Verify request path")
        
        // When
        sut.signup(userData: signupData)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    // Then
                    XCTAssertEqual(self.mockNetworkService.requestParameters?.path, "/customers.json")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Simulate response
        mockNetworkService.responseSubject.send(CustomerResponse(customer: nil))
        mockNetworkService.responseSubject.send(completion: .finished)
        
        wait(for: [expectation], timeout: 2.0)
    }
}
