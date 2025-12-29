import SwiftUI

struct ProductImageView: View {
    let urlString: String?

    @StateObject private var loader = ImageLoader()

    var body: some View {
        ZStack {
            // base grey background so kabhi full blank na lage
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))

            if let image = loader.image {
                // SUCCESS
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else if loader.isLoading {
                // LOADING
                ProgressView()
                    .scaleEffect(0.8)
            } else if loader.didFail {
                // FAILED after retries
                placeholder
            } else {
                // abhi tak load start hi nahi hua / invalid URL
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            startLoadingIfNeeded()
        }
        
    }

    private func startLoadingIfNeeded() {
        guard
            let raw = urlString?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !raw.isEmpty,
            raw.lowercased().hasPrefix("http"),
            let url = URL(string: raw)
        else {
            return
        }

        loader.load(from: url, maxRetries: 2)   // yaha retry count control kar sakta hai
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.gray.opacity(0.12))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 22))
                    .foregroundColor(.gray.opacity(0.6))
            )
    }
}
