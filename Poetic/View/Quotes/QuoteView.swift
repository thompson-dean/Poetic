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
    
    @State private var showShareSheet = false
    
    let links = Links()
    
    init(viewModel: PoemViewModel, pcViewModel: PersistenceController) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        self.viewModel = viewModel
        self.pcViewModel = pcViewModel
    }
    
    var body: some View {
        NavigationView {
            if pcViewModel.quotes.isEmpty {
                VStack {
                    VStack {
                        HStack {
                            Image(systemName: "quote.bubble")
                                .foregroundColor(.primary)
                                .font(.title)
                                .padding(.vertical, 8)
                                .padding(.leading, 8)
                            VStack(alignment: .leading, spacing: 2) {
                                
                                Text("No favorited quotes...")
                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                    .foregroundColor(.primary)
                                
                                Text("Long press lines to save quotes.")
                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                    .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            Spacer()
                        }
                    
                    }
                    .background(colorScheme == .light ? .white : .black)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                    Spacer()
                }
                .background(
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea(.all)
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
                           
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
            } else {
                if #available(iOS 16.0, *) {
                    List {
                        ForEach(0..<pcViewModel.quotes.count, id: \.self) { index in
                            ZStack {
                                NavigationLink {
                                    if let poem = pcViewModel.favoritedQuotesPoem.first(where: { $0.title == pcViewModel.quotes[index].title }) {
                                        NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: Poem(title: poem.title ?? "Unknown", author: poem.author ?? "Unknown", lines: poem.lines ?? ["Unknown"], linecount: "0"))
                                    }
                                } label: {
                                    EmptyView().opacity(0)
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(("""
                                                            "\(pcViewModel.quotes[index].quote ?? "Unknown Line")"
                                                        """).trimmingCharacters(in: .whitespacesAndNewlines))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                            
                                            Text(pcViewModel.quotes[index].title ?? "Unknown Title")
                                                .fixedSize(horizontal: false, vertical: true)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .semibold), lineHeight: 16)
                                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                            
                                            Text(pcViewModel.quotes[index].author ?? "Unknown Title")
                                                .fixedSize(horizontal: false, vertical: true)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .regular), lineHeight: 16)
                                                .foregroundColor(.primary)
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
                                    links.shareQuote(quote: pcViewModel.quotes[index].quote!, title: pcViewModel.quotes[index].title ?? "", author: pcViewModel.quotes[index].author ?? "")
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
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
                } else {
                    List {
                        ForEach(0..<pcViewModel.quotes.count, id: \.self) { index in
                            ZStack {
                                NavigationLink {
                                    if let poem = pcViewModel.favoritedQuotesPoem.first(where: { $0.title == pcViewModel.quotes[index].title }) {
                                        NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: Poem(title: poem.title ?? "Unknown", author: poem.author ?? "Unknown", lines: poem.lines ?? ["Unknown"], linecount: "0"))
                                    }
                                } label: {
                                    EmptyView().opacity(0)
                                }
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(("""
                                                            "\(pcViewModel.quotes[index].quote ?? "Unknown Line")"
                                                        """).trimmingCharacters(in: .whitespacesAndNewlines))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                            
                                            Text(pcViewModel.quotes[index].title ?? "Unknown Title")
                                                .fixedSize(horizontal: false, vertical: true)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .semibold), lineHeight: 16)
                                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                            
                                            Text(pcViewModel.quotes[index].author ?? "Unknown Title")
                                                .fixedSize(horizontal: false, vertical: true)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .regular), lineHeight: 16)
                                                .foregroundColor(.primary)
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
                                    links.shareQuote(quote: pcViewModel.quotes[index].quote!, title: pcViewModel.quotes[index].title ?? "", author: pcViewModel.quotes[index].author ?? "")
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
                        .onDelete { indexSet in
                            pcViewModel.deleteFavoritedPoem(indexSet: indexSet)
                        }
                    }
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .background(
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea(.all)
                    )
                    .navigationTitle("Quotes")
                    .navigationBarTitleDisplayMode(.inline)
                    .foregroundColor(.primary)
                    .onAppear {
                        pcViewModel.fetchQuotes()
                    }
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
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteView(viewModel: PoemViewModel(), pcViewModel: PersistenceController())
    }
}
