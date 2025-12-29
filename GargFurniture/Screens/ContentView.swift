import SwiftUI

enum GFTab: String {
    case shop
    case cart
    case profile
}

struct ContentView: View {
    @State private var selectedTab: GFTab = .shop

    var body: some View {
        ZStack(alignment: .bottom) {

            // MAIN CONTENT
            Group {
                switch selectedTab {
                case .shop:
                    ProductListView()

                case .cart:
                    CartView()

                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        GFTheme.background,
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )

            // FLOATING TAB BAR
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: GFTab

    var body: some View {
        HStack(spacing: 22) {
            tabItem(icon: "house", title: "Shop", tab: .shop,size:17)
            tabItem(icon: "box.truck.fill", title: "Truck", tab: .cart,size:14)
            tabItem(icon: "person.crop.circle", title: "Profile", tab: .profile,size:17)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.96))
                .shadow(color: Color.black.opacity(0.12),
                        radius: 18,
                        x: 0,
                        y: 10)
        )
    }

    @ViewBuilder
    private func tabItem(icon: String, title: String, tab: GFTab,size:CGFloat) -> some View {
        let isSelected = (selectedTab == tab)

        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [GFTheme.primary, GFTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                    }

                    Image(systemName: icon)
                        .font(.system(size: size, weight: .semibold))
                        .foregroundColor(isSelected ? .white : GFTheme.textSecondary)
                }

                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? GFTheme.primary : GFTheme.textSecondary.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(SessionStore())
        .environmentObject(CartManager())
}
