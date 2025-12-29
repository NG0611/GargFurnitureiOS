import SwiftUI
import FirebaseFirestore
import FirebaseFunctions

struct CartView: View {
    @EnvironmentObject var cart: CartManager
    @EnvironmentObject var session: SessionStore

    @State private var creating = false
    @State private var createError = ""
    @State private var showSuccess = false
    @State private var showAddressSheet = false
    @State private var chosenAddress: Address? = nil

    var body: some View {
        ZStack(alignment: .bottom) {

            VStack(spacing: 0) {

                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Truck")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(GFTheme.textPrimary)

                        if !cart.items.isEmpty {
                            Text("\(cart.items.count) item\(cart.items.count > 1 ? "s" : "") in your truck")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(GFTheme.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)

                if cart.items.isEmpty {
                    Spacer()

                    VStack(spacing: 16) {
                        

                            Image("Truck") // name from Assets
                                .resizable()
                                .scaledToFit()
                                

                                .frame(width: 150, height: 150)
                                .foregroundColor(GFTheme.primary.opacity(0.75)) // note: color only applies to template images

                        

                        Text("Your delivery truck looks empty")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(GFTheme.textPrimary)

                        Text("Browse beautiful furniture and add items to your truck.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(GFTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                } else {
                    // MARK: - Cart items list
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(cart.items) { item in
                                CartRowView(item: item)
                                    .environmentObject(cart)
                            }

                            if !createError.isEmpty {
                                Text(createError)
                                    .foregroundColor(.red)
                                    .font(.system(size: 13, design: .rounded))
                                    .padding(.horizontal)
                            }

                            if showSuccess {
                                Text("Order created & paid successfully!")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 250) // space for bottom bar
                    }
                }
            }

            // MARK: - Checkout bar (floating)
            if !cart.items.isEmpty {
                checkoutBar
            }
        }
        .sheet(isPresented: $showAddressSheet, onDismiss: {
            if chosenAddress == nil {
                createError = ""
                showSuccess = false
            }
        }) {
            NavigationView {
                SelectAddressView { addr in
                    chosenAddress = addr
                    showAddressSheet = false
                    createOrder(with: addr)
                }
                .environmentObject(session)
            }
        }
        .onAppear {
            createError = ""
            showSuccess = false
        }
    }

    // MARK: - Checkout Bar

    private var checkoutBar: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total amount")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary)

                    Text("₹\(String(format: "%.2f", cart.totalAmount()))")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(GFTheme.primary)
                }

                Spacer()

                Button {
                    createError = ""
                    showSuccess = false
                    showAddressSheet = true
                } label: {
                    HStack(spacing: 8) {
                        if creating { ProgressView().tint(.white) }
                        Text(creating ? "Wait" : "Checkout")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [GFTheme.primary, GFTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(18)
                }
                .disabled(creating)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.12),
                radius: 12,
                x: 0,
                y: -2)
        .padding(.horizontal, 16)
        .padding(.bottom, 110)
    }

    // MARK: - Order logic (same as tumhara)

    func deleteItem(at offsets: IndexSet) {
        for idx in offsets {
            let product = cart.items[idx].product
            cart.remove(product: product)
        }
    }

    func createOrder(with address: Address) {
        guard let user = session.user else {
            createError = "Please login again."
            return
        }

        let db = Firestore.firestore()
        let functions = Functions.functions(region: "us-central1")

        let orderId = UUID().uuidString
        let totalCents = Int((cart.totalAmount() * 100).rounded())

        print("🔥 iOS sending orderId:", orderId)
        print("🔥 totalCents:", totalCents)

        let itemsArray = cart.items.map {
            [
                "productId": $0.product.id,
                "name": $0.product.name,
                "price_cents": $0.product.price_cents,
                "quantity": $0.quantity
            ]
        }

        let orderData: [String: Any] = [
            "uid": user.uid,
            "items": itemsArray,
            "total_cents": totalCents,
            "currency": "INR",
            "order_status": "pending",
            "address": [
                "label": address.label,
                "line1": address.line1,
                "city": address.city,
                "state": address.state,
                "pincode": address.pincode,
                "phone": address.phone
            ],
            "razorpay_order_id": NSNull(),
            "createdAt": FieldValue.serverTimestamp()
        ]

        creating = true
        createError = ""
        showSuccess = false

        // STEP 1 – Firestore order
        db.collection("orders").document(orderId).setData(orderData) { err in
            if let err = err {
                creating = false
                createError = "Order create failed: \(err.localizedDescription)"
                return
            }

            print("✔ Firestore order created → \(orderId)")

            // STEP 2 – Cloud Function → Razorpay order
            functions.httpsCallable("createRazorpayOrder").call([
                "orderId": orderId
            ]) { result, error in

                if let error = error {
                    creating = false
                    createError = "Payment server error: \(error.localizedDescription)"
                    return
                }

                guard
                    let dict = result?.data as? [String: Any],
                    let razorpayOrderId = dict["order_id"] as? String
                else {
                    creating = false
                    createError = "Invalid server response."
                    return
                }

                print("✔ Razorpay order id:", razorpayOrderId)

                // STEP 3 – Open Razorpay
                RazorpayHandler.shared.startPayment(
                    orderId: razorpayOrderId,
                    amountInPaise: totalCents,
                    name: user.name,
                    email: user.email,
                    contact: address.phone
                ) { payResult in

                    switch payResult {

                    case .success(let paymentId):
                        print("✅ Payment success:", paymentId)

                        // STEP 4 – Mark as paid
                        db.collection("orders").document(orderId).updateData([
                            "order_status": "paid",
                            "payment_id": paymentId
                        ])

                        creating = false
                        cart.items.removeAll()
                        showSuccess = true
                        createError = ""
                        chosenAddress = nil

                    case .failure(let err):
                        print("❌ Payment failed:", err.localizedDescription)

                        db.collection("orders").document(orderId).updateData([
                            "order_status": "failed"
                        ])

                        creating = false
                        createError = "Payment failed: \(err.localizedDescription)"
                        showSuccess = false
                    }
                }
            }
        }
    }
}
