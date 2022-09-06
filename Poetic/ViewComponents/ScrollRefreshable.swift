//
//  ScrollRefreshable.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/06.
//

import SwiftUI

struct ScrollRefreshable<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var content: Content
    var onRefresh: () -> Void
    
    init(@ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
        
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .menuIndicator(.hidden)
        }
        .listStyle(.plain)
        .refreshable {
            onRefresh()
        }
    }
}
