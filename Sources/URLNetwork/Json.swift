//
//  Json.swift
//
//
//  Created by MAHESHWARAN on 17/12/23.
//

import Foundation

@dynamicMemberLookup
public struct JSON: RandomAccessCollection {
  
  var value: Any?
  
  public var startIndex: Int { array.startIndex }
  public var endIndex: Int { array.endIndex }
  
  public init(string: String) throws {
    let data = Data(string.utf8)
    value = try JSONSerialization.jsonObject(with: data)
  }
  
  public init(value: Any?) {
    self.value = value
  }
  
  public var optionalBool: Bool? {
    value as? Bool
  }
  
  public var optionalDouble: Double? {
    value as? Double
  }
  
  public var optionalInt: Int? {
    value as? Int
  }
  
  public var optionalString: String? {
    value as? String
  }
  
  public var bool: Bool {
    optionalBool ?? false
  }
  
  public var double: Double {
    optionalDouble ?? 0
  }
  
  public var int: Int {
    optionalInt ?? 0
  }
  
  public var string: String {
    optionalString ?? ""
  }
  
  public var optionalArray: [JSON]? {
    let converted = value as? [Any]
    return converted?.map { JSON(value: $0) }
  }
  
  public var optionalDictionary: [String: JSON]? {
    let converted = value as? [String: Any]
    return converted?.mapValues { JSON(value: $0) }
  }
  
  public var array: [JSON] {
    optionalArray ?? []
  }
  
  public var dictionary: [String: JSON] {
    optionalDictionary ?? [:]
  }
  
  public subscript(index: Int) -> JSON {
    optionalArray?[index] ?? JSON(value: nil)
  }
  
  public subscript(key: String) -> JSON {
    optionalDictionary?[key] ?? JSON(value: nil)
  }
  
  public subscript(dynamicMember key: String) -> JSON {
    optionalDictionary?[key] ?? JSON(value: nil)
  }
}
