//
//  GargFurnitureApp.swift
//  GargFurniture
//
//  Created by Nikunj Garg on 19/11/25.
//

import SwiftUI
import Firebase

@main
struct GargFurnitureApp: App {
    @StateObject var session = SessionStore()
    @StateObject var cart = CartManager()
    @State private var showSplash = true

    init() {
        let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .clear
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
                ]
                appearance.largeTitleTextAttributes = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold)
                ]

                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // If user logged in show ContentView, else show AuthView
                if let _ = session.user {
                    ContentView()
                        .environmentObject(session)
                        .environmentObject(cart)
                        .opacity(showSplash ? 0 : 1)
                } else {
                    AuthView()
                        .environmentObject(session)
                        .opacity(showSplash ? 0 : 1)
                }

                if showSplash {
                    SplashView(isActive: $showSplash)
                }
            }
            .onAppear {
                // ensure session starts listening
                _ = session
            }
        }
    }
}
