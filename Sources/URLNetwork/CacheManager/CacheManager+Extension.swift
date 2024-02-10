//
//  CacheManager+Extension.swift
//
//
//  Created by MAHESHWARAN on 02/01/24.
//

import Combine
import Foundation
import SwiftUI

extension PlatformImageView {
  
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
  
  public func getCachedImage(_ urlString: String?, completion: @escaping (Result<Image, Error>) -> Void) {
    
    guard let urlString else { return }
    
    CacheManager.shared.downloadImage(urlString) { image in
      
      let result: Result<Image, Error>
      
      defer { completion(result) }
      
      switch image {
      case .success(let uiImage):
        
#if os(macOS)
        result = .success(Image(nsImage: uiImage))
#else
        result = .success(Image(uiImage: uiImage))
#endif
        
      case .failure(let error):
        result = .failure(error)
      }
    }
  }
}
