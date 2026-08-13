//
//  Constants.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import Foundation

enum Constants {
    static let appName = "Poetic"
    static let darkModeEnable = "darkModeEnabled"
    static let systemThemeEnabled = "systemThemeEnabled"
    static let featuredAuthor1 = "featuredAuthor1"
    static let featuredAuthor2 = "featuredAuthor2"
    static let featuredAuthor3 = "featuredAuthor3"

    static let supporterIdentifier = "Dean.Thompson.Poetic.supporter"

    static let tipIdentifiers = [
        "Dean.Thompson.Poetic.smallTip",
        "Dean.Thompson.Poetic.mediumTip",
        "Dean.Thompson.Poetic.largeTip"
    ]

    static let storeKitIdentifiers = tipIdentifiers + [supporterIdentifier]
}
