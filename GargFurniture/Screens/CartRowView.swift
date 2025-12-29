import SwiftUI

struct CartRowView: View {
    @EnvironmentObject var cart: CartManager
    let item: CartItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 14) {

                // Product image
                ProductImageView(urlString: item.product.imageUrl)
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.12),
                            radius: 8,
                            x: 0,
                            y: 4)

                // Text area
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.product.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(GFTheme.textPrimary)
                        .lineLimit(2)

                    Text("₹\(String(format: "%.2f", priceEach())) each")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)

                    Text("Subtotal: ₹\(String(format: "%.2f", subtotal()))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(GFTheme.primary)
                }

                Spacer()

                // Quantity controls
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        // minus
                        Button {
                            cart.decrement(product: item.product)
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                                .shadow(color: .black.opacity(0.1),
                                        radius: 4,
                                        x: 0,
                                        y: 2)
                                .overlay(
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(GFTheme.primary)
                                )
                        }
                        .buttonStyle(.plain)

                        // ✅ QTY CLEARLY VISIBLE
                        Text("\(item.quantity)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(GFTheme.textPrimary)   // <- important
                            .frame(width: 30)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )

                        // plus
                        Button {
                            cart.increment(product: item.product)
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                                .shadow(color: .black.opacity(0.1),
                                        radius: 4,
                                        x: 0,
                                        y: 2)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(GFTheme.primary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Remove button
            Button {
                cart.remove(product: item.product)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Remove")
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05),
                radius: 10,
                x: 0,
                y: 5)
    }

    // MARK: - Helpers

    func priceEach() -> Double {
        Double(item.product.price_cents) / 100
    }

    func subtotal() -> Double {
        priceEach() * Double(item.quantity)
    }
}
