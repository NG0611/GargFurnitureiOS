import Foundation
import Combine



class CartManager: ObservableObject {
    
    
    @Published var items: [CartItem] = []

    func addToCart(product: Product, qty: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += qty
            if items[index].quantity <= 0 { items.remove(at: index) }
        } else {
            guard qty > 0 else { return }
            items.append(CartItem(product: product, quantity: qty))
        }
    }

    func setQuantity(product: Product, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        } else {
            if quantity > 0 {
                items.append(CartItem(product: product, quantity: quantity))
            }
        }
    }
    func convertToOrder(uid: String, address: Address) -> Order {
        let itemsList = items.map {
            OrderItem(
                productId: $0.product.id,
                name: $0.product.name,
                price_cents: $0.product.price_cents,
                quantity: $0.quantity
            )
        }

        let totalCents = Int(totalAmount() * 100)

        return Order(
                uid: uid,
                items: itemsList,
                total_cents: totalCents,
                currency: "INR",
                address: address,
                order_status: "pending",
                razorpay_order_id: nil
            )
    }

    func increment(product: Product) {
        addToCart(product: product, qty: 1)
    }

    func decrement(product: Product) {
        addToCart(product: product, qty: -1)
    }

    func remove(product: Product) {
        items.removeAll(where: { $0.product.id == product.id })
    }

    func totalAmount() -> Double {
        return items.reduce(0) { result, item in
            result + (Double(item.product.price_cents) / 100.0 * Double(item.quantity))
        }
    }

    func clearCart() {
        items.removeAll()
    }

    func quantityFor(product: Product) -> Int {
        return items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}
