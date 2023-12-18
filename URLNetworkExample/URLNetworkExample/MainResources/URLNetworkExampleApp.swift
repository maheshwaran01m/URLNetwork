//
//  URLNetworkExampleApp.swift
//  URLNetworkExample
//
//  Created by MAHESHWARAN on 18/12/23.
//

import SwiftUI
import URLNetwork

@main
struct URLNetworkExampleApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(NetworkMonitor.shared)
    }
  }
}
