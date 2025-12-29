
import SwiftUI
import FirebaseFirestore
import AVKit   // 👈 Video ke liye
import Combine
import AVFoundation


// MARK: - Video Banner Model

struct VideoBanner: Identifiable {
    let id = UUID()
    let videoName: String   // e.g. "video1" -> video1.mp4 in bundle
}

// Local video + image banners
private let videoBanners: [VideoBanner] = [
    VideoBanner(videoName: "video3"),
    VideoBanner(videoName: "video1"),
    VideoBanner(videoName: "video2")
    
    
    
]

// Banner (image) model already alag file me hai:
// struct Banner: Identifiable { let id = UUID(); let imageName: String }

private let banners: [Banner] = [
    Banner(imageName: "banner1"),
    Banner(imageName: "banner2"),
    Banner(imageName: "banner3")
]

struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var loading = true
    @State private var errorMessage = ""
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    // Image banner auto-slide
    @State private var currentBanner: Int = 0
    private let bannerTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    // automatic video banner rotation feature
    
    @State private var currentVideoIndex: Int = 0
        private let videoTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    
    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let db = Firestore.firestore()

    // Filtered products based on search
    private var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter { p in
            p.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        GFTheme.background,
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Group {
                    if loading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading products...")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(GFTheme.textSecondary)
                        }
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        VStack{
                            header
                            searchBar
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 18) {
                                    
                                    
                                    
                                    if !isSearching {
                                        VStack(spacing: 10) {
                                            videoBannerCarousel
                                            bannerCarousel
                                        }
                                        .transition(
                                            .asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .top)),
                                                removal: .opacity.combined(with: .move(edge: .top))
                                            )
                                        )
                                        VStack(alignment: .leading, spacing: 6) {Spacer()
                                            Spacer()
                                            Spacer()
                                            Text("Browse Products")
                                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                                .foregroundColor(GFTheme.textPrimary)
                                        }
                                    }
                                    
                                    // MARK: - Product grid
                                    if filteredProducts.isEmpty {
                                        Text("No products found.")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(GFTheme.textSecondary)
                                            .padding(.top, 24)
                                    } else {
                                        LazyVGrid(
                                            columns: [
                                                GridItem(.flexible(), spacing: 16),
                                                GridItem(.flexible(), spacing: 16)
                                            ],
                                            spacing: 18
                                        ) {
                                            ForEach(filteredProducts) { p in
                                                NavigationLink {
                                                    ProductDetailView(product: p)
                                                } label: {
                                                    ProductCardView(product: p)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.top, 8)
                                    }
                                   
                                }.animation(.easeInOut(duration: 0.25), value: isSearching)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 110)
                            }
                            .scrollDismissesKeyboard(.interactively)
                            .simultaneousGesture(
                                DragGesture().onChanged { _ in
                                    if isSearchFocused {
                                        isSearchFocused = false
                                    }
                                }
                            )
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("Garg Furniture")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(GFTheme.textPrimary)
                        }
                    }
                }
                .onAppear(perform: fetchProducts)
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Transform your space.")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(GFTheme.textPrimary)

            Text("Premium furniture & furnishings curated for you.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)
        }
        .padding(.top, 4)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSearchFocused ? GFTheme.primary : GFTheme.textSecondary)

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search sofas, beds, tables…")
                        .foregroundColor(GFTheme.textSecondary.opacity(0.6))
                        .font(.system(.subheadline, design: .rounded))
                }

                TextField("", text: $searchText)
                    .foregroundColor(GFTheme.textPrimary)
                    .font(.system(.subheadline, design: .rounded))
                    .disableAutocorrection(true)
                    .focused($isSearchFocused)
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(GFTheme.textSecondary.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)

        // width control
        .frame(maxWidth: 360)
        

        // 🎨 background + focus highlight
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    Group {
                        if isSearchFocused {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [GFTheme.primary, GFTheme.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.6
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    Color.gray.opacity(0.9),
                                    lineWidth: 1.2
                                )
                        }
                    }
                )
        )

        // 🌫️ glow when focused
        .shadow(
            color: isSearchFocused
                ? GFTheme.primary.opacity(0.25)
                : GFTheme.softShadow.color.opacity(0.3),
            radius: isSearchFocused ? 12 : 8,
            x: 0, y: isSearchFocused ? 6 : 4
        )

        .animation(.easeInOut(duration: 0.18), value: isSearchFocused)
        .padding(.top, 6)
    }
    // MARK: - VIDEO BANNER CAROUSEL (square)

    // MARK: - VIDEO BANNER CAROUSEL (square, full width)

    private var videoBannerCarousel: some View {
           let side = UIScreen.main.bounds.width - 32  // 16 + 16 padding

           return TabView(selection: $currentVideoIndex) {          // <- selection binding here
               ForEach(Array(videoBanners.enumerated()), id: \.element.id) { idx, banner in
                   VideoBannerView(banner: banner)
                       .frame(width: side, height: side)   // square frame
                       .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                       .shadow(color: GFTheme.softShadow.color.opacity(0.45),
                               radius: 14, x: 0, y: 6)
                       .padding(.horizontal, 2)
                       .tag(idx) // important: tag with index for selection binding
               }
           }
           .frame(height: side)
           .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
           // Advance video index every 10s
           .onReceive(videoTimer) { _ in
               guard !videoBanners.isEmpty else { return }
               withAnimation {
                   currentVideoIndex = (currentVideoIndex + 1) % videoBanners.count
               }
           }
       }

    // MARK: - IMAGE BANNER CAROUSEL (rectangle, auto slide)

    private var bannerCarousel: some View {
        TabView(selection: $currentBanner) {
            ForEach(0..<banners.count, id: \.self) { index in
                Image(banners[index].imageName)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
                    .clipped()
                    .cornerRadius(18)
                    .shadow(color: GFTheme.softShadow.color.opacity(0.4),
                            radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 2)
                    .tag(index)
            }
        }
        .frame(height: 170)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onReceive(bannerTimer) { _ in
            withAnimation {
                currentBanner = (currentBanner + 1) % banners.count
            }
        }
    }

    // MARK: - Helpers

    func formattedPrice(_ cents: Int) -> String {
        let rupees = Double(cents) / 100
        return String(format: "%.0f", rupees)
    }

    func fetchProducts() {
        db.collection("products").order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.loading = false
                    return
                }

                guard let docs = snapshot?.documents else {
                    self.loading = false
                    return
                }

                self.products = docs.compactMap { doc in
                    let data = doc.data()

                    guard
                        let name = data["name"] as? String,
                        let price = data["price_cents"] as? Int,
                        let currency = data["currency"] as? String,
                        let desc = data["description"] as? String,
                        let stock = data["stock"] as? Int
                    else {
                        print("Skipping invalid product document \(doc.documentID)")
                        return nil
                    }

                    return Product(
                        id: doc.documentID,
                        name: name,
                        price_cents: price,
                        currency: currency,
                        description: desc,
                        imageUrl: data["imageUrl"] as? String,
                        stock: stock
                    )
                }

                self.loading = false
            }
    }
}

