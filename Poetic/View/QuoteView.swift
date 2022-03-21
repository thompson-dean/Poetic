//
//  QuoteView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/12.
//

import SwiftUI

struct QuoteView: View {
    @Environment(\.colorScheme) var colorScheme
   
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var showShareSheet = false
    
    let links = Links()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                    List {
                        ForEach(0..<pcViewModel.quotes.count, id: \.self) { index in
                            VStack(alignment: .center, spacing: 4) {
                                
                                Text(("""
                                            "\(pcViewModel.quotes[index].quote!)"
                                        """).trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.system(.headline, design: .serif))
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 5)
                                
                                
                                HStack {
                                    Spacer()
                                    
                                    Text(pcViewModel.quotes[index].title ?? "")
                                        .font(.system(.caption, design: .serif))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("-")
                                        .font(.system(.caption, design: .serif))
                                    
                                    Text(pcViewModel.quotes[index].author ?? "")
                                        .italic()
                                        .font(.system(.caption, design: .serif))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    
                                }
                                .padding(.bottom, 5)
                                 
                            }
                            .padding(.horizontal, 5)
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
                        }
                        .onDelete(perform: pcViewModel.deleteQuotes)
                    }
                    .background(
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()
                        
                    )
                    .onAppear {
                        // Set the default to clear
                        UITableView.appearance().backgroundColor = .clear
                        pcViewModel.fetchQuotes()
                    }
                    .navigationTitle("Quotes")
                    .navigationBarTitleDisplayMode(.inline)
                    .foregroundColor(.primary)
                
                
                
            }
            .toolbar {
                EditButton()
            }
        }
        
    }
    func removeRows(at offsets: IndexSet) {
        viewModel.quotes.remove(atOffsets: offsets)
    }
    
    
    
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}
