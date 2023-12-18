//
// Copyright © MAHESHWARAN. All rights reserved.
//

import Combine
import Foundation

public final class URLNetwork {
  
  public static let shared = URLNetwork()
  
  private let network = NetworkMonitor.shared
  
  private init() {
    _ = NetworkMonitor.shared
  }
  
  // MARK: - GET
  
  public func get<Output: Decodable>(
    _ url: URL,
    urlConfig config: URLSessionConfiguration? = nil,
    debugPrintEnabled: Bool = false,
    completion: @escaping (Result<Output, Error>) -> Void) {
      
      guard network.isActive else {
        completion(.failure(URLError(.notConnectedToInternet)))
        return
      }
      let session = URLSession(configuration: config ?? urlSessionConfiguration)
      
      session
        .dataTask(with: url) { [weak self] data, response, error in
          guard let self, error == nil else {
            completion(.failure(error ?? URLError(.badServerResponse)))
            return
          }
          guard let data else {
            completion(.failure(URLError(.cannotDecodeRawData)))
            return
          }
          do {
            if debugPrintEnabled {
              debugPrint(data.description)
            }
            let decoder = try defaultDecoder.decode(Output.self, from: data)
            completion(.success(decoder))
          } catch {
            completion(.failure(URLError(.cannotDecodeContentData)))
          }
        }
        .resume()
    }
  
  public func get<Output: Decodable>(
    _ url: URL,
    urlConfig config: URLSessionConfiguration? = nil,
    debugPrintEnabled: Bool = false) -> AnyPublisher<Output, Error> {
      
      guard network.isActive else {
        return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
      }
      let session = URLSession(configuration: config ?? urlSessionConfiguration)
      
      return session
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Output.self, decoder: defaultDecoder)
        .eraseToAnyPublisher()
    }
  
  // MARK: - POST
  
  public func post<Input: Encodable, Output: Decodable>(
    _ data: Input,
    to url: URL,
    httpMethod: HttpMethodType = .post,
    contentType: String = "application/json",
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
        .dataTask(with: request) { [weak self] data, response, error in
          guard let self, error == nil else {
            completion(.failure(error ?? URLError(.badServerResponse)))
            return
          }
          guard let data else {
            completion(.failure(URLError(.cannotDecodeRawData)))
            return
          }
          
          do {
            if debugPrintEnabled {
              debugPrint(data.description)
            }
            let decoder = try defaultDecoder.decode(Output.self, from: data)
            completion(.success(decoder))
          } catch {
            completion(.failure(URLError(.cannotDecodeContentData)))
          }
        }.resume()
    }
  
  public func post<Input: Encodable, Output: Decodable>(
    _ data: Input,
    to url: URL,
    httpMethod: HttpMethodType = .post,
    contentType: String = "application/json") -> AnyPublisher<Output, Error> {
      
      guard network.isActive else {
        return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
      }
      
      var request = URLRequest(url: url)
      request.httpMethod = httpMethod.type
      request.setValue(contentType, forHTTPHeaderField: "Content-Type")
      
      let encoder = JSONEncoder()
      request.httpBody = try? encoder.encode(data)
      
      return URLSession
        .shared
        .dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: Output.self, decoder: defaultDecoder)
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
  
  var defaultDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    
    return decoder
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
