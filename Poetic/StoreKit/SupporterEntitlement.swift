//
//  SupporterEntitlement.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

/// Persists the supporter unlock so the widget extension can read it.
/// Pure persistence — no StoreKit — so it compiles into the widget target
/// and is trivially testable.
struct SupporterEntitlement {
    private let defaults: UserDefaults

    /// Falls back to .standard when the App Group container isn't available
    /// yet (before the capability is registered in Xcode).
    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
            ?? UserDefaults(suiteName: SharedConstants.appGroupID)
            ?? .standard
    }

    var isSupporter: Bool {
        defaults.bool(forKey: SharedConstants.supporterDefaultsKey)
    }

    func set(_ value: Bool) {
        defaults.set(value, forKey: SharedConstants.supporterDefaultsKey)
    }
}
