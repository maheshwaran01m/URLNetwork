//
//  User.swift
//  URLNetworkExample
//
//  Created by MAHESHWARAN on 18/12/23.
//

import Foundation

struct User: Codable {
  var id: String
  var name: String
  
  static let `default` = User(id: UUID().uuidString, name: "No Name")
}

struct APIResponse: Codable {
  let results: [Records]
}

struct Records: Codable, Identifiable {
  let id: Int
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case id = "artistId"
    case name = "artistName"
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(id, forKey: .id)
    try container.encode(name, forKey: .name)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
  }
}
