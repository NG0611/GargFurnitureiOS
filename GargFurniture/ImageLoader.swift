//
//  ImageLoader.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 26/11/25.
//

import SwiftUI
import Combine

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var didFail = false

    private var currentTask: URLSessionDataTask?
    private var currentURL: URL?

    func load(from url: URL, maxRetries: Int = 2) {

        // 🔥 SAME URL? don't reload
        if currentURL == url, image != nil { return }

        currentURL = url
        didFail = false

        // 🔥 MEMORY CACHE FIRST
        if let cached = ImageCache.shared.image(for: url) {
            self.image = cached
            self.isLoading = false
            return
        }

        isLoading = true

        let request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy, // ✅ allow URLCache
            timeoutInterval: 15
        )

        currentTask?.cancel()

        currentTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }

                if let _ = error {
                    self.retryOrFail(url: url, retries: maxRetries)
                    return
                }

                guard
                    let data,
                    let image = UIImage(data: data)
                else {
                    self.retryOrFail(url: url, retries: maxRetries)
                    return
                }

                // ✅ STORE IN CACHE
                ImageCache.shared.insert(image, for: url)

                self.image = image
                self.isLoading = false
                self.didFail = false
            }
        }

        currentTask?.resume()
    }

    private func retryOrFail(url: URL, retries: Int) {
        if retries > 0 {
            load(from: url, maxRetries: retries - 1)
        } else {
            self.isLoading = false
            self.didFail = true
        }
    }

    deinit {
        currentTask?.cancel()
    }
}
