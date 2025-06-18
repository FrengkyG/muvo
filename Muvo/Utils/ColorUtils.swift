//
//  ColorUtils.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//
import SwiftUI

extension Color {
    static let disabledText = Color(hex: "#797877")
    static let primColor = Color(hex: "#0B6FF9")
    static let bgButtonColor = Color(hex: "#F9F6F4")
    static let greenProgressColor = Color(hex: "#00D34B")
    static let grayProgressColor = Color(hex: "#D8D8D8")
    static let grayText = Color(hex: "B2B2B2")
    static let grayIcon = Color(hex: "#393938")
    static let white80 = Color(hex: "EAF3FF")
}

extension Color {
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        guard hex.count == 6,
              let intCode = Int(hex, radix: 16) else {
            return nil
        }

        let red = Double((intCode >> 16) & 0xFF) / 255.0
        let green = Double((intCode >> 8) & 0xFF) / 255.0
        let blue = Double(intCode & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
