//
//  AddressFormView.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//
import SwiftUI

struct AddressFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var input = AddressFormInput()
    let onSave: (AddressFormInput) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("First Name", text: $input.firstName)
                    TextField("Last Name", text: $input.lastName)
                    TextField("Phone", text: $input.phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address Line 1", text: $input.address1)
                    TextField("City", text: $input.city)
                    TextField("Governate", text: $input.province)
                    TextField("Zip Code", text: $input.zip)
                        .keyboardType(.numbersAndPunctuation)
                    Toggle("Set as Default Address", isOn: $input.isDefault)
                }
                
                Section {
                    Button("Save Address") {
                        onSave(input)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add New Address")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private var isFormValid: Bool {
        !input.firstName.isEmpty &&
        !input.lastName.isEmpty &&
        !input.phone.isEmpty &&
        !input.address1.isEmpty &&
        !input.city.isEmpty &&
        !input.province.isEmpty &&
        !input.zip.isEmpty
    }
}
#Preview {
    AddressFormView { _ in }
}
