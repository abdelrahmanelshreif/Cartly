//
//  NetworkMonitor.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
        
        private let monitor = NWPathMonitor()
        private let queue = DispatchQueue(label: "ReachabilityMonitor")

        init() {
            monitor.pathUpdateHandler = { [weak self] path in
                DispatchQueue.main.async {
                    self?.isConnected = path.status == .satisfied
                }
            }
            monitor.start(queue: queue)
        }

        deinit {
            monitor.cancel()
        }
}

