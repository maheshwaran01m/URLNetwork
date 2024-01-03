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
#endif

#if canImport(AppKit)
import AppKit
#endif

public final class CacheManager {
  
  public static let shared = CacheManager()
  
  private var cancelBag = Set<AnyCancellable>()
  
#if os(macOS)
  private let nsImageCache = NSCache<NSString, NSImage>()
#else
  private let uiImageCache = NSCache<NSString, UIImage>()
#endif
}

extension CacheManager {
  
#if os(macOS)
  public func downloadImage(_ urlString: String, completion: @escaping (Result<NSImage, Error>) -> Void) {
    
    let cacheKey = NSString(string: urlString)
    
    if let image = nsImageCache.object(forKey: cacheKey) {
      completion(.success(image))
    } else {
      
      guard let url = URL(string: urlString) else { return }
      
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self, error == nil else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let data, let image = NSImage(data: data) else {
          completion(.failure(URLError(.dataNotAllowed)))
          return
        }
        // cache image
        nsImageCache.setObject(image, forKey: cacheKey)
        
        completion(.success(image))
      }.resume()
    }
  }
  #else
  
  public func downloadImage(_ urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
    
    let cacheKey = NSString(string: urlString)
    
    if let image = uiImageCache.object(forKey: cacheKey) {
      completion(.success(image))
    } else {
      
      guard let url = URL(string: urlString) else { return }
      
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self, error == nil else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let data, let image = UIImage(data: data) else {
          completion(.failure(URLError(.dataNotAllowed)))
          return
        }
        // cache image
        uiImageCache.setObject(image, forKey: cacheKey)
        
        completion(.success(image))
      }.resume()
    }
  }
#endif
}

// MARK: - Get

public extension CacheManager {
  
#if os(macOS)
  func getValue(_ key: String) -> NSImage? {
    guard let image = nsImageCache.object(forKey: cacheKey(key)) else { return nil }
    return image
  }
#else
  func getValue(_ key: String) -> UIImage? {
    guard let image = uiImageCache.object(forKey: cacheKey(key)) else { return nil }
    return image
  }
#endif
  
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
#if os(macOS)
    nsImageCache.removeAllObjects()
#else
    uiImageCache.removeAllObjects()
#endif
  }
  
  func clearImageCache(forKey key: String) {
#if os(macOS)
    nsImageCache.removeObject(forKey: cacheKey(key))
#else
    uiImageCache.removeObject(forKey: cacheKey(key))
#endif
  }
}
