import SwiftUI
import MapKit

struct AddressesView: View {
    @StateObject var viewModel: AddressesViewModel

    init(viewModel: AddressesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
        .sheet(isPresented: $viewModel.showAddAddressForm) {
            AddressFormView { details in
                viewModel.saveNewAddress(with: details)
            }
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

                addressButtons
            }
            .padding(.top)
        }
    }

    private func defaultAddressView(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Default Address")
                .font(.title3)
                .fontWeight(.semibold)

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(address.name ?? "")
                    .font(.headline)
            }

            Text(address.address1 ?? "")
            Text(address.city ?? "")
            Text(address.phone ?? "")

            if let mapView = mapPreview(for: address) {
                mapView
                    .allowsHitTesting(false)
                    .frame(height: 100)
                    .cornerRadius(8)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
    }

    private var addressButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.showLocationPicker = true
            }) {
                Text("Add New Address")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // Placeholder for future change-address flow
                print("Change address tapped")
            }) {
                Text("Choose Another Address")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
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

        return Map(position: .constant(.camera(MapCamera(centerCoordinate: coordinate, distance: 1000)))) {
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
            )
        )
    )
}
