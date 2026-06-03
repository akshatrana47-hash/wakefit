//
//  Constants.swift
//  WakeFit
//
//  App-wide design tokens and constants from Stitch design system
//

import SwiftUI

struct AppColors {
    static let bgBase = Color(hex: "051424")
    static let bgSurface = Color(hex: "0D1C2D")
    static let bgCard = Color(hex: "122131")
    static let bgCardHigh = Color(hex: "1C2B3C")
    static let accentTeal = Color(hex: "46F1CF")
    static let success = Color(hex: "00C896")
    static let warning = Color(hex: "F5A623")
    static let danger = Color(hex: "FF5C5C")
    static let textPrimary = Color(hex: "D4E4FA")
    static let textSecondary = Color(hex: "BACAC4")
    static let textMuted = Color(hex: "84948F")
    static let cardBorder = Color(hex: "3B4A45")
}

struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 40
    static let screenMargin: CGFloat = 20
}

struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}