// MARK: - Video Banner View

struct VideoBannerView: View {
    let banner: VideoBanner

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        ZStack {
            if let player = player {
                VideoFillView(player: player)
                    .allowsHitTesting(false)   // koi tap action nahi
            } else {
                Color.black.opacity(0.05)
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            // ⚠️ Agar player already hai (swipe se wapas aaye) → bas play kar do
            if let p = player {
                p.play()
                return
            }

            // First time init
            guard let url = Bundle.main.url(forResource: banner.videoName,
                                            withExtension: "mp4") else {
                print("⚠️ Video not found in bundle:", banner.videoName)
                return
            }

            let item = AVPlayerItem(url: url)

            // 🔁 Looping queue player
            let queuePlayer = AVQueuePlayer(playerItem: item)
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)

            queuePlayer.isMuted = true
            queuePlayer.play()

            self.player = queuePlayer     // strong references
            self.looper = looper
        }
        .onDisappear {
            // screen se hatne par pause
            player?.pause()
        }
    }
}
// MARK: - Product Card View (same as before)

struct ProductCardView: View {
    let product: Product

    private var displayPrice: String {
        let rupees = Double(product.price_cents) / 100.0
        return String(format: "₹%.0f", rupees)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                ProductImageView(urlString: product.imageUrl)
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(16)

                Text(displayPrice)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [GFTheme.primary, GFTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(999)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(GFTheme.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free delivery • 3–5 days")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary.opacity(0.9))
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .gfCard()
    }
}

struct VideoFillPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill   // 👈 no black bars, full fill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            layer.player = player
            layer.frame = uiView.bounds
        }
    }
}
struct VideoFillView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill  // 👈 full fill, no black bars
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// Custom UIView jisme layer hi AVPlayerLayer hai
class PlayerContainerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds  // frame change hote hi video resize ho jaayega
    }
}
