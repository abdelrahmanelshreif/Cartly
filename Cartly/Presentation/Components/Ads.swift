//
//  Ads.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//
import SwiftUI

struct Ads: View {
    @ObservedObject var viewModel: PriceRulesViewModel
    let timerInterval: TimeInterval = 3
    @State private var timer: Timer?

    init() {
        self.viewModel = PriceRulesViewModel(useCase: GetPriceRulesUseCase(repository: PriceRuleRepository(networkService: AdsNetworkService())))
    }
    var body: some View {
        ZStack {
            VStack {
                if viewModel.priceRules.isEmpty {
                    ProgressView("Loading ads...")
                        .frame(height: 250)
                } else {
                    TabView(selection: $viewModel.currentIndex) {
                        ForEach(viewModel.priceRules.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: viewModel.priceRules[index].image_url)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0/255, green: 32/255, blue: 96/255), lineWidth: 4)
                            )
                            .cornerRadius(12)
                            .padding(12)
                            .tag(index)
                            .onTapGesture {
                                viewModel.copyCode(for: index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 250)
                    .onAppear { startTimer() }
                    .onDisappear { stopTimer() }

                    // Dots
                    HStack(spacing: 8) {
                        ForEach(viewModel.priceRules.indices, id: \.self) { index in
                            Circle()
                                .fill(index == viewModel.currentIndex ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                }
            }

            // Toast
            if viewModel.showToast {
                VStack {
                    Spacer()
                    Text("Discount Code Copied to the Clipboard")
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.showToast)
                }
            }
        }
        .onChange(of: viewModel.currentIndex, initial: false) { _, newValue in
            if newValue >= viewModel.priceRules.count {
                viewModel.currentIndex = 0
            } else if newValue < 0 {
                viewModel.currentIndex = viewModel.priceRules.count - 1
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            withAnimation {
                viewModel.currentIndex = (viewModel.currentIndex + 1) % max(viewModel.priceRules.count, 1)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


#Preview {
    Ads()
}
