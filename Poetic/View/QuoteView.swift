//
//  QuoteView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/12.
//

import SwiftUI

struct QuoteView: View {
   
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var showShareSheet = false
    
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
                                    shareQuote(quote: pcViewModel.quotes[index].quote!, title: pcViewModel.quotes[index].title ?? "", author: pcViewModel.quotes[index].author ?? "")
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
                        Image("background")
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
                    .foregroundColor(.black)
                
                
                
            }
            .toolbar {
                EditButton()
            }
        }
        
    }
    func removeRows(at offsets: IndexSet) {
        viewModel.quotes.remove(atOffsets: offsets)
    }
    
    func shareQuote(quote: String, title: String, author: String) {
        let sharedString = """
"\(quote)" A quote from \(title) by \(author), found on Poetic, your favorite classical poetry app. Available here:  https://apps.apple.com/us/app/poetic/id1614416936
"""
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}
