//
//  AppTheme.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI

enum AppTheme {

    // MARK: - Primary Color System (Based on App Icon)

    /// Primary - Golden Orange (from app icon speech bubble)
    static let primary = Color(red: 0.961, green: 0.663, blue: 0.267) // #F5A944

    /// Secondary - Cyan Blue (from app icon speech bubble)
    static let secondary = Color(red: 0.357, green: 0.773, blue: 0.949) // #5BC5F2

    /// Tertiary - Deep Purple (from app icon background)
    static let tertiary = Color(red: 0.180, green: 0.102, blue: 0.278) // #2E1A47

    /// Success - Vibrant Green (complementary to purple)
    static let success = Color(red: 0.298, green: 0.792, blue: 0.533) // #4CCA88

    /// Accent - Light Purple (tint of tertiary)
    static let accent = Color(red: 0.420, green: 0.318, blue: 0.576) // #6B5193

    // MARK: - Color Variations

    /// Light Orange - softer variation of primary
    static let primaryLight = Color(red: 0.988, green: 0.800, blue: 0.502) // #FCCC80

    /// Medium Orange - main primary color
    static let primaryMedium = Color(red: 0.961, green: 0.663, blue: 0.267) // #F5A944

    /// Dark Orange - deeper variation of primary
    static let primaryDark = Color(red: 0.851, green: 0.537, blue: 0.157) // #D98928

    /// Light Cyan - softer variation of secondary
    static let secondaryLight = Color(red: 0.569, green: 0.847, blue: 0.969) // #91D8F7

    /// Medium Cyan - main secondary color
    static let secondaryMedium = Color(red: 0.357, green: 0.773, blue: 0.949) // #5BC5F2

    /// Dark Cyan - deeper variation of secondary
    static let secondaryDark = Color(red: 0.243, green: 0.651, blue: 0.820) // #3EA6D1

    // MARK: - Semantic Colors

    static let warmUpColor = secondaryMedium
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

    static let appSecondaryLight = AppTheme.secondaryLight
    static let appSecondaryMedium = AppTheme.secondaryMedium
    static let appSecondaryDark = AppTheme.secondaryDark
}
