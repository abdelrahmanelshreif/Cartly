//
//  Addresses.swift
//  Cartly
//
//  Created by Khalid Amr on 01/06/2025.
//

import SwiftUI
import MapKit

struct Addresses: Identifiable {
    let id = UUID()
    let name: String
    let street: String
    let city: String
    let postalCode: String
    let coordinate: CLLocationCoordinate2D
}

struct AddressMapView: View {
    // Dummy address data
    let dummyAddress = Addresses(
        name: "Home",
        street: "123 Main Street",
        city: "San Francisco",
        postalCode: "94105",
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showingNewAddressSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Map Section
            Map(position: $cameraPosition) {
                Marker(dummyAddress.name, coordinate: dummyAddress.coordinate)
                    .tint(.blue)
            }
            .mapStyle(.standard)
            .frame(height: 300)
            .onAppear {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: dummyAddress.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
            
            // Address Details
            VStack(alignment: .leading, spacing: 12) {
                Text("CURRENT ADDRESS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dummyAddress.name)
                        .font(.headline)
                    Text(dummyAddress.street)
                    Text("\(dummyAddress.city), \(dummyAddress.postalCode)")
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: addNewAddress) {
                        Text("Add New")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    
                    Button(action: selectAddress) {
                        Text("Change")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(20)
            .offset(y: -40)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingNewAddressSheet) {
            Text("Add New Address Screen")
                .presentationDetents([.medium])
        }
    }
    
    private func addNewAddress() {
        showingNewAddressSheet = true
        print("Add New Address tapped")
    }
    
    private func selectAddress() {
        print("Select Address tapped")
        // Selection logic would go here
    }
}

struct AddressMapView_Previews: PreviewProvider {
    static var previews: some View {
        AddressMapView()
    }
}
