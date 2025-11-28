//
//  NetworkMonitor.swift
//  Offleaf
//
//  Network connectivity monitoring
//

import Network
import SwiftUI
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.offleaf.networkmonitor")
    
    @Published var isConnected = true
    @Published var connectionType = NWInterface.InterfaceType.other
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.filter { 
                    path.usesInterfaceType($0.type) 
                }.first?.type ?? .other
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    var connectionDescription: String {
        if !isConnected {
            return "No Connection"
        }
        
        switch connectionType {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        default:
            return "Connected"
        }
    }
}