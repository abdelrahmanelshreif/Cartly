import Foundation
import Combine
import MapKit

class AddressesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var defaultAddress: Address?
    @Published var allAddresses: [Address] = []
    @Published var isLoading = false
    @Published var showLocationPicker = false
    @Published var showAddressForm: Bool = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var showChangeAddressSheet = false
    @Published var addressToEdit: Address?
    @Published var isDeleting = false
    
    // MARK: - Dependencies
    private let fetchAddressesUseCase: FetchCustomerAddressesUseCaseProtocol
    private let addAddressUseCase: AddCustomerAddressUseCaseProtocol
    private let setDefaultAddressUseCase: SetDefaultCustomerAddressUseCaseProtocol
    private let deleteAddressUseCase : DeleteCustomerAddressUseCaseProtocol
    private let editAddressUseCase : EditCustomerAddressUseCaseProtocol
    private let customerID: Int64 = 7703169302711 // Static customer ID
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        fetchAddressesUseCase: FetchCustomerAddressesUseCaseProtocol,
        addAddressUseCase: AddCustomerAddressUseCaseProtocol,
        setDefaultAddressUseCase: SetDefaultCustomerAddressUseCaseProtocol,
        deleteAddressUseCase : DeleteCustomerAddressUseCaseProtocol,
        editAddressUseCase : EditCustomerAddressUseCaseProtocol
    ) {
        self.fetchAddressesUseCase = fetchAddressesUseCase
        self.addAddressUseCase = addAddressUseCase
        self.setDefaultAddressUseCase = setDefaultAddressUseCase
        self.deleteAddressUseCase = deleteAddressUseCase
        self.editAddressUseCase = editAddressUseCase
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
        guard EgyptLocationValidator.isInsideEgypt(coordinate) else {
            showError(message: "Location must be inside Egypt")
            return
        }
        
        selectedCoordinate = coordinate
        showLocationPicker = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showAddressForm = true
        }
    }
    
    
    func saveNewAddress(with details: AddressFormInput) {
        guard let coordinate = selectedCoordinate else {
            showError(message: "Location not selected")
            return
        }
        
        let editedAddress = Address(
            address1: details.address1,
            address2: "\(coordinate.latitude),\(coordinate.longitude)",
            city: details.city,
            country: "Egypt",
            countryCode: "EG",
            countryName: "Egypt",
            company: nil,
            customerId: customerID,
            firstName: details.firstName,
            id: addressToEdit?.id,
            lastName: details.lastName,
            name: "\(details.firstName) \(details.lastName)",
            phone: details.phone,
            province: details.province.isEmpty ? "Cairo" : details.province,
            provinceCode: nil,
            zip: details.zip.isEmpty ? "11511" : details.zip,
            isDefault: details.isDefault
        )
        
        let publisher: AnyPublisher<Address, Error>
        if let _ = addressToEdit {
            publisher = editAddressUseCase.execute(customerID: customerID, address: editedAddress)
        } else {
            publisher = addAddressUseCase.execute(customerID: customerID, address: editedAddress)
        }
        
        publisher
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
                self?.showAddressForm = false
                self?.selectedCoordinate = nil
                self?.addressToEdit = nil
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
    func formattedFullAddress(_ address: Address) -> String? {
        let address1 = address.address1?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let city = address.city?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let combined = [address1, city].filter { !$0.isEmpty }.joined(separator: ", ")
        return combined.isEmpty ? nil : combined
    }
    func setAsDefault(_ address: Address) {
        guard let addressID = address.id else { return }
        
        setDefaultAddressUseCase.execute(customerID: customerID, addressID: addressID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error)
                    self?.allAddresses = self?.allAddresses.map {
                        var modified = $0
                        modified.isDefault = ($0.id == address.id) ? false : $0.isDefault
                        return modified
                    } ?? []
                }
            }, receiveValue: { [weak self] updatedAddress in
                self?.allAddresses = self?.allAddresses.map {
                    var modified = $0
                    modified.isDefault = ($0.id == updatedAddress.id)
                    return modified
                } ?? []
                self?.defaultAddress = updatedAddress
            })
            .store(in: &cancellables)
    }
    
    func deleteAddress(_ address: Address) {
        guard let addressID = address.id else { return }
        isDeleting = true
        let backup = allAddresses
        allAddresses = allAddresses.filter { $0.id != address.id }
        
        deleteAddressUseCase.execute(customerID: customerID, addressID: addressID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isDeleting = false
                if case let .failure(error) = completion {
                    self?.handleError(error)
                    self?.allAddresses = backup
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func editAddress(_ address: Address) {
        addressToEdit = address
        showAddressForm = true
    }
    func saveEditedAddress(_ input: AddressFormInput) {
        guard var address = addressToEdit else { return }

        address.firstName = input.firstName
        address.lastName = input.lastName
        address.phone = input.phone
        address.address1 = input.address1
        address.city = input.city
        address.province = input.province
        address.zip = input.zip
        address.isDefault = input.isDefault

        let backup = allAddresses
        if let index = allAddresses.firstIndex(where: { $0.id == address.id }) {
            allAddresses[index] = address
        }

        editAddressUseCase.execute(customerID: customerID, address: address)
            .flatMap { [weak self] updated -> AnyPublisher<Address, Error> in
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }

                if input.isDefault, let addressID = updated.id {
                    return self.setDefaultAddressUseCase.execute(customerID: self.customerID, addressID: addressID)
                }

                return Just(updated)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                    self?.allAddresses = backup
                }
                self?.showAddressForm = false
                self?.addressToEdit = nil
            }, receiveValue: { [weak self] updated in
                if (self?.allAddresses.firstIndex(where: { $0.id == updated.id })) != nil {
                    self?.allAddresses = self?.allAddresses.map {
                        var modified = $0
                        modified.isDefault = ($0.id == updated.id)
                        return modified
                    } ?? []
                    self?.defaultAddress = updated
                }
            })
            .store(in: &cancellables)
    }

    
    
    
    
    
}
