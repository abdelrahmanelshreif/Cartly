//
//  ChangeAddressView.swift
//  Cartly
//
//  Created by Khalid Amr on 12/06/2025.
//

import Foundation
import SwiftUI
struct ChangeAddressView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AddressesViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.allAddresses, id: \.id) { address in
                    AddressRow(
                        address: address,
                        formattedAddress: viewModel.formattedFullAddress(address) ?? "Unknown address",
                        isDefault: address.isDefault ?? false,
                        onSelect: {
                            viewModel.setAsDefault(address)
                            dismiss()
                        },
                        onEdit: {
                            viewModel.editAddress(address)
                        },
                        onDelete: {
                            viewModel.deleteAddress(address)
                        }
                    )
                }
            }
            .navigationTitle("Change Address")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct AddressRow: View {
    let address: Address
    let formattedAddress: String
    let isDefault: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(address.name ?? "")
                    .font(.headline)
                
                if isDefault {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(formattedAddress)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Select") { onSelect() }
                    .buttonStyle(.borderedProminent)
                    .disabled(isDefault)
                
                Button("Edit") { onEdit() }
                    .buttonStyle(.bordered)
                
                Button("Delete") { onDelete() }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(isDefault)
            }
        }
        .padding(.vertical, 6)
    }
}
