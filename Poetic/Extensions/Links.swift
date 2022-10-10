//
//  Links.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import Foundation
import SwiftUI

class Links {
    let twitterURLString = "https://twitter.com/DeanWThompson"
    let twitterPoeticURLString = "https://twitter.com/PoeticApp"
    let poetryDBURLSTring = "https://github.com/thundercomb/poetrydb"
    let PoeticURLString = "https://github.com/thompson-dean/Poetic"
    let appStoreDeepLink = "itms-apps://apple.com/app/id1614416936"
    let appStoreWebsiteLink = "https://apps.apple.com/us/app/poetic/id1614416936"
    let gitHubLink = "https://github.com/thompson-dean"
    
    func shareQuote(quote: String, title: String, author: String) {
        let sharedString = """
"\(quote)" A quote from \(title) by \(author), found on Poetic, your favorite classical poetry app. Available here:  https://apps.apple.com/us/app/poetic/id1614416936
"""
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    func sharePoem(poem: [String], title: String, author: String) {
        let sharedString = """
\(title) by \(author) \n \(poem.joined(separator: "\n")) \n
Found on Poetic, your favorite classical poetry app. Available here:  https://apps.apple.com/us/app/poetic/id1614416936
"""
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    func shareApp() {
        let sharedString = "https://apps.apple.com/us/app/poetic/id1614416936"
        
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    
}
