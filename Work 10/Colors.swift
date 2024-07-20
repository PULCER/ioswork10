import SwiftUI

extension Color {
    static let customPink = Color(hex: 0xFFAEBC)
    static let customTeal = Color(hex: 0xA0E7E5)
    static let customGreen = Color(hex: 0xB4F8C8)
    static let customYellow = Color(hex: 0xFBE7C6)
    static let customBlue = Color(hex: 0x87CEEB)  // Sky Blue
    static let customDarkBrown = Color(hex: 0x3D2B1F)  // Dark Brown
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
