//
//  SearchView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var authorSearch = false
    @State var authorSearchTerm = ""
    
    var colors = Colors()
    var body: some View {
        NavigationView {
            ZStack {

                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Picker("", selection: $authorSearch) {
                        Text("Title").tag(false)
                        Text("Author").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if authorSearch {
                        SearchBar(searchTerm: $authorSearchTerm)
                            .padding(.horizontal, 8)
                    } else {
                        SearchBar(searchTerm: $viewModel.searchTerm)
                            .padding(.horizontal, 8)
                    }
                    
                    
                    switch authorSearch {
                    case true:
                        List {
                            ForEach(authors.authors.filter { author in
                                authorSearchTerm.isEmpty || author.lowercased().contains(authorSearchTerm.lowercased())
                            }, id: \.self) { author in
                                NavigationLink {
                                    AuthorView(viewModel: viewModel, pcViewModel: pcViewModel, author: author)
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(author)
                                                .font(.system(.headline, design: .serif))
                                        }
                                    }
                                }
                            }
                        }
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                        }
                            
                    case false:
                        
                        switch viewModel.searchState {
                        case .idle:
                            idleView
                            
                        case .loading:
                            VStack(alignment: .center) {
                                ProgressView()
                            }
                            .frame(maxWidth: . infinity)
                            
                        case .failed:
                            showFailView
                            
                        case .loaded:
                            resultsListView
                        }
                    }
                    
                    Spacer()
                }
                .onChange(of: viewModel.searchTerm) { _ in
                    if !authorSearch {
                        viewModel.loadPoem(searchTerm: viewModel.searchTerm, filter: .title)
                    }
                }

                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(.primary)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }   
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: PoemViewModel(), pcViewModel: PersistenceController())
    }
}

extension SearchView {
    
    var idleView: some View {
        VStack(alignment: .center) {
            
            Image(systemName: "doc.text.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 150)
            
            Text("Start searching for poems!")
                .font(.system(.title, design: .serif))
        }
        .frame(maxWidth: .infinity)
    }
    
    var showFailView: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .padding(.top)
            
            Text("No titles for this search. Try again.")
                .font(.system(.body, design: .serif))
                .padding()
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
    }
    
    var resultsListView: some View {
        GeometryReader { geo in
            List {
                ForEach(viewModel.poems, id: \.self) { poem in
                NavigationLink {
                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                } label: {
                    VStack(alignment: .center) {
                        
                        HStack {
                            Text(poem.title)
                                .font(.system(.headline, design: .serif))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        HStack {
                            Text(poem.author)
                                .font(.system(.subheadline, design: .serif))
                            Spacer()
                        }
                    }
                }
            }
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}
