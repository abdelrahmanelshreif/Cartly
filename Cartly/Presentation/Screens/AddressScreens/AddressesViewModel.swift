import Foundation
import Combine
import MapKit

class AddressesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var defaultAddress: Address?
    @Published var allAddresses: [Address] = []
    @Published var isLoading = false
    @Published var showLocationPicker = false
    @Published var showAddAddressForm = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedCoordinate: CLLocationCoordinate2D? // Store selected location
    
    // MARK: - Dependencies
    private let fetchAddressesUseCase: FetchCustomerAddressesUseCaseProtocol
    private let addAddressUseCase: AddCustomerAddressUseCaseProtocol
    private let setDefaultAddressUseCase: SetDefaultCustomerAddressUseCaseProtocol
    private let customerID: Int64 = 7691118575799 // Static customer ID
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init 
    init(
        fetchAddressesUseCase: FetchCustomerAddressesUseCaseProtocol,
        addAddressUseCase: AddCustomerAddressUseCaseProtocol,
        setDefaultAddressUseCase: SetDefaultCustomerAddressUseCaseProtocol
    ) {
        self.fetchAddressesUseCase = fetchAddressesUseCase
        self.addAddressUseCase = addAddressUseCase
        self.setDefaultAddressUseCase = setDefaultAddressUseCase
    }
    
    // MARK: - Public Functions
    func loadAddresses() {
        isLoading = true
        fetchAddressesUseCase.execute(customerID: customerID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] addresses in
                self?.handleAddressesResponse(addresses)
            })
            .store(in: &cancellables)
    }
    
    func handleLocationSelection(_ coordinate: CLLocationCoordinate2D) {
        guard isLocationInsideEgypt(coordinate: coordinate) else {
            showError(message: "Location must be inside Egypt")
            return
        }

        selectedCoordinate = coordinate
        showLocationPicker = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showAddAddressForm = true
        }
    }

    
    func saveNewAddress(with details: AddressFormInput) {
        guard let coordinate = selectedCoordinate else {
            showError(message: "Location not selected")
            return
        }

        print("📤 Saving new address...")
        print("📍 Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        print("📍 Details: \(details)")

        let newAddress = Address(
            address1: details.address1,
            address2: "\(coordinate.latitude),\(coordinate.longitude)", // Save lat/lon in address2
            city: details.city,
            country: "Egypt",
            countryCode: "EG",
            countryName: "Egypt",
            company: nil,
            customerId: customerID,
            firstName: details.firstName,
            id: nil,
            lastName: details.lastName,
            name: "\(details.firstName) \(details.lastName)",
            phone: details.phone,
            province: details.province.isEmpty ? "Cairo" : details.province,
            provinceCode: nil,
            zip: details.zip.isEmpty ? "11511" : details.zip,
            isDefault: details.isDefault
        )

        addAddressUseCase.execute(customerID: customerID, address: newAddress)
            .flatMap { [weak self] savedAddress -> AnyPublisher<Address, Error> in
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }

                if details.isDefault, let addressID = savedAddress.id {
                    return self.setDefaultAddressUseCase.execute(
                        customerID: self.customerID,
                        addressID: addressID
                    )
                }
                return Just(savedAddress)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] _ in
                self?.showAddAddressForm = false
                self?.selectedCoordinate = nil
                self?.loadAddresses()
            })
            .store(in: &cancellables)
    }


    
    // MARK: - Private Helpers
    private func handleAddressesResponse(_ addresses: [Address]) {
        allAddresses = addresses
        defaultAddress = addresses.first(where: { $0.isDefault == true }) ?? addresses.first
        
        if addresses.isEmpty {
            showLocationPicker = true
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func isLocationInsideEgypt(coordinate: CLLocationCoordinate2D) -> Bool {
        let egyptBounds = (
            minLat: 22.0, maxLat: 31.6,
            minLon: 25.0, maxLon: 35.0
        )
        return coordinate.latitude >= egyptBounds.minLat &&
               coordinate.latitude <= egyptBounds.maxLat &&
               coordinate.longitude >= egyptBounds.minLon &&
               coordinate.longitude <= egyptBounds.maxLon
    }
    
    
}
