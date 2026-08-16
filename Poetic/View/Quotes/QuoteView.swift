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
                        ForEach(store.quotes) { quote in
                            row(for: quote)
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
                    sortMenu
                }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $store.quoteSort) {
                ForEach(PoemStore.QuoteSort.allCases) { sort in
                    Text(sort.label).tag(sort)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort quotes")
    }

    private func row(for quote: QuoteEntity) -> some View {
        ZStack {
            NavigationLink {
                DetailView(poem: quote.poem.asPoem(), source: "quotes")
            } label: {
                EmptyView().opacity(0)
            }
            QuoteCell(quote: quote, colorScheme: colorScheme)
        }
        .contextMenu {
            shareButton(for: quote)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            shareButton(for: quote)
                .tint(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let index = store.quotes.firstIndex(of: quote) {
                    store.deleteQuotes(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func shareButton(for quote: QuoteEntity) -> some View {
        Button {
            Links.shareQuote(
                quote: quote.quote,
                title: quote.poem.title,
                author: quote.poem.author
            )
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
}

private struct QuoteCell: View {
    let quote: QuoteEntity
    let colorScheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.quote.trimmingCharacters(in: .whitespacesAndNewlines))
                        .fixedSize(horizontal: false, vertical: true)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)

                    Text(quote.poem.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)

                    Text(quote.poem.author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .medium), lineHeight: 20)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(colorScheme == .light ? .white : Color.black)
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}
