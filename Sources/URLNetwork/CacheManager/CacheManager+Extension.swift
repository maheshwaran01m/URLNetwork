//
//  CacheManager+Extension.swift
//  
//
//  Created by MAHESHWARAN on 02/01/24.
//

import Combine
import Foundation
import SwiftUI

#if os(macOS)
import AppKit

extension NSImageView {
  
  public func getCachedImage(_ urlString: String?) {
    guard let urlString else { return }
    
    CacheManager.shared.downloadImage(urlString) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let image):
        DispatchQueue.main.async {
          self.image = image
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}

extension Image {
  
  public func getCachedImage(_ urlString: String?) -> Image? {
    guard let urlString else { return nil }
    
    var image: Image?
    
    CacheManager.shared.downloadImage(urlString) { result in
      
      switch result {
      case .success(let uiImage):
        image = Image(nsImage: uiImage)
        
      case .failure(let error):
        print(error.localizedDescription)
        image = nil
      }
    }
    return image
  }
}
#else

import UIKit

extension UIImageView {
  
  public func getCachedImage(_ urlString: String?) {
    guard let urlString else { return }
    
    CacheManager.shared.downloadImage(urlString) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let image):
        DispatchQueue.main.async {
          self.image = image
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}

extension Image {
  
  public func getCachedImage(_ urlString: String?) -> Image? {
    guard let urlString else { return nil }
    
    var image: Image?
    
    CacheManager.shared.downloadImage(urlString) { result in
      
      switch result {
      case .success(let uiImage):
        image = Image(uiImage: uiImage)
        
      case .failure(let error):
        print(error.localizedDescription)
        
      }
    }
    return image
  }
}

#endif
