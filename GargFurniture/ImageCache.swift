//
//  ImageCache.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 13/12/25.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 300          // max images
        cache.totalCostLimit = 50 * 1024 * 1024 // ~50MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}
