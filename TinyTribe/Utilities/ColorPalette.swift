//
//  ColorPalette.swift
//  TinyTribe
//
//  Created by rosa.meijers  on 07/11/2024.
//

import SwiftUI

struct ColorPalette {
    
    // Neutral colors
    static let warmBeige = Color(hex: "#F5F5DC")
    static let blushPink = Color(hex: "#F8E1E7")
    static let sageGreen = Color(hex: "#B2BEB5")
    static let softCream = Color(hex: "#FFF5E1")
    static let peach = Color(hex: "#FFE5B4")
    static let sand = Color(hex: "#FAF0E6")
    static let almostWhite = Color(hex: "#FDFDFD")
    static let stoneGray = Color(hex: "#7D7D7D") 
    
    // Dark & Accent Colors
    static let charcoalGray = Color(hex: "#333333")
    static let rustyRed = Color(hex: "#B94A3A")
    
    // Earthy & Natural Tones
    static let woodenBrown = Color(hex: "#8B4513")
    static let mutedOliveGreen = Color(hex: "#708238")
    
    // Soft and Elegant tones
    static let warmTaupe = Color(hex: "#D8C9B3")
    static let powderBlue = Color(hex: "#A1C6EA")
    static let midnightBlue = Color(hex: "#003366") 

}

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }

        guard hex.count == 6 || hex.count == 8 else {
            self = Color.black
            return
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        if hex.count == 6 {
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgb & 0x000000FF) / 255.0
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
