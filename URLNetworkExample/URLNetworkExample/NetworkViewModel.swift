//
//  NetworkViewModel.swift
//  URLNetworkExample
//
//  Created by MAHESHWARAN on 18/12/23.
//

import SwiftUI
import Combine
import URLNetwork

class NetworkViewModel: ObservableObject {
  
  @Published var records = [Records]()
  @Published var errorMessage: String?
  
  private var cancelbag = Set<AnyCancellable>()
  
  func getRequest() {
    let url = URL(string: "https://itunes.apple.com/search?media=music&term=astrid.s")!
    URLNetwork.shared
      .get(url) { [weak self] (result: Result<APIResponse, Error>) in
        switch result {
        case .success(let data):
          DispatchQueue.main.async {
            guard let self else { return }
            self.records = data.results
          }
        case .failure(let error):
          self?.errorMessage = error.localizedDescription
        }
      }
  }
  
  func postRequest() {
    let user = User(id: UUID().uuidString, name: "apple")
    let url = URL(string: "https://reqres.in/api/users")!
    
    URLNetwork
      .shared
      .post(user, to: url) { [weak self] (result: Result<User, Error>) in
        switch result {
        case .success(let data):
          print(data)
        case .failure(let error):
          self?.errorMessage = error.localizedDescription
        }
      }
  }
}
