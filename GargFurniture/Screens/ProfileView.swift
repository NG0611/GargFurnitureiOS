import SwiftUI
import FirebaseFirestore


import AVKit   // 👈 Video ke liye
import Combine
import AVFoundation

struct videoBanner: Identifiable {
    let id = UUID()
    let videoName: String   // e.g. "video1" -> video1.mp4 in bundle
}
private let videoBanners: [videoBanner] = [
    videoBanner(videoName: "profile_bg")
   
    
]

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore

    @State private var editingName: String = ""
    @State private var editingPhone: String = ""
    @State private var error: String = ""

    // Address edit / add
    @State private var selectedAddressForEdit: Address? = nil
    @State private var showAddAddressSheet: Bool = false
    
    @State private var currentVideoIndex: Int = 0
        private let videoTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    var body: some View {
       
        NavigationStack {
            
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
                
                // Tap to hide keyboard
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                
                
                   
                    
                    
                    ScrollView {
                        
                        
                        VStack(spacing: 18) {
                            videoBannerCarousel
                                .padding(.top, 5)
                            
                            
                            if let profile = session.user {
                                profileHeader(profile).padding(.top,10)
                            } else {
                                Text("Loading profile...")
                                    .foregroundColor(GFTheme.textSecondary)
                                    .padding()
                            }
                            
                            
                            accountDetailsCard
                            
                            addressesCard
                            
                            logoutCard
                            
                            VStack {
                                   Spacer()
//                                   Text("GARG\nFURNITURE")
//                                       .font(.system(size: 36, weight: .bold, design: .rounded))
//                                       .tracking(3)                               // letter spacing
//                                       .foregroundColor(Color(white: 0.45))
//                                       .opacity(0.8)
//                                       .padding(.bottom,30)
//                                       .allowsHitTesting(false)
                                
                                Spacer()
                                Spacer()
                                Text("Crafted with 💖 by Nikunj Garg")
                                    .font(.custom("ShadowsIntoLight", size: 28))
                                    .foregroundColor(Color(white: 0.45))
                                    .shadow(color: Color.black.opacity(0.16), radius: 0.7, x: 0.6, y: 0.6)

                                    .opacity(0.8)
                                    
                                    .padding(.bottom, 110)
                                    .allowsHitTesting(false)
                                
                                
                               }
                            
                            
                            if !error.isEmpty {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.system(.footnote, design: .rounded))
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 110)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.endEditing()
                        }
                    )
                
                    
                
                }
            .navigationTitle("Profile").font(.system(.headline, design: .rounded)).foregroundColor(GFTheme.textPrimary)
            
                .navigationBarTitleDisplayMode(.inline)
                
                
                .onAppear {
                    syncFromSession()
                    
                    // temperorary code
                    for family in UIFont.familyNames.sorted() {
                            print(family)
                            for name in UIFont.fontNames(forFamilyName: family) {
                                print("   \(name)")
                            }
                        }
                }
            }
            // Edit address sheet
            .sheet(item: $selectedAddressForEdit) { addr in
                AddAddressView(addressToEdit: addr)
                    .environmentObject(session)
            }
            // Add new address sheet
            .sheet(isPresented: $showAddAddressSheet) {
                AddAddressView()
                    .environmentObject(session)
            }
        
        
                
            
            
           
    }

    // MARK: - Subviews

    private func profileHeader(_ profile: UserProfile) -> some View {
        HStack(alignment: .center, spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [GFTheme.primary, GFTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Text(initials(for: profile.name.isEmpty ? profile.email : profile.name))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name.isEmpty ? "Welcome to Garg Furniture" : profile.name)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundColor(GFTheme.textPrimary)

                Text(profile.email)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)

                if let phone = profile.phone, !phone.isEmpty {
                    Text("📞 \(phone)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.white, Color.white.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(GFTheme.cardRadius)
        .shadow(color: GFTheme.softShadow.color,
                radius: GFTheme.softShadow.radius,
                x: GFTheme.softShadow.x,
                y: GFTheme.softShadow.y)
    }
    private var videoBannerCarousel: some View {
           let side = UIScreen.main.bounds.width - 32  // 16 + 16 padding

           return TabView(selection: $currentVideoIndex) {          // <- selection binding here
               ForEach(Array(videoBanners.enumerated()), id: \.element.id) { idx, banner in
                   videoBannerView(banner: banner)
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

    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account details")
                .gfSectionTitle()

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Full name")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)

                    TextField("Enter your name", text: $editingName)
                        .foregroundColor(GFTheme.textPrimary)          // ✅ TEXT VISIBLE
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(GFTheme.borderSoft, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone number")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)

                    TextField("Enter phone", text: $editingPhone)
                        .keyboardType(.phonePad)
                        .foregroundColor(GFTheme.textPrimary)          // ✅ TEXT VISIBLE
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(GFTheme.borderSoft, lineWidth: 1)
                        )
                }

                Button {
                    UIApplication.shared.endEditing()
                    saveProfile()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save profile")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [GFTheme.primary, GFTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .gfCard()
    }

    private var addressesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My addresses")
                .gfSectionTitle()

            if let addrs = session.user?.addresses, !addrs.isEmpty {
                VStack(spacing: 10) {
                    ForEach(addrs) { addr in
                        addressRow(addr)
                    }
                }
            } else {
                Text("No addresses added yet.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)
                    .padding(.vertical, 4)
            }

            Button {
                showAddAddressSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add new address")
                }
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(GFTheme.primary)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .gfCard()
    }

    private func addressRow(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(address.label)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(GFTheme.textPrimary)

                Text(address.line1)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)

                Text("\(address.city), \(address.state) - \(address.pincode)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)

                Text("Phone: \(address.phone)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)
            }

            // ✅ Edit / Remove row matching UI, no red icons beech mein
            HStack(spacing: 16) {
                Button {
                    selectedAddressForEdit = address
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(GFTheme.primary)
                }

                Button {
                    deleteAddress(address)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Remove")
                    }
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(GFTheme.borderSoft, lineWidth: 1)
        )
    }

    private var logoutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session")
                .gfSectionTitle()

            Button {
                UIApplication.shared.endEditing()
                session.signOut()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log out")
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                }
                .foregroundColor(.red)
                .padding(.vertical, 10)
            }
        }
        .padding(16)
        .gfCard()
    }

    // MARK: - Helpers

    private func syncFromSession() {
        if let profile = session.user {
            editingName = profile.name
            editingPhone = profile.phone ?? ""
        }
    }

    private func saveProfile() {
        guard var profile = session.user else { return }
        profile.name = editingName
        profile.phone = editingPhone

        session.saveProfile(profile) { err in
            if let e = err {
                error = e.localizedDescription
            } else {
                error = ""
                session.user?.name = editingName
                session.user?.phone = editingPhone
            }
        }
    }

    private func deleteAddress(_ address: Address) {
        guard let uid = session.user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("addresses")
            .document(address.id)
            .delete { err in
                if let err = err {
                    error = err.localizedDescription
                } else {
                    if let idx = session.user?.addresses?.firstIndex(where: { $0.id == address.id }) {
                        session.user?.addresses?.remove(at: idx)
                    }
                }
            }
    }

    private func initials(for nameOrEmail: String) -> String {
        let comps = nameOrEmail.split(separator: " ")
        if comps.count >= 2 {
            let first = comps[0].first ?? "?"
            let second = comps[1].first ?? "?"
            return String(first).uppercased() + String(second).uppercased()
        } else if let first = nameOrEmail.first {
            return String(first).uppercased()
        }
        return "G"
    }
}

struct videoBannerView: View {
    let banner: videoBanner

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
struct videoFillPlayer: UIViewRepresentable {
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
struct videoFillView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> playerContainerView {
        let view = playerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill  // 👈 full fill, no black bars
        return view
    }

    func updateUIView(_ uiView: playerContainerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// Custom UIView jisme layer hi AVPlayerLayer hai
class playerContainerView: UIView {
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

