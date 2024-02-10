//
// Copyright © MAHESHWARAN. All rights reserved.
//

import Combine
import Foundation

public final class URLNetwork {
  
  public static let shared = URLNetwork()
  
  private let network = NetworkMonitor.shared
  
  private init() {}
  
  // MARK: - GET
  
  public func get<Output: Decodable>(
    _ url: URL,
    urlConfig config: URLSessionConfiguration? = nil,
    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .iso8601,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
    debugPrintEnabled: Bool = false,
    completion: @escaping (Result<Output, Error>) -> Void) {
      
      guard network.isActive else {
        completion(.failure(URLError(.notConnectedToInternet)))
        return
      }
      let session = URLSession(configuration: config ?? urlSessionConfiguration)
      
      session
        .dataTask(with: url) { data, response, error in
          
          let result: Result<Output, Error>
          
          defer { completion(result) }
          
          guard error == nil else {
            result = .failure(error ?? URLError(.badServerResponse))
            return
          }
          guard let data else {
            result = .failure(URLError(.cannotDecodeRawData))
            return
          }
          do {
            if debugPrintEnabled {
              print(try JSONSerialization.jsonObject(with: data))
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = dateDecodingStategy
            jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
            
            let decoder = try jsonDecoder.decode(Output.self, from: data)
            result = .success(decoder)
          } catch {
            result = .failure(URLError(.cannotDecodeContentData))
          }
        }
        .resume()
    }
  
  public func get<Output: Decodable>(
    _ url: URL,
    urlConfig config: URLSessionConfiguration? = nil,
    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .iso8601,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
    debugPrintEnabled: Bool = false) -> AnyPublisher<Output, Error> {
      
      guard network.isActive else {
        return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
      }
      let session = URLSession(configuration: config ?? urlSessionConfiguration)
      
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = dateDecodingStategy
      jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
      
      return session
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Output.self, decoder: jsonDecoder)
        .eraseToAnyPublisher()
    }
  
  // MARK: - POST
  
  public func post<Input: Encodable, Output: Decodable>(
    _ data: Input,
    to url: URL,
    httpMethod: HttpMethodType = .post,
    contentType: String = "application/json",
    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .iso8601,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
    debugPrintEnabled: Bool = false,
    completion: @escaping (Result<Output, Error>) -> Void) {
      
      guard network.isActive else {
        completion(.failure(URLError(.notConnectedToInternet)))
        return
      }
      
      var request = URLRequest(url: url)
      request.httpMethod = httpMethod.type
      request.setValue(contentType, forHTTPHeaderField: "Content-Type")
      
      let encoder = JSONEncoder()
      request.httpBody = try? encoder.encode(data)
      
      URLSession
        .shared
        .dataTask(with: request) { data, response, error in
          
          let result: Result<Output, Error>
          
          defer { completion(result) }
          
          guard error == nil else {
            result = .failure(error ?? URLError(.badServerResponse))
            return
          }
          guard let data else {
            result = .failure(URLError(.cannotDecodeRawData))
            return
          }
          
          do {
            if debugPrintEnabled {
              print(try JSONSerialization.jsonObject(with: data))
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = dateDecodingStategy
            jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
            
            let decoder = try jsonDecoder.decode(Output.self, from: data)
            result = .success(decoder)
          } catch {
            result = .failure(URLError(.cannotDecodeContentData))
          }
        }.resume()
    }
  
  public func post<Input: Encodable, Output: Decodable>(
    _ data: Input,
    to url: URL,
    httpMethod: HttpMethodType = .post,
    contentType: String = "application/json",
    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .iso8601,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> AnyPublisher<Output, Error> {
      
      guard network.isActive else {
        return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
      }
      
      var request = URLRequest(url: url)
      request.httpMethod = httpMethod.type
      request.setValue(contentType, forHTTPHeaderField: "Content-Type")
      
      let encoder = JSONEncoder()
      request.httpBody = try? encoder.encode(data)
      
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = dateDecodingStategy
      jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
      
      return URLSession
        .shared
        .dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: Output.self, decoder: jsonDecoder)
        .eraseToAnyPublisher()
    }
}

public extension URLNetwork {
  
  var urlSessionConfiguration: URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.allowsExpensiveNetworkAccess = false
    config.allowsConstrainedNetworkAccess = false
    config.waitsForConnectivity = true
    
    return config
  }
}

extension URLNetwork {
  
  public enum HttpMethodType {
    case get, post, patch, delete
    
    public var type: String {
      switch self {
      case .get: return "GET"
      case .post: return "POST"
      case .patch: return "PATCH"
      case .delete: return "DELETE"
      }
    }
  }
}
