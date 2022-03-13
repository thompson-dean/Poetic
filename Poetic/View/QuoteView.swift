//
//  QuoteView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/12.
//

import SwiftUI

struct QuoteView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                    List {
                        ForEach(0..<viewModel.quotes.count, id: \.self) { index in
                            VStack(alignment: .center, spacing: 4) {
                                
                                Text(("""
                                            "\(viewModel.quotes[index].quote)"
                                        """).trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.system(.headline, design: .serif))
                                    .multilineTextAlignment(.center)
                                
                                
                                
                                HStack {
                                    Spacer()
                                    
                                    Text(viewModel.quotes[index].title)
                                        .font(.system(.caption, design: .serif))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("-")
                                        .font(.system(.caption, design: .serif))
                                    
                                    Text(viewModel.quotes[index].author)
                                        .italic()
                                        .font(.system(.caption, design: .serif))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    
                                }
                                
                            }
                            .padding(.horizontal, 5)
                        }
                        .onDelete(perform: removeRows)
                    }
                    .background(
                        Image("background")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()
                        
                    )
                    .onAppear {
                        // Set the default to clear
                        UITableView.appearance().backgroundColor = .clear
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
    
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteView(viewModel: SearchViewModel())
    }
}
