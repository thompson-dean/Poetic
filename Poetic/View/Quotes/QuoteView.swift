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
                if pcViewModel.quotes.isEmpty {
                    ContentUnavailableView(
                        "No favourite quotes yet!",
                        systemImage: "quote.bubble",
                        description: Text("Long press to save your favourite quotes.")
                    )
                } else {
                    List {
                        ForEach(0..<pcViewModel.quotes.count, id: \.self) { index in
                            ZStack {
                                NavigationLink {
                                    if let poem = pcViewModel.favoritedQuotesPoem.first(where: {
                                        $0.title == pcViewModel.quotes[index].title
                                    }) {
                                        DetailView(
                                            pcViewModel: pcViewModel,
                                            poem: Poem(
                                                title: poem.title ?? "Unknown",
                                                author: poem.author ?? "Unknown",
                                                lines: poem.lines ?? ["Unknown"],
                                                linecount: "0"
                                            )
                                        )
                                    }
                                } label: {
                                    EmptyView().opacity(0)
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(("\(pcViewModel.quotes[index].quote ?? "Unknown Line")")
                                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                            )
                                            .fixedSize(horizontal: false, vertical: true)
                                            .fontWithLineHeight(
                                                font: .systemFont(ofSize: 16, weight: .bold),
                                                lineHeight: 24
                                            )

                                            Text(pcViewModel.quotes[index].author ?? "Unknown Title")
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
                                        quote: pcViewModel.quotes[index].quote!,
                                        title: pcViewModel.quotes[index].title ?? "",
                                        author: pcViewModel.quotes[index].author ?? ""
                                    )
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }

                                Button {

                                } label: {
                                    Label("Cancel", systemImage: "delete.left")
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete(perform: pcViewModel.deleteQuotes)
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
            .onAppear {
                pcViewModel.fetchQuotes()
            }
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.primary)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        pcViewModel.quotesFilter.toggle()
                        pcViewModel.fetchQuotes()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
