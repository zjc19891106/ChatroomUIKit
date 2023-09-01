//
//  ImageCacheManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import Foundation
import UIKit
import Combine

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory = NSTemporaryDirectory() + "ImageCache/"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        createCacheDirectory()
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] out in
                self?.memoryCache.removeAllObjects()
            }
            .store(in: &cancellables)
    }
    
    private func createCacheDirectory() {
        do {
            try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create cache directory: \(error)")
        }
    }
    
    private func cachePath(for key: String) -> String {
        return cacheDirectory + key.replacingOccurrences(of: "/", with: "-")
    }
    
    func image(for key: String) -> UIImage? {
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Check disk cache
        let filePath = cachePath(for: key)
        if fileManager.fileExists(atPath: filePath) {
            if let data = fileManager.contents(atPath: filePath), let image = UIImage(data: data) {
                // Cache the image to memory
                memoryCache.setObject(image, forKey: key as NSString)
                return image
            }
        }
        
        return nil
    }
    
    func cacheImage(_ image: UIImage, for key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        
        // Save image to disk cache
        let filePath = cachePath(for: key)
        if let data = image.pngData()  {
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
    }
    
    
}
