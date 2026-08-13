//
//  QuoteView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/12.
//

import SwiftUI

struct QuoteView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: PoemViewModel
    @EnvironmentObject var store: PoemStore

    init(viewModel: PoemViewModel) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                if store.quotes.isEmpty {
                    ContentUnavailableView(
                        "No favourite quotes yet!",
                        systemImage: "quote.bubble",
                        description: Text("Long press to save your favourite quotes.")
                    )
                } else {
                    List {
                        ForEach(0..<store.quotes.count, id: \.self) { index in
                            ZStack {
                                NavigationLink {
                                    DetailView(poem: store.quotes[index].poem.asPoem())
                                } label: {
                                    EmptyView().opacity(0)
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(store.quotes[index].quote
                                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                            )
                                            .fixedSize(horizontal: false, vertical: true)
                                            .fontWithLineHeight(
                                                font: .systemFont(ofSize: 16, weight: .bold),
                                                lineHeight: 24
                                            )

                                            Text(store.quotes[index].poem.author)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .fontWithLineHeight(
                                                    font: .systemFont(ofSize: 16, weight: .semibold),
                                                    lineHeight: 24
                                                )
                                                .foregroundColor(
                                                    colorScheme == .light ? .lightThemeColor : .darkThemeColor
                                                )
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                }
                                .background(colorScheme == .light ? .white : .black)
                                .cornerRadius(8)
                                .padding(.vertical, 4)

                            }
                            .contextMenu {
                                Button {
                                    Links.shareQuote(
                                        quote: store.quotes[index].quote,
                                        title: store.quotes[index].poem.title,
                                        author: store.quotes[index].poem.author
                                    )
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete { indexSet in
                            store.deleteQuotes(at: indexSet)
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
                    .ignoresSafeArea()
            )
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.primary)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.quoteSort = store.quoteSort == .quote ? .title : .quote
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
