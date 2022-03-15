//
//  SearchView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct SearchView: View {
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var authorSearch = false
    @State var authorSearchTerm = ""
    
    var colors = Colors()
    var body: some View {
        NavigationView {
            ZStack {
//                colors.lightPink
//                    .ignoresSafeArea(.all)
                Image("background")
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
                                authorSearchTerm.isEmpty || author.contains(authorSearchTerm)
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
                    if authorSearch {

                    } else {
                        viewModel.loadPoem(searchTerm: viewModel.searchTerm, filter: .title)
                    }
                }
                
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(.black)
            }
            
            
        }
        
    }
        
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}

extension SearchView {
    
    var idleView: some View {
        VStack(alignment: .center) {
            
            Image(systemName: "eyeglasses")
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
                .frame(width: 250, height: 200)
            
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
                .frame(width: 150, height: 100)
                .padding(.top)
            
            Text("No titles for this search. Try again.")
                .font(.system(.title3, design: .serif))
                .padding()
        }
        .foregroundColor(.black).opacity(0.7)
        .frame(maxWidth: . infinity)
    }
    
    var resultsListView: some View {
        GeometryReader { geo in
            List {
            ForEach(viewModel.poems) { poem in
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
