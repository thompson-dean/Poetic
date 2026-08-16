//
//  FavoritesView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var storeKitManager: StoreKitManager
    @EnvironmentObject var store: PoemStore
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            VStack {
                if store.favorites.isEmpty {
                    ContentUnavailableView(
                        "No favourites yet!",
                        systemImage: "star",
                        description: Text("Tap the star to save your favourite poems.")
                    )
                } else {
                    List {
                        ForEach(store.favorites) { poem in
                            ZStack {
                                NavigationLink {
                                    DetailView(poem: poem.asPoem(), source: "favorites")
                                } label: {
                                    EmptyView().opacity(0.0)
                                }
                                TitleAuthorFavoriteCell(poem: poem)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete { indexSet in
                            store.deleteFavorites(at: indexSet)
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                    if !storeKitManager.isSupporter {
                        widgetNudge
                    }
                }
            }
            .background(
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea(.all)
            )
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.primary)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    sortMenu
                }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $store.favoriteSort) {
                ForEach(PoemStore.FavoriteSort.allCases) { sort in
                    Text(sort.label).tag(sort)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort favorites")
    }

    /// The most contextual supporter nudge in the app: the user is looking
    /// at exactly the poems the gated widget would show.
    private var widgetNudge: some View {
        Button {
            showSettings = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "star.square.on.square")
                Text("Get these on your home screen — leave any tip")
            }
            .font(.footnote.weight(.semibold))
            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
        }
        .padding(.bottom, 8)
    }
}
