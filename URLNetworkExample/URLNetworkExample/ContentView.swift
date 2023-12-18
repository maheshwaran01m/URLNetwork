//
//  ContentView.swift
//  URLNetworkExample
//
//  Created by MAHESHWARAN on 18/12/23.
//

import SwiftUI

struct ContentView: View {
  
  @StateObject private var viewModel = NetworkViewModel()
  
  var body: some View {
    NavigationStack {
      List(viewModel.records) { record in
        VStack(alignment: .leading, spacing: 8) {
          Text(record.id.description)
          Text(record.name)
        }
      }
      .safeAreaInset(edge: .bottom, content: bottomView)
      .background(Color(uiColor: UIColor.secondarySystemBackground))
      .alert("Error", isPresented: errorBinding) {
        Button("Ok") {}
      } message: {
        Text(viewModel.errorMessage ?? "")
      }
      .navigationTitle("Example")
    }
  }
  
  func bottomView() -> some View {
    HStack {
      Button("Post", action: viewModel.postRequest)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.yellow.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
      
      Button("Get", action: viewModel.getRequest)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
    .background(Color(uiColor: UIColor.systemBackground))
  }
  
  var errorBinding: Binding<Bool> {
    .init(get: {
      viewModel.errorMessage != nil
    }, set: { value in
      if !value {
        viewModel.errorMessage = nil
      }
    })
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
