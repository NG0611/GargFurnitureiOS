import SwiftUI
import FirebaseFirestore

struct AddAddressView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var session: SessionStore

    // If non-nil => edit mode
    let addressToEdit: Address?

    @State private var label: String = ""
    @State private var line1: String = ""
    @State private var city: String = ""
    @State private var stateName: String = ""   // avoid conflict with SwiftUI.State
    @State private var pincode: String = ""
    @State private var phone: String = ""

    @State private var error: String = ""
    @State private var loading: Bool = false
    @State private var isEditing: Bool = false

    // Default init for "Add Address" usage
    init(addressToEdit: Address? = nil) {
        self.addressToEdit = addressToEdit
    }

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

                    Text(isEditing ? "Edit address" : "Add new address")
                        .gfSectionTitle()
                        .padding(.top, 8)

                    // FORM CARD
                    VStack(alignment: .leading, spacing: 14) {

                        // Label
                        formField(
                            title: "Address label",
                            placeholder: "Home / Work / Others",
                            text: $label
                        )

                        // Line 1
                        formField(
                            title: "Address line",
                            placeholder: "Street / Flat / Area",
                            text: $line1
                        )

                        HStack(spacing: 10) {
                            formField(
                                title: "City",
                                placeholder: "City",
                                text: $city
                            )

                            formField(
                                title: "State",
                                placeholder: "State",
                                text: $stateName
                            )
                        }

                        HStack(spacing: 10) {
                            formField(
                                title: "Pincode",
                                placeholder: "Pincode",
                                text: $pincode,
                                keyboard: .numberPad
                            )

                            formField(
                                title: "Phone",
                                placeholder: "Phone number",
                                text: $phone,
                                keyboard: .phonePad
                            )
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(GFTheme.cardRadius)
                    .shadow(color: GFTheme.softShadow.color,
                            radius: GFTheme.softShadow.radius,
                            x: GFTheme.softShadow.x,
                            y: GFTheme.softShadow.y)

                    if !error.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(.footnote, design: .rounded))
                    }

                    Button {
                        saveAddress()
                    } label: {
                        HStack {
                            Spacer()
                            if loading { ProgressView().scaleEffect(0.9) }
                            Text(isEditing ? "Update address" : "Save address")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [GFTheme.primary, GFTheme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: GFTheme.softShadow.color.opacity(0.7),
                                radius: 10,
                                x: 0,
                                y: 6)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(isEditing ? "Edit Address" : "Add Address")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupInitialValues()
        }
    }

    // MARK: - Subviews

    // MARK: - Subviews

    private func formField(title: String,
                           placeholder: String,
                           text: Binding<String>,
                           keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)

            ZStack(alignment: .leading) {
                // Placeholder jab text empty ho
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary.opacity(0.7))
                        .padding(.horizontal, 10)
                }

                TextField("", text: text)
                    .keyboardType(keyboard)
                    .foregroundColor(GFTheme.textPrimary)   // ✅ typed text clearly visible
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(GFTheme.borderSoft, lineWidth: 1)
            )
        }
    }

    // MARK: - Logic

    private func setupInitialValues() {
        if let a = addressToEdit {
            label = a.label
            line1 = a.line1
            city = a.city
            stateName = a.state
            pincode = a.pincode
            phone = a.phone
            isEditing = true
        } else {
            isEditing = false
        }
    }

    private func saveAddress() {
        guard let uid = session.user?.uid else {
            error = "User not logged in"
            return
        }

        // basic validation
        if label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            line1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            stateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            pincode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Please fill all fields."
            return
        }

        loading = true
        error = ""

        // If editing, reuse same id, else new one
        let addressId = addressToEdit?.id ?? UUID().uuidString

        let addr = Address(
            id: addressId,
            label: label,
            line1: line1,
            city: city,
            state: stateName,
            pincode: pincode,
            phone: phone
        )

        let data: [String: Any] = [
            "id": addr.id,
            "label": addr.label,
            "line1": addr.line1,
            "city": addr.city,
            "state": addr.state,
            "pincode": addr.pincode,
            "phone": addr.phone
        ]

        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .collection("addresses")
            .document(addressId)
            .setData(data, merge: true) { err in
                loading = false
                if let err = err {
                    error = err.localizedDescription
                } else {
                    // Update local session copy
                    if session.user?.addresses == nil {
                        session.user?.addresses = []
                    }

                    if let index = session.user?.addresses?.firstIndex(where: { $0.id == addr.id }) {
                        session.user?.addresses?[index] = addr
                    } else {
                        session.user?.addresses?.append(addr)
                    }

                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}
