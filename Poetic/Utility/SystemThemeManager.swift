//
//  ThemeManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import UIKit

class SystemThemeManager {
    static let shared = SystemThemeManager()
    private init() { }

    func handleTheme(darkMode: Bool, system: Bool) {
        guard !system else {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = .unspecified
            return
        }

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}
