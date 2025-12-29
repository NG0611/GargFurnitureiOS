//import SwiftUI
//
//// MARK: - Garg Furniture Design System (Warm Beige + Brown)
//
//struct GFTheme {
//    // Colors – warm, cozy, premium furniture brand style
//    static let primary       = Color(hex: "#8B5E3C")  // Rich walnut brown
//    static let secondary     = Color(hex: "#D9A05B")  // Soft caramel gold
//    static let background    = Color(hex: "#F9F6F2")  // Warm cream background
//    static let card          = Color.white
//    static let cardBg        = Color.white
//    
//    static let textPrimary   = Color(hex: "#2B2118")  // Dark brown charcoal
//    static let textSecondary = Color(hex: "#7C6A5C")  // Warm muted brown
//    static let borderSoft    = Color(hex: "#E3D5C8")  // Light beige divider
//    
//    // Corner radius levels
//    static let cardRadius: CGFloat = 18
//    static let buttonRadius: CGFloat = 14
//    
//    // Soft premium shadow
//    static let softShadow = ShadowStyle(
//        color: Color.black.opacity(0.06),
//        radius: 14,
//        x: 0,
//        y: 8
//    )
//}
//
//struct ShadowStyle {
//    let color: Color
//    let radius: CGFloat
//    let x: CGFloat
//    let y: CGFloat
//}
//
//// MARK: - Hex Support
//
//extension Color {
//    init(hex: String) {
//        var hex = hex
//        if hex.hasPrefix("#") { hex.removeFirst() }
//        
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        
//        let r = Double((int >> 16) & 0xFF) / 255
//        let g = Double((int >> 8) & 0xFF) / 255
//        let b = Double(int & 0xFF) / 255
//        
//        self.init(.sRGB, red: r, green: g, blue: b)
//    }
//}
//
//// MARK: - Common UI Modifiers
//
//struct GFCardModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .background(GFTheme.card)
//            .cornerRadius(GFTheme.cardRadius)
//            .shadow(color: GFTheme.softShadow.color,
//                    radius: GFTheme.softShadow.radius,
//                    x: GFTheme.softShadow.x,
//                    y: GFTheme.softShadow.y)
//    }
//}
//
//// MARK: - Global Extensions
//
//extension View {
//    func gfCard() -> some View {
//        self.modifier(GFCardModifier())
//    }
//    
//    func gfSectionTitle() -> some View {
//        self
//            .font(.system(.title3, design: .rounded).weight(.semibold))
//            .foregroundColor(GFTheme.textPrimary)
//    }
//    
//    func gfSoftField() -> some View {
//        self
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(color: GFTheme.softShadow.color.opacity(0.4),
//                    radius: 8, x: 0, y: 4)
//    }
//    
//    func gfButton() -> some View {
//        self
//            .font(.system(size: 16, weight: .semibold))
//            .foregroundColor(.white)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                LinearGradient(colors: [GFTheme.primary, GFTheme.secondary],
//                               startPoint: .leading,
//                               endPoint: .trailing)
//            )
//            .cornerRadius(GFTheme.buttonRadius)
//            .shadow(color: GFTheme.softShadow.color,
//                    radius: GFTheme.softShadow.radius,
//                    x: GFTheme.softShadow.x,
//                    y: GFTheme.softShadow.y)
//    }
//}



import SwiftUI

// MARK: - Garg Furniture Design System (Ultra Minimalist)

struct GFTheme {
    // MARK: - Color Palette
    // Strict Monochrome: Black, White, and Grey.
    // This makes the furniture images the "hero".
    
    static let primary      = Color(hex: "#4B3621")  // Luxury brown
    static let secondary    = Color(hex: "#4B3621")  // luxury brown
    static let background   = Color(hex: "#F3EDE7")  // Warm Cream
    static let card         = Color(hex: "#FFFFFF")
    
    // Text Colors
    static let textPrimary   = Color(hex: "#000000")
    static let textSecondary = Color(hex: "#666666") // Medium Grey
    static let borderSoft    = Color(hex: "#E0E0E0") // Light Grey Divider
    
    // MARK: - Dimensions (Sharper for Luxury)
    // Kam radius "cute" nahi, "professional" lagta hai.
    static let cardRadius: CGFloat = 4
    static let buttonRadius: CGFloat = 0 // Completely sharp buttons (very modern)
    
    // MARK: - Shadows (Minimal or None)
    // High-end apps often use borders instead of shadows for a cleaner look.
    static let softShadow = ShadowStyle(
        color: Color.black.opacity(0.05),
        radius: 10,
        x: 0,
        y: 4
    )
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Hex Support (Same as before)
extension Color {
    init(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") { hex.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

// MARK: - Global Extensions

extension View {
    
    // 1. Minimal Card (Border instead of Shadow)
    func gfCard() -> some View {
        self
            .background(GFTheme.card)
            .cornerRadius(GFTheme.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: GFTheme.cardRadius)
                    .stroke(Color(hex: "#EEEEEE"), lineWidth: 1) // Subtle border
            )
        // No shadow for a flat, clean magazine look
    }
    
    // 2. Section Title (Bold & Uppercase)
    func gfSectionTitle() -> some View {
        self
            .font(.system(size: 18, weight: .bold, design: .default))
            .textCase(.uppercase) // Uppercase looks very premium
            .foregroundColor(GFTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
    
    // 3. Input Field (Underline Style - Very Sleek)
    // Box wala field hatakar sirf underline rakha hai
    func gfSoftField() -> some View {
        self
            .padding()
            .background(Color(hex: "#F9F9F9"))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.black),
                alignment: .bottom
            )
    }
    
    // 4. Primary Button (Solid Black)
    func gfButton() -> some View {
        self
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black) // Solid Black
            .cornerRadius(GFTheme.buttonRadius)
    }
    
    // 5. Secondary Button (Black Border)
    func gfSecondaryButton() -> some View {
        self
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1) // Sharp border
            )
    }
}
