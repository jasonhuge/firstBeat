//
//  AppTheme.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI

enum AppTheme {

    // MARK: - Primary Color System

    /// Primary - Warm Amber (main brand color)
    static let primary = Color(red: 0.957, green: 0.576, blue: 0.184) // #F4932F

    /// Secondary - Rich Orange (analogous to primary)
    static let secondary = Color(red: 0.957, green: 0.467, blue: 0.129) // #F47721

    /// Tertiary - Deep Terracotta (analogous to primary)
    static let tertiary = Color(red: 0.906, green: 0.396, blue: 0.192) // #E76531

    /// Success - Warm Coral (warm complementary)
    static let success = Color(red: 0.929, green: 0.412, blue: 0.376) // #ED6960

    /// Accent - Clay Brown (warm accent)
    static let accent = Color(red: 0.741, green: 0.439, blue: 0.318) // #BD7051

    // MARK: - Primary Shades (for gradient cards)

    /// Light shade of primary - for first card (soft amber)
    static let primaryLight = Color(red: 0.992, green: 0.722, blue: 0.420) // #FDB86B

    /// Medium shade of primary - for second card (warm amber)
    static let primaryMedium = Color(red: 0.957, green: 0.576, blue: 0.184) // #F4932F

    /// Dark shade of primary - for potential third card (deep amber)
    static let primaryDark = Color(red: 0.839, green: 0.475, blue: 0.145) // #D67925

    // MARK: - Semantic Colors

    static let warmUpColor = primaryLight
    static let practiceColor = primaryMedium
    static let successColor = success
    static let accentColor = accent
}

// MARK: - SwiftUI Color Extension

extension Color {
    static let appPrimary = AppTheme.primary
    static let appSecondary = AppTheme.secondary
    static let appTertiary = AppTheme.tertiary
    static let appSuccess = AppTheme.success
    static let appAccent = AppTheme.accent
    static let appPrimaryLight = AppTheme.primaryLight
    static let appPrimaryMedium = AppTheme.primaryMedium
    static let appPrimaryDark = AppTheme.primaryDark
}
