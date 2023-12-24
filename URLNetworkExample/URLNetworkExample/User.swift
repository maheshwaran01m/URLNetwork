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
  let song: String?
  
  enum CodingKeys: String, CodingKey {
    case id = "artistId"
    case name = "artistName"
    case song = "collectionCensoredName"
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(song, forKey: .song)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.song = try container.decode(String.self, forKey: .song)
  }
}

// MARK: - ObservableObject

class People: Codable, ObservableObject {
  
  @Published var title = "Hello"
  @Published var sequence = 0
  
  init(title: String, sequence: Int) {
    self.title = title
    self.sequence = sequence
  }
  
  enum CodingKeys: String, CodingKey {
    case title, sequence
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    sequence = try container.decode(Int.self, forKey: .sequence)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(title, forKey: .title)
    try container.encode(sequence, forKey: .sequence)
  }
}

// MARK: - Custom Decoder

struct Article: Decodable {
  
  struct Feed: Decodable {
    let publisher: String
    let country: String
  }
  
  struct Entry: Decodable {
    let author: String
  }
  
  enum CodingKeys: String, CodingKey {
    case feed, entry
  }
  
  let feed: Feed
  var entry: [Entry]
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    feed = try container.decode(Feed.self, forKey: .feed)
    do {
      entry = try container.decode([Entry].self, forKey: .entry)
    } catch {
      let value = try container.decode(Entry.self, forKey: .entry)
      entry = [value]
    }
  }
}
