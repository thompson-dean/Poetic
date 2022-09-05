//
//  AuthorView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import SwiftUI

struct AuthorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    @State var count = 0
    let author: String
    
    var body: some View {
        
        VStack {
            switch viewModel.state {
                
            case .idle:
                ZStack {
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                    
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: . infinity)
                }
                
                
            case .loading:
                ZStack {
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                    
                    VStack(alignment: .center) {
                        ProgressView("loading")
                    }
                    .frame(maxWidth: . infinity)
                }
                
                
            case .failed:
                ZStack {
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                    
                    VStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .padding()
                        
                        Text("Connection error: Connect to the internet and try again")
                            .font(.system(.body, design: .serif))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: . infinity)
                }
                
                
            case .loaded:
                List(0..<viewModel.authorPoems.count, id: \.self) { index in
                    NavigationLink {
                        DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: viewModel.authorPoems[index].title, author: viewModel.authorPoems[index].author, lines: viewModel.authorPoems[index].lines, linecount: viewModel.authorPoems[index].linecount)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(index + 1)")
                                    .font(.system(.caption2, design: .serif))
                                    .frame(width: 20, height: 10)
                                    .padding(.trailing, 5)
                                Text(viewModel.authorPoems[index].title)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.headline, design: .serif))
                                Spacer()
                                
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .background(
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                )
                .onAppear {
                    // Set the default to clear
                    UITableView.appearance().backgroundColor = .clear
                }
            }
        }
        .navigationTitle(author)
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            viewModel.loadAuthorPoem(searchTerm: author.replacingOccurrences(of: " ", with: "%20"))
            print(viewModel.searchTerm)
            
        }
        
    }
    
}

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView(viewModel: SearchViewModel(), pcViewModel: PersistenceController(), author: "Anne Bronte")
    }
}
