////
////  ShopifyServicesTests.swift
////  Cartly
////
////  Created by Abdelrahman Elshreif on 19/6/25.
////
//
//import Foundation
//import Combine
//import XCTest
//@testable import Cartly
//
//// MARK: - ShopifyServices Tests
//class ShopifyServicesTests: XCTestCase {
//    var sut: ShopifyServices!
//    var mockNetworkService: MockNetworkService!
//    var cancellables: Set<AnyCancellable>!
//    
//    override func setUp() {
//        super.setUp()
//        mockNetworkService = MockNetworkService()
//        sut = ShopifyServices()
//        // We need to inject the mock network service
//        // Since we can't directly inject it, we'll need to modify the ShopifyServices class
//        // to accept dependency injection for testing
//        cancellables = []
//    }
//    
//    override func tearDown() {
//        sut = nil
//        mockNetworkService = nil
//        cancellables = nil
//        super.tearDown()
//    }
//    
//    func testSignup_WithValidData_Success() {
//        // Given
//        let signupData = SignUpData(
//            firstname: "John",
//            lastname: "Doe",
//            email: "john.doe@example.com",
//            password: "password123",
//            passwordConfirm: "password123",
//            sendinEmailVerification: true
//        )
//        
//        let expectedCustomer = CustomerResponse(
//            customer: Customer(id: 123456, email: "john.doe@example.com", createdAt: "", updatedAt: "", firstName: "John", lastName: "Doe", ordersCount: 1, state: "", totalSpent: "", lastOrderId: 124, note: "", verifiedEmail: true, multipassIdentifier: "", taxExempt: nil , tags: "", lastOrderName: "", currency: "", phone: "", addresses: [], emailMarketingConsent: nil, smsMarketingConsent: nil, adminGraphqlApiId: "")
//        )
//        
//        let expectation = XCTestExpectation(description: "Signup success")
//        
//        // When
//        sut.signup(userData: signupData)
//            .sink(
//                receiveCompletion: { completion in
//                    if case .failure = completion {
//                        XCTFail("Expected success but got failure")
//                    }
//                },
//                receiveValue: { response in
//                    // Then
//                    XCTAssertNotNil(response)
//                    XCTAssertEqual(response?.customer?.email, expectedCustomer.customer?.email)
//                    expectation.fulfill()
//                }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testSignup_WithoutPassword_ParametersCorrect() {
//        // Given
//        let signupData = SignUpData(
//            firstname: "Jane",
//            lastname: "Smith",
//            email: "jane.smith@example.com",
//            password: nil,
//            passwordConfirm: nil,
//            sendinEmailVerification: false
//        )
//        
//        
//    }
//}
