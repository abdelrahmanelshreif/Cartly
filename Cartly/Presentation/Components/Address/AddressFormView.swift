//
//  AddressFormView.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//
import SwiftUI

struct AddressFormView: View {
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var address1: String = ""
    @State private var city: String = ""
    @State private var province: String = ""
    @State private var zip: String = ""
    @State private var isDefault: Bool = false

    var existingAddress: Address? = nil
    let onSubmit: (AddressFormInput) -> Void
    private let provinces = [
        "6th of October", "Al Sharqia", "Alexandria", "Aswan", "Asyut", "Beheira", "Beni Suef", "Cairo",
        "Dakahlia", "Damietta", "Faiyum", "Gharbia", "Giza", "Helwan", "Ismailia", "Kafr el-Sheikh",
        "Luxor", "Matrouh", "Minya", "Monufia", "New Valley", "North Sinai", "Port Said", "Qalyubia",
        "Qena", "Red Sea", "Sohag", "South Sinai", "Suez"
    ]


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Address")) {
                    TextField("Address Line 1", text: $address1)
                    TextField("City", text: $city)
                    Picker("Governate", selection: $province) {
                        ForEach(provinces, id: \.self) { province in
                            Text(province)
                        }
                    }

                    TextField("Zip Code", text: $zip)
                        .keyboardType(.numbersAndPunctuation)
                    Toggle("Set as Default Address", isOn: $isDefault)
                }

                Section {
                    Button("Save Address") {
                        let input = AddressFormInput(
                            firstName: firstName,
                            lastName: lastName,
                            phone: phone,
                            address1: address1,
                            city: city,
                            isDefault: isDefault,
                            zip: zip,
                            province: province
                            
                           
                        )
                        onSubmit(input)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(existingAddress == nil ? "Add New Address" : "Edit Address")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .onAppear {
                if let existing = existingAddress {
                    firstName = existing.firstName ?? ""
                    lastName = existing.lastName ?? ""
                    phone = existing.phone ?? ""
                    address1 = existing.address1 ?? ""
                    city = existing.city ?? ""
                    province = existing.province ?? ""
                    zip = existing.zip ?? ""
                    isDefault = existing.isDefault ?? false
                }
            }
        }
    }

    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phone.isEmpty &&
        !address1.isEmpty &&
        !city.isEmpty &&
        !province.isEmpty &&
        !zip.isEmpty
    }
}

#Preview {
    AddressFormView(onSubmit: { _ in })
}
