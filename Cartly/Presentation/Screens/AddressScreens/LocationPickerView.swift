import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 29.8717, longitude: 31.2729),
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showAlert = false
    @State private var alertMessage = ""

    let onLocationSelected: (CLLocationCoordinate2D) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    UserAnnotation()

                    if let coordinate = selectedCoordinate {
                        Annotation("Selected Location", coordinate: coordinate, anchor: .center) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        selectedCoordinate = coordinate
                    }
                }
                .mapControls {
                    MapCompass()
                    MapUserLocationButton()
                }
                .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Text("Select a location in Egypt")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 16)

                Spacer()

                if selectedCoordinate != nil {
                    Button(action: verifyLocation) {
                        Text("Confirm Location")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Location Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func verifyLocation() {
        guard let coordinate = selectedCoordinate else { return }

        if isLocationInsideEgypt(coordinate: coordinate) {
            selectedCoordinate = coordinate
            onLocationSelected(coordinate)
        } else {
            alertMessage = "Selected location is outside Egypt. Please choose a location within Egypt."
            showAlert = true
        }
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

#Preview {
    LocationPickerView { _ in }
}
