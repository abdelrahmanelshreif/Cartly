import SwiftUI
import MapKit

struct AddressesView: View {
    @StateObject var viewModel: AddressesViewModel = DIContainer.shared.resolveAddressViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                addressContent
            }
        }
        .fullScreenCover(isPresented: $viewModel.showLocationPicker) {
            LocationPickerView { coordinate in
                viewModel.handleLocationSelection(coordinate)
            }
        }
        .sheet(isPresented: $viewModel.showAddressForm) {
            AddressFormView(
                existingAddress: viewModel.addressToEdit,
                onSubmit: { input in
                    if viewModel.addressToEdit != nil {
                        viewModel.saveEditedAddress(input)
                    } else {
                        viewModel.saveNewAddress(with: input)
                    }
                }
            )
        }
        .sheet(isPresented: $viewModel.showChangeAddressSheet) {
            ChangeAddressView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadAddresses()
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var addressContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if let defaultAddress = viewModel.defaultAddress {
                    defaultAddressView(defaultAddress)
                }
                
            }
            .padding(.top)
        }
    }
    
    private func defaultAddressView(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("Default Address")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            HStack(alignment: .top, spacing: 10) {
                if let mapView = mapPreview(for: address) {
                    mapView
                        .allowsHitTesting(false)
                        .frame(width: 150, height: 80)
                        .cornerRadius(6)
                        .layoutPriority(1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let name = address.name {
                        Text(name)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    if let line = viewModel.formattedFullAddress(address){
                        Text(line)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if let phone = address.phone {
                        Text(phone)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(minWidth: 100, alignment: .leading)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.showLocationPicker = true
                }) {
                    Text("Add")
                        .font(.caption)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                
                Button(action: {
                    print("Change address tapped")
                    viewModel.showChangeAddressSheet = true
                }) {
                    Text("Change")
                        .font(.caption)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            .padding(.top, 6)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 0.5)
        .padding(.horizontal, 12)
        .frame(height: UIScreen.main.bounds.height * 0.25)
    }
    
    
    
    
    private func mapPreview(for address: Address) -> AnyView? {
        guard
            let latStr = address.address2?.split(separator: ",").first,
            let lonStr = address.address2?.split(separator: ",").last,
            let lat = Double(latStr),
            let lon = Double(lonStr)
        else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        return Map(position: .constant(.camera(MapCamera(centerCoordinate: coordinate, distance: 500)))) {
            Annotation("Address Pin", coordinate: coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .eraseToAnyView()
    }
}


extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

#Preview {
    AddressesView(
        viewModel: AddressesViewModel(
            fetchAddressesUseCase: FetchCustomerAddressesUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            addAddressUseCase: AddCustomerAddressUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            setDefaultAddressUseCase: SetDefaultCustomerAddressUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            deleteAddressUseCase: DeleteCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService())),
            editAddressUseCase: EditCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService()))
        )
    )
}
