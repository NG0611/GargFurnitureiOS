import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var cart: CartManager
    @Environment(\.dismiss) private var dismiss
    let product: Product

    // Local state to show controls and reflect cart
    @State private var localQty: Int = 0
    @State private var showControls: Bool = false

    var body: some View {
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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Hero image
                    ZStack(alignment: .bottomLeading) {
                        ProductImageView(urlString: product.imageUrl)
                            .scaledToFill()
                            .frame(height: 280)
                            .clipped()
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.15),
                                    radius: 18,
                                    x: 0,
                                    y: 10)

                        // gradient overlay bottom
                        LinearGradient(
                            colors: [.black.opacity(0.0),
                                     .black.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(22)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity, alignment: .bottom)

                        HStack(alignment: .center, spacing: 10) {
                            Text(product.name)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(2)

                            Spacer()

                            stockChip
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                    .padding(.top, 8)

                    // MARK: - Price + summary
                    priceSection

                    // MARK: - Description
                    descriptionSection

                    // MARK: - Quantity / Add to cart
                    quantitySection

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)   // 👈 system ka blue back hide
        .toolbar {
//            // 👈 Custom back button
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button {
//                    dismiss()   // SwiftUI se safely back
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(GFTheme.primary)  // tumhara brand color
//                        .frame(width: 44, height: 44)
//                }
//            }

            // Title center me
            ToolbarItem(placement: .principal) {
                Text("Product Details")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(GFTheme.textPrimary)
            }
        }
        .onAppear {
            // sync initial state from cart
            let q = cart.quantityFor(product: product)
            localQty = q
            showControls = q > 0
        }
        .onReceive(cart.$items) { _ in
            // update live when cart changes elsewhere
            let q = cart.quantityFor(product: product)
            localQty = q
            if q > 0 {
                if !showControls {
                    withAnimation { showControls = true }
                }
            } else {
                if showControls {
                    withAnimation { showControls = false }
                }
            }
        }
    }

    // MARK: - Subviews

    private var stockChip: some View {
        let inStock = (product.stock ?? 0) > 0

        return HStack(spacing: 6) {
            Circle()
                .fill(inStock ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(inStock ? "In stock" : "Out of stock")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .cornerRadius(999)
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(GFTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("₹\(formatPrice(product.price_cents))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(GFTheme.primary)

                Text("incl. GST")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(GFTheme.textSecondary)
            }

            Text("No-cost EMI • Free delivery • Easy returns")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)
        }
        .padding(16)
        .gfCard()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .gfSectionTitle()

            Text(product.description)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .gfCard()
    }

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add to cart")
                .gfSectionTitle()

            if showControls {
                HStack(spacing: 16) {
                    // minus
                    Button(action: {
                        if localQty > 1 {
                            localQty -= 1
                            cart.decrement(product: product)
                        } else {
                            cart.decrement(product: product)
                            localQty = 0
                            withAnimation { showControls = false }
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(GFTheme.primary)
                    }

                    // qty – IMPORTANT: color set + proper font
                    Text("\(localQty)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(GFTheme.textPrimary)
                        .frame(minWidth: 40)

                    // plus
                    Button(action: {
                        localQty += 1
                        cart.increment(product: product)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(GFTheme.primary)
                    }

                    Spacer()

                    // Subtotal with localQty
                    let subtotal = (Double(product.price_cents)/100.0) * Double(max(localQty, 1))
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Subtotal")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(GFTheme.textSecondary)

                        Text("₹\(String(format: "%.2f", subtotal))")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(GFTheme.textPrimary)
                    }
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: GFTheme.softShadow.color.opacity(0.4),
                        radius: 10,
                        x: 0,
                        y: 6)

            } else {
                Button(action: {
                    // pehle cart me 1 qty daal, aur localQty ko direct 1 set kar
                    cart.addToCart(product: product, qty: 1)
                    localQty = 1
                    withAnimation { showControls = true }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("ADD TO CART")
                            .font(.system(.headline, design: .rounded))
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [GFTheme.primary, GFTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: GFTheme.softShadow.color.opacity(0.7),
                            radius: 12,
                            x: 0,
                            y: 6)
                }
            }
        }
        .padding(16)
        .gfCard()
    }

    // MARK: - Helpers

    func formatPrice(_ cents: Int) -> String {
        let rupees = Double(cents) / 100
        return String(format: "%.2f", rupees)
    }
}
