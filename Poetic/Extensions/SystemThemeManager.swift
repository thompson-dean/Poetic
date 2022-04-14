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
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            return
        }
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}
