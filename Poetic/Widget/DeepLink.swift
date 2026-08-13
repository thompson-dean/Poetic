//
//  DeepLink.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

/// URLs the widgets use to open the app: poetic://poem?title=…&author=…,
/// poetic://favorites, poetic://support, poetic://home.
enum DeepLink: Equatable {
    case poem(title: String, author: String)
    case favorites
    case support
    case home

    static let scheme = "poetic"

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .poem(let title, let author):
            components.host = "poem"
            components.queryItems = [
                URLQueryItem(name: "title", value: title),
                URLQueryItem(name: "author", value: author)
            ]
        case .favorites:
            components.host = "favorites"
        case .support:
            components.host = "support"
        case .home:
            components.host = "home"
        }
        return components.url ?? URL(fileURLWithPath: "/")
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        switch components.host {
        case "poem":
            let items = components.queryItems ?? []
            guard let title = items.first(where: { $0.name == "title" })?.value,
                  let author = items.first(where: { $0.name == "author" })?.value,
                  !title.isEmpty, !author.isEmpty else {
                return nil
            }
            self = .poem(title: title, author: author)
        case "favorites":
            self = .favorites
        case "support":
            self = .support
        case "home":
            self = .home
        default:
            return nil
        }
    }
}
