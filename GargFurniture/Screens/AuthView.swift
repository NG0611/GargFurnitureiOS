
//
//  AuthView.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 19/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var isSignup = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var errorMessage = ""
    @State private var loading = false
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0

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

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Brand Header
                        VStack(spacing: 10) {
                            ZStack {
                                

                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
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
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            logoScale = 1.0
                                            logoOpacity = 1.0
                                        }
                                    }
                            }

                            

                            Text("Premium furniture & furnishings for your home.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(GFTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                
                        }
                        .padding(.top, 40)

                        // MARK: - Card
                        VStack(spacing: 18) {

                            // Toggle Login / Signup
                            HStack(spacing: 4) {
                                toggleChip(title: "Log in", isActive: !isSignup) {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                        isSignup = false
                                        clear()
                                    }
                                }
                                toggleChip(title: "Sign up", isActive: isSignup) {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                        isSignup = true
                                        clear()
                                    }
                                }
                            }
                            .padding(.top, 4)

                            VStack(spacing: 14) {
                                if isSignup {
                                    inputField(
                                        title: "Full name",
                                        placeholder: "Your name",
                                        text: $name,
                                        keyboard: .default,
                                        autoCapWords: true
                                    )
                                }

                                inputField(
                                    title: "Email",
                                    placeholder: "you@example.com",
                                    text: $email,
                                    keyboard: .emailAddress,
                                    autoCapWords: false
                                )

                                secureField(
                                    title: "Password",
                                    placeholder: "Minimum 6 characters",
                                    text: $password
                                )
                            }
                            .padding(.top, 4)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            Button(action: { isSignup ? signup() : login() }) {
                                HStack {
                                    if loading { ProgressView().scaleEffect(0.8) }
                                    Text(isSignup ? "Create account" : "Log in")
                                        .font(.system(.headline, design: .rounded))
                                        .bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [GFTheme.primary, GFTheme.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: GFTheme.softShadow.color.opacity(0.7),
                                        radius: 10,
                                        x: 0,
                                        y: 6)
                            }
                            .disabled(loading)

                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    isSignup.toggle()
                                    clear()
                                }
                            } label: {
                                Text(
                                    isSignup
                                    ? "Already have an account? Log in"
                                    : "Don't have an account? Sign up"
                                )
                                .font(.system(.footnote, design: .rounded))
                                .foregroundColor(GFTheme.primary)
                            }
                            .padding(.top, 2)
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(GFTheme.cardRadius)
                        .shadow(color: GFTheme.softShadow.color,
                                radius: GFTheme.softShadow.radius,
                                x: GFTheme.softShadow.x,
                                y: GFTheme.softShadow.y)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isSignup ? "Create account" : "Welcome back")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(GFTheme.textPrimary)
                }
            }
        }
    }

    // MARK: - UI Helpers

    private func toggleChip(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isActive ? .white : GFTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isActive {
                            LinearGradient(
                                colors: [GFTheme.primary, GFTheme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.white.opacity(0.9)
                        }
                    }
                )
                .cornerRadius(999)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(GFTheme.borderSoft, lineWidth: isActive ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        autoCapWords: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)

            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary.opacity(0.7))
                        .padding(.horizontal, 10)
                }

                TextField("", text: text)
                    .keyboardType(keyboard)
                    .textFieldStyle(.plain)
                    .autocapitalization(autoCapWords ? .words : .none)
                    .foregroundColor(GFTheme.textPrimary)     // 👈 typed text visible
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

    private func secureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(GFTheme.textSecondary)

            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(GFTheme.textSecondary.opacity(0.7))
                        .padding(.horizontal, 10)
                }

                SecureField("", text: text)
                    .textFieldStyle(.plain)
                    .foregroundColor(GFTheme.textPrimary)   // 👈 typed text visible
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

    private func clear() {
        email = ""
        password = ""
        name = ""
        errorMessage = ""
    }

    private func login() {
        errorMessage = ""
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        loading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            loading = false
            if let err = error {
                errorMessage = err.localizedDescription
                return
            }
            // success - SessionStore will update automatically
        }
    }

    private func signup() {
        errorMessage = ""
        guard !name.isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        guard !email.isEmpty, password.count >= 6 else {
            errorMessage = "Please enter valid email and password (min 6)."
            return
        }
        loading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            loading = false
            if let err = error {
                errorMessage = err.localizedDescription
                return
            }
            guard let uid = result?.user.uid else { return }

            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            db.collection("users").document(uid).setData(userData) { err in
                if let e = err {
                    print("Failed to save user:", e.localizedDescription)
                }
                // success - SessionStore will pick up user
            }
        }
    }
}
