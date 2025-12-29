import Foundation

struct OrderItem: Codable, Identifiable {
    var id: String { productId }
    let productId: String
    let name: String
    let price_cents: Int
    let quantity: Int
}

struct Order: Codable, Identifiable {
    var id: String            // Firestore doc id
    let uid: String
    let items: [OrderItem]
    let total_cents: Int
    let currency: String
    let address: Address
    var order_status: String
    var razorpay_order_id: String?

    // Convenient init – id default me naya UUID string
    init(
        id: String = UUID().uuidString,
        uid: String,
        items: [OrderItem],
        total_cents: Int,
        currency: String,
        address: Address,
        order_status: String = "pending",
        razorpay_order_id: String? = nil
    ) {
        self.id = id
        self.uid = uid
        self.items = items
        self.total_cents = total_cents
        self.currency = currency
        self.address = address
        self.order_status = order_status
        self.razorpay_order_id = razorpay_order_id
    }
}
