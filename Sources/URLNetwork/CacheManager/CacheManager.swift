//
//  CacheManager.swift
//
//
//  Created by MAHESHWARAN on 02/01/24.
//

import Combine
import Foundation

#if canImport(UIKit)
import UIKit

public typealias PlatformImage = UIImage
public typealias PlatformImageView = UIImageView
#endif

#if canImport(AppKit)
import AppKit

public typealias PlatformImage = NSImage
public typealias PlatformImageView = NSImageView
#endif

public final class CacheManager {
  
  public static let shared = CacheManager()
  
  private var cancelBag = Set<AnyCancellable>()
  
  private let imageCache = NSCache<NSString, PlatformImage>()
}

extension CacheManager {
  
  public func downloadImage(_ urlString: String, completion: @escaping (Result<PlatformImage, Error>) -> Void) {
    
    let cacheKey = NSString(string: urlString)
    
    if let image = imageCache.object(forKey: cacheKey) {
      completion(.success(image))
    } else {
      
      guard let url = URL(string: urlString) else { return }
      
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        
        let result: Result<PlatformImage, Error>
        
        defer { completion(result) }
        
        guard let self, error == nil else {
          result = .failure(URLError(.badServerResponse))
          return
        }
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
          result = .failure(URLError(.badServerResponse))
          return
        }
        guard let data, let image = PlatformImage(data: data) else {
          result = .failure(URLError(.dataNotAllowed))
          return
        }
        // cache image
        imageCache.setObject(image, forKey: cacheKey)
        
        result = .success(image)
      }.resume()
    }
  }
}

// MARK: - Get

public extension CacheManager {
  
  func getValue(_ key: String) -> PlatformImage? {
    guard let image = imageCache.object(forKey: cacheKey(key)) else { return nil }
    return image
  }
  
  func contains(_ key: String) -> Bool {
    return getValue(key) != nil
  }
  
  private func cacheKey(_ key: String) -> NSString {
    NSString(string: key)
  }
}

// MARK: - Clear Cache

public extension CacheManager {
  
  func clearImageCache() {
    imageCache.removeAllObjects()
  }
  
  func clearImageCache(forKey key: String) {
    imageCache.removeObject(forKey: cacheKey(key))
  }
}
