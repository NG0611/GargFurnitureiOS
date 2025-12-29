import SwiftUI

struct SelectAddressView: View {
    @EnvironmentObject var session: SessionStore
    let onSelect: (Address) -> Void

    var body: some View {
        ZStack {
            GFTheme.background.ignoresSafeArea()

            VStack(spacing: 12) {

                // Address List
                if let addrs = session.user?.addresses, !addrs.isEmpty {

                    ScrollView {
                        VStack(spacing: 16) {

                            ForEach(addrs) { a in
                                addressCard(a)
                                    .padding(.horizontal, 14)
                            }
                        }
                        .padding(.top, 10)
                    }

                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "house.circle")
                            .font(.system(size: 48))
                            .foregroundColor(GFTheme.textSecondary.opacity(0.7))

                        Text("No addresses saved.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(GFTheme.textSecondary)
                    }
                    .padding(.top, 50)
                }

                // Add New Address Button
                NavigationLink {
                    AddAddressView()
                } label: {
                    Text("Add New Address")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [GFTheme.primary, GFTheme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: GFTheme.softShadow.color.opacity(0.6),
                                radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Select Address")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)   // 👈 Fixed black color
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Address Card
    private func addressCard(_ a: Address) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(a.label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(GFTheme.textPrimary)

                Spacer()

                Image(systemName: "location.circle.fill")
                    .foregroundColor(GFTheme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(a.line1).foregroundColor(GFTheme.textSecondary)
                Text("\(a.city), \(a.state)").foregroundColor(GFTheme.textSecondary)
                Text("Pincode: \(a.pincode)")
                    .foregroundColor(GFTheme.textSecondary)
                Text("Phone: \(a.phone)")
                    .foregroundColor(GFTheme.textSecondary)
            }
            .font(.system(size: 14))

            Button {
                onSelect(a)
            } label: {
                Text("Deliver Here")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(GFTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 6)

        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: GFTheme.softShadow.color.opacity(0.45),
                radius: 10, x: 0, y: 4)
    }
}
