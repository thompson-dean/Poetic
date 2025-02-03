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
    @ObservedObject var pcViewModel: PersistenceController

    init(viewModel: PoemViewModel, pcViewModel: PersistenceController) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
        self.viewModel = viewModel
        self.pcViewModel = pcViewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                if pcViewModel.favoritedPoems.isEmpty {
                    ContentUnavailableView(
                        "No favourites yet!",
                        systemImage: "star",
                        description: Text("Tap the star to save your favourite poems.")
                    )
                } else {
                    List {
                        ForEach(pcViewModel.favoritedPoems) { poem in
                            ZStack {
                                NavigationLink {
                                    let sentPoem = Poem(
                                        title: poem.title ?? "",
                                        author: poem.author ?? "",
                                        lines: poem.lines ?? [],
                                        linecount: poem.linecount ?? ""
                                    )
                                    DetailView(
                                        pcViewModel: pcViewModel,
                                        poem: sentPoem
                                    )
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
                            pcViewModel.deleteFavoritedPoem(indexSet: indexSet)
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
            .onAppear {
                pcViewModel.fetchFavoritedPoems()
            }
            .toolbar {
                ToolbarItem {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        pcViewModel.poemsFilter.toggle()
                        pcViewModel.fetchFavoritedPoems()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}
