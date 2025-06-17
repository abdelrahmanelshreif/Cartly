//
//  TestDataHelpers.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 16/6/25.
//

import Foundation
import FirebaseAuth
@testable import Cartly

extension SignUpData {
    static func mock(
        firstname: String = "John",
        lastname: String = "Doe",
        email: String = "john.doe@example.com",
        password: String? = "password123",
        passwordConfirm: String? = "password123",
        sendinEmailVerification: Bool = true
    ) -> SignUpData {
        return SignUpData(
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: password,
            passwordConfirm: passwordConfirm,
            sendinEmailVerification: sendinEmailVerification
        )
    }
}

extension CustomerResponse {
    static func mock(
        customer: Customer = Customer.mock()
    ) -> CustomerResponse {
        return CustomerResponse(customer: customer)
    }
}



extension Customer {
    static func mock(
        id: Int64 = 12345,
        email: String = "john.doe@example.com",
        firstName: String? = "John",
        lastName: String? = "Doe",
        verifiedEmail: Bool? = true,
        state: String? = "invited",
        phone: String? = nil,
        createdAt: String? = "2024-01-01T00:00:00Z",
        updatedAt: String? = "2024-01-01T00:00:00Z",
        ordersCount: Int = 0,
        totalSpent: String? = "0.00",
        tags: String? = nil,
        currency: String? = "EGP",
        addresses: [Address]? = nil
    ) -> Customer {
        return Customer(
            id: id,
            email: email,
            createdAt: createdAt,
            updatedAt: updatedAt,
            firstName: firstName,
            lastName: lastName,
            ordersCount: ordersCount,
            state: state,
            totalSpent: totalSpent,
            lastOrderId: nil,
            note: nil,
            verifiedEmail: verifiedEmail,
            multipassIdentifier: nil,
            taxExempt: false,
            tags: tags,
            lastOrderName: nil,
            currency: currency,
            phone: phone,
            addresses: addresses,
            emailMarketingConsent: nil,
            smsMarketingConsent: nil,
            adminGraphqlApiId: nil
        )
    }
}

