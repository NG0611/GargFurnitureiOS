import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    // Animations
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var glowOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // BACKGROUND – warm furniture theme
            ZStack {
                // Base cream background
                GFTheme.background
                    .ignoresSafeArea()

                // Subtle diagonal tint using brand browns
                LinearGradient(
                    colors: [
                        GFTheme.background,
                        GFTheme.primary.opacity(0.12),
                        GFTheme.secondary.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 18) {

                ZStack {
                    // Soft glow behind logo
                    Circle()
                        .fill(GFTheme.secondary.opacity(0.25))
                        .blur(radius: 40)
                        .frame(width: 190, height: 190)
                        .opacity(glowOpacity)

                    // LOGO
                    if UIImage(named: "AppLogo") != nil {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(GFTheme.borderSoft, lineWidth: 1.2)
                            )
                            .shadow(color: Color.black.opacity(0.10),
                                    radius: 10,
                                    x: 0,
                                    y: 8)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    } else {
                        // Fallback text logo
                        Text("Garg Furniture")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(GFTheme.textPrimary)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                }

                VStack(spacing: 4) {
                    Text("Garg Furniture")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(GFTheme.textPrimary)

                    Text("Premium furniture & furnishings")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        // 1) Logo appear + scale
        withAnimation(.easeOut(duration: 0.7)) {
            logoOpacity = 1.0
            logoScale = 1.05
        }

        // 2) Glow fade-in
        withAnimation(.easeInOut(duration: 1.2).delay(0.15)) {
            glowOpacity = 1.0
        }

        // 3) Text slide-up
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.35)) {
            textOpacity = 1.0
            textOffset = 0
        }

        // 4) Wait then dismiss splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.4)) {
                isActive = false
            }
        }
    }
}
