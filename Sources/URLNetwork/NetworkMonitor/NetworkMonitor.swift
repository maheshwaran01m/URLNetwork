//
//  NetworkMonitor.swift
//  
//
//  Created by MAHESHWARAN on 18/12/23.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
  
  static let shared = NetworkMonitor()
  
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "network_Monitor")
  
  var isActive = false
  var isExpensive = false
  var isConstrained = false
  var connectionType = NWInterface.InterfaceType.other
  
  private init() {
    monitor.pathUpdateHandler = { [weak self] path in
      self?.updateStatus(using: path)
    }
    monitor.start(queue: queue)
  }
  
  private func updateStatus(using path: NWPath) {
    isActive = path.status == .satisfied
    isExpensive = path.isExpensive
    isConstrained = path.isConstrained
    
    let connectionTypes = [NWInterface.InterfaceType.cellular, .wifi, .wiredEthernet]
    self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
    
    DispatchQueue.main.async {
      self.objectWillChange.send()
    }
  }
}

extension NetworkMonitor: CustomStringConvertible, CustomDebugStringConvertible {
  
  var description: String {
    "Network: \(connectionType),  Status: \(isActive ? "Connected" : "Disconnected")"
  }
  
  var debugDescription: String {
    "Network: \(connectionType), Status: \(monitor.currentPath.status)"
  }
}
