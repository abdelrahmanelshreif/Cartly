//
//  CustomerAddressRepository.swift
//  CartlyTests
//
//  Created by Khalid Amr on 23/06/2025.
//
//
//  CustomerAddressRepositoryTests.swift
//  CartlyTests
//
//  Created by Khalid Amr on 23/06/2025.
//

import XCTest
import Combine
@testable import Cartly

enum error: Error {
    case someError
}


final class CustomerAddressRepositoryTests: XCTestCase {
    var sut: CustomerAddressRepository!
    var mockService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        sut = CustomerAddressRepository(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_fetchAddresses_success() {
        let customerID: Int64 = 123
        let expectedAddresses = [
            Address(address1: "123 Main St", address2: nil, city: "Cairo", country: "Egypt", countryCode: "EG", countryName: "Egypt", company: nil, firstName: "Khalid", id: 1, lastName: "Amr", name: nil, phone: "1234567890", province: "Cairo", zip: "12345", isDefault: true)
        ]
        let expectation = XCTestExpectation(description: "Fetch addresses")

        sut.fetchAddresses(for: customerID)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { addresses in
                XCTAssertEqual(addresses.count, 1)
                XCTAssertEqual(addresses.first?.city, "Cairo")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(AddressesListResponse(addresses: expectedAddresses))
    }

    func test_addAddress_success() {
        let customerID: Int64 = 123
        let address = Address(address1: "Street 1", address2: nil, city: "Giza", country: "Egypt", countryCode: "EG", countryName: "Egypt", company: nil, firstName: "Test", id: nil, lastName: "User", name: nil, phone: "0123456789", province: "Cairo", zip: "11223", isDefault: false)
        let expectation = XCTestExpectation(description: "Add address")

        sut.addAddress(for: customerID, address: address)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { returnedAddress in
                XCTAssertEqual(returnedAddress.city, "Giza")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(CustomerAddressResponse(customerAddress: address))
    }

    func test_editAddress_failsWithNoID() {
        let customerID: Int64 = 123
        let invalidAddress = Address(address1: "Street", address2: nil, city: "City", country: nil, countryCode: nil, countryName: nil, company: nil, firstName: nil, id: nil, lastName: nil, name: nil, phone: nil, province: "Cairo", zip: nil, isDefault: nil)

        let expectation = XCTestExpectation(description: "Edit should fail")

        sut.editAddress(for: customerID, address: invalidAddress)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not succeed with nil ID")
            })
            .store(in: &cancellables)

    }

    func test_deleteAddress_success() {
        let customerID: Int64 = 123
        let addressID: Int64 = 456
        let expectation = XCTestExpectation(description: "Delete address")

        sut.deleteAddress(for: customerID, addressID: addressID)
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(EmptyResponse())
    }

    func test_setDefaultAddress_success() {
        let customerID: Int64 = 123
        let addressID: Int64 = 456
        let expectedAddress = Address(address1: "Default St", address2: nil, city: "Alex", country: "Egypt", countryCode: "EG", countryName: "Egypt", company: nil, firstName: nil, id: addressID, lastName: nil, name: nil, phone: nil, province: "Cairo", zip: nil, isDefault: true)
        let expectation = XCTestExpectation(description: "Set default address")

        sut.setDefaultAddress(for: customerID, addressID: addressID)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { returnedAddress in
                XCTAssertEqual(returnedAddress.id, addressID)
                XCTAssertTrue(returnedAddress.isDefault ?? false)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(CustomerAddressResponse(customerAddress: expectedAddress))
    }
    func test_editAddress_success() {
        let customerID: Int64 = 123
        let address = Address(
            address1: "Updated Street",
            address2: nil,
            city: "Mansoura",
            country: "Egypt",
            countryCode: "EG",
            countryName: "Egypt",
            company: nil,
            firstName: "John",
            id: 99,
            lastName: "Doe",
            name: nil,
            phone: "01098765432",
            province: "Dakahlia",
            zip: "76543",
            isDefault: false
        )

        let expectation = XCTestExpectation(description: "Edit address")

        sut.editAddress(for: customerID, address: address)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got failure: \(error)")
                }
            }, receiveValue: { returnedAddress in
                XCTAssertEqual(returnedAddress.city, "Mansoura")
                XCTAssertEqual(returnedAddress.id, 99)
                XCTAssertEqual(returnedAddress.firstName, "John")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(CustomerAddressResponse(customerAddress: address))
    }
    func test_addAddress_failure() {
        let customerID: Int64 = 123
        let address = Address(address1: "Street 1", address2: nil, city: "Giza", country: "Egypt", countryCode: "EG", countryName: "Egypt", company: nil, firstName: "Test", id: nil, lastName: "User", name: nil, phone: "0123456789", province: "Cairo", zip: "11223", isDefault: false)

        let expectation = XCTestExpectation(description: "Add address fails")

        sut.addAddress(for: customerID, address: address)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(completion: .failure(error.someError))
    }

    func test_deleteAddress_failure() {
        let customerID: Int64 = 123
        let addressID: Int64 = 456

        let expectation = XCTestExpectation(description: "Delete address fails")

        sut.deleteAddress(for: customerID, addressID: addressID)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: {
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(completion: .failure(error.someError))
    }
    
    func test_fetchAddresses_failure() {
        let customerID: Int64 = 123
        let expectation = XCTestExpectation(description: "Fetch addresses fails")

        sut.fetchAddresses(for: customerID)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(completion: .failure(error.someError))
    }
    
    func test_setDefaultAddress_failure() {
        let customerID: Int64 = 123
        let addressID: Int64 = 456
        let expectation = XCTestExpectation(description: "Set default address fails")

        sut.setDefaultAddress(for: customerID, addressID: addressID)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)

        mockService.responseSubject.send(completion: .failure(error.someError))
    }

    



}
