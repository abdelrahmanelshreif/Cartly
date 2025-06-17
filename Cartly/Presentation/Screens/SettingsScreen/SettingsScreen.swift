import SwiftUI

import SwiftUI

struct SettingsScreen: View {
    @StateObject var viewModel = SettingsViewModel()
    @State private var isTransitioning = false
    @ObservedObject var currencyManager = CurrencyManager.shared

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: Binding(
                        get: { viewModel.isDarkMode },
                        set: { newValue in
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isTransitioning = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                viewModel.toggleDarkMode(newValue)
                                isTransitioning = false
                            }
                        }
                    )) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }

                Section(header: Text("Currency")) {
                    Picker(selection: $viewModel.selectedCurrency, label: Label("Currency", systemImage: "dollarsign.circle.fill")) {
                        Text("EGP").tag("EGP")
                        Text("USD").tag("USD")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedCurrency) { _ in
                        currencyManager.fetchConversionRate()
                    }

                    if currencyManager.isLoading {
                        ProgressView()
                    } else if viewModel.selectedCurrency != "EGP" {
                        Text("1 EGP = \(String(format: "%.4f", currencyManager.conversionRate)) \(viewModel.selectedCurrency)")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    NavigationLink(destination: ContactUsScreen()) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }

                    NavigationLink(destination: AboutUsScreen()) {
                        Label("About Us", systemImage: "info.circle.fill")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
        .overlay(
            Color(viewModel.isDarkMode ? .white : .black)
                .opacity(isTransitioning ? 1 : 0)
                .animation(.easeInOut(duration: 0.4), value: isTransitioning)
                .ignoresSafeArea()
        )
        .onAppear {
            currencyManager.fetchConversionRate()
        }
    }
}
struct ContactUsScreen: View {
    var body: some View {
        Text("Contact Us")
            .navigationTitle("Contact Us")
    }
}

struct AboutUsScreen: View {
    var body: some View {
        Text("About Us")
            .navigationTitle("About Us")
    }
}

#Preview {
    SettingsScreen(
        viewModel: SettingsViewModel(
            
        )
    )
}
