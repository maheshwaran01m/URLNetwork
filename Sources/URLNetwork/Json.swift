//
//  Json.swift
//
//
//  Created by MAHESHWARAN on 17/12/23.
//

import Foundation

@dynamicMemberLookup
public struct JSON {
  
  private var value: Any
  
  public init(string: String) {
    do {
      let data = Data(string.utf8)
      value = try JSONSerialization.jsonObject(with: data)
    } catch {
      value = NSNull()
    }
  }
  
  public init(_ value: Any? = nil) {
    self.value = value ?? NSNull()
  }
  
  public init(_ data: Data, options opt: JSONSerialization.ReadingOptions = []) {
    do {
      let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
      value = object
    } catch {
      value = NSNull()
    }
  }
}

extension JSON {
  
  public var optionalBool: Bool? {
    get {
      value as? Bool
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var optionalDouble: Double? {
    get {
      value as? Double
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var optionalInt: Int? {
    get {
      value as? Int
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var optionalString: String? {
    get {
      value as? String
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var bool: Bool {
    get {
      optionalBool ?? false
    } set {
      value = newValue
    }
  }
  
  public var double: Double {
    get {
      optionalDouble ?? 0
    } set {
      value = newValue
    }
  }
  
  public var int: Int {
    get {
      optionalInt ?? 0
    } set {
      value = newValue
    }
  }
  
  public var string: String {
    get {
      optionalString ?? ""
    } set {
      value = newValue
    }
  }
  
  public var optionalArray: [JSON]? {
    get {
      let converted = value as? [Any]
      return converted?.map { JSON($0) }
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var optionalDictionary: [String: JSON]? {
    get {
      let converted = value as? [String: Any]
      return converted?.mapValues { JSON($0) }
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var array: [JSON] {
    get {
      optionalArray ?? []
    } set {
      value = newValue
    }
  }
  
  public var dictionary: [String: JSON] {
    get {
      optionalDictionary ?? [:]
    } set {
      value = newValue
    }
  }
  
 public  var rawDictionary: [String: Any] {
    get {
      return value as? [String: Any] ?? [:]
    } set {
      value = newValue
    }
  }
  
  public var optionalDate: Date? {
    get {
      return value as? Date
    } set {
      value = newValue ?? NSNull()
    }
  }
  
  public var date: Date {
    get {
      return optionalDate ?? Date()
    } set {
      value = newValue
    }
  }
}

extension JSON: RandomAccessCollection {
  
  public var startIndex: Int {
    array.startIndex
  }
  public var endIndex: Int {
    array.endIndex
  }
  
  public subscript(index: Int) -> JSON {
    optionalArray?[index] ?? JSON()
  }
  
  public subscript(key: String) -> JSON {
    optionalDictionary?[key] ?? JSON()
  }
  
  public subscript(dynamicMember key: String) -> JSON {
    optionalDictionary?[key] ?? JSON()
  }
}

extension JSON {
  
  public var url: URL? {
    get {
      
      if !string.isEmpty && string.range(
        of: "%[0-9A-Fa-f]{2}",
        options: .regularExpression, range: nil, locale: nil) != nil {
        return URL(string: self.string)
        
      } else if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        return URL(string: encodedString)
        
      } else {
        return nil
      }
    }
    set {
      value = newValue?.absoluteString ?? NSNull()
    }
  }
}

extension JSON: Codable {
  
  private static var codableTypes: [Codable.Type] {
    [ Bool.self, Int.self, Int8.self, Int16.self, Int32.self, Int64.self,
      UInt.self, UInt8.self, UInt16.self, UInt32.self, UInt64.self, Double.self,
      String.self, [JSON].self, [String: JSON].self
    ]
  }
  
  public init(from decoder: Decoder) throws {
    var object: Any?
    
    if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
      for type in JSON.codableTypes {
         if object != nil { break }
        
        switch type {
        case let boolType as Bool.Type:
          object = try? container.decode(boolType)
        case let intType as Int.Type:
          object = try? container.decode(intType)
        case let int8Type as Int8.Type:
          object = try? container.decode(int8Type)
        case let int32Type as Int32.Type:
          object = try? container.decode(int32Type)
        case let int64Type as Int64.Type:
          object = try? container.decode(int64Type)
        case let uintType as UInt.Type:
          object = try? container.decode(uintType)
        case let uint8Type as UInt8.Type:
          object = try? container.decode(uint8Type)
        case let uint16Type as UInt16.Type:
          object = try? container.decode(uint16Type)
        case let uint32Type as UInt32.Type:
          object = try? container.decode(uint32Type)
        case let uint64Type as UInt64.Type:
          object = try? container.decode(uint64Type)
        case let doubleType as Double.Type:
          object = try? container.decode(doubleType)
        case let stringType as String.Type:
          object = try? container.decode(stringType)
        case let jsonValueArrayType as [JSON].Type:
          object = try? container.decode(jsonValueArrayType)
        case let jsonValueDictType as [String: JSON].Type:
          object = try? container.decode(jsonValueDictType)
        default:
          break
        }
      }
    }
    self.init(object ?? NSNull())
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if value is NSNull {
      try container.encodeNil()
      return
    }
    switch value {
    case let intValue as Int: try container.encode(intValue)
    case let int8Value as Int8: try container.encode(int8Value)
    case let int32Value as Int32: try container.encode(int32Value)
    case let int64Value as Int64: try container.encode(int64Value)
    case let uintValue as UInt: try container.encode(uintValue)
    case let uint8Value as UInt8: try container.encode(uint8Value)
    case let uint16Value as UInt16: try container.encode(uint16Value)
    case let uint32Value as UInt32: try container.encode(uint32Value)
    case let uint64Value as UInt64: try container.encode(uint64Value)
    case let doubleValue as Double: try container.encode(doubleValue)
    case let boolValue as Bool: try container.encode(boolValue)
    case let stringValue as String: try container.encode(stringValue)
    case is [Any]:
      let jsonValueArray = array
      try container.encode(jsonValueArray)
    case is [String: Any]:
      let jsonValueDictValue = dictionary
      try container.encode(jsonValueDictValue)
    default:
      break
    }
  }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
  
  public var description: String {
    return rawString() ?? ""
  }
  
  public var debugDescription: String {
    description
  }
  
  fileprivate func rawString() -> String? {
    switch value {
    case let string as String: return string.description
    case let bool as Bool: return "\(bool)"
    case let int as Int: return int.description
    case let number as NSNumber: return number.description
    case let double as Double: return double.description
    case let float as Float: return float.description
    case let array as [Any]:
      let stringValue = array.map { value in
       let nestedValue = JSON(value)
        guard let string = nestedValue.rawString() else {
          return ""
        }
        if !string.isEmpty {
          return "\"\(string.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
        } else {
          return string
        }
      }
      return "[\(stringValue.joined(separator: ","))]"
      
    case let dictionary as [String: Any]:
      guard let dict = value as? [String: Any?] else {
        return nil
      }
      
      let body = dict.keys.map { key -> String in
        guard let value = dict[key] else {
          return "\"\(key)\": null"
        }
        guard let unwrappedValue = value else {
          return "\"\(key)\": null"
        }
        
        let nestedValue = JSON(unwrappedValue)
        guard let nestedString = nestedValue.rawString() else {
          return ""
        }
        if !nestedString.isEmpty {
          return "\"\(key)\": \"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
        } else {
          return "\"\(key)\": \(nestedString)"
        }
      }
      return "{\(body.joined(separator: ","))}"
      
    default: return nil
    }
  }
}
