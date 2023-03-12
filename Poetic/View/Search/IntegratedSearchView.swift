//
//  IntegratedSearchView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/09.
//

import SwiftUI
import PKHUD

struct IntegratedSearchView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var isLoading: Bool = false
    @State private var didFail: Bool = false
    @FocusState private var isFocused: Bool
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    SearchBar(searchTerm: $viewModel.searchTerm)
                        .padding(.bottom, -4)
                        .focused($isFocused)
                    Picker("", selection: $viewModel.isTitle) {
                        Text("Title").tag(true)
                        Text("Author").tag(false)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 8)
                    VStack(alignment: .leading) {
                        
                        ScrollView(showsIndicators: false) {
                            if viewModel.isTitle {
                                switch viewModel.searchState {
                                case .idle, .failed:
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        VStack(alignment: .leading) {
                                            Text("Featured Authors")
                                                .foregroundColor(.primary)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                                                .padding(.horizontal, 8)
                                            
                                            NavigationLink {
                                                AuthorView(viewModel: viewModel, pcViewModel: pcViewModel, author: viewModel.featuredAuthor1)
                                            } label: {
                                                AuthorCell(author: viewModel.featuredAuthor1)
                                            }
                                            .buttonStyle(FlatLinkStyle())
                                            
                                            NavigationLink {
                                                AuthorView(viewModel: viewModel, pcViewModel: pcViewModel, author: viewModel.featuredAuthor2)
                                            } label: {
                                                AuthorCell(author: viewModel.featuredAuthor2)
                                            }
                                            .buttonStyle(FlatLinkStyle())
                                            
                                            NavigationLink {
                                                AuthorView(viewModel: viewModel, pcViewModel: pcViewModel, author: viewModel.featuredAuthor3)
                                            } label: {
                                                AuthorCell(author: viewModel.featuredAuthor3)
                                            }
                                            .buttonStyle(FlatLinkStyle())
                                            
                                            Text("Recommended")
                                                .foregroundColor(.primary)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                                                .padding(.horizontal, 8)
                                                .padding(.top, 8)
                                            
                                            ForEach(viewModel.randomPoems, id: \.self) { poem in
                                                NavigationLink {
                                                    let sentPoem = Poem(title: poem.title , author: poem.author , lines: poem.lines , linecount: poem.title)
                                                    NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                                                } label: {
                                                    VStack {
                                                        HStack {
                                                            VStack(alignment: .leading, spacing: 2) {
                                                                
                                                                Text(poem.author)
                                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                                    .foregroundColor(.primary)
                                                                
                                                                Text(poem.title)
                                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                                    .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                                            }
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 8)
                                                            
                                                            Spacer()
                                                            
                                                            Image(systemName: "chevron.right")
                                                                .foregroundColor(.primary)
                                                                .padding(8)
                                                        }
                                                    }
                                                    .frame(width: UIScreen.main.bounds.width - 16)
                                                    .background(colorScheme == .light ? .white : .black)
                                                    .cornerRadius(8)
                                                    .padding(.horizontal, 8)
                                                }
                                                .buttonStyle(FlatLinkStyle())
                                            }
                                        }
                                        .padding(.top, 8)
                                    }
                                    
                                case  .loading:
                                    VStack(alignment: .leading) {
                                        ForEach(viewModel.randomPoems, id: \.self) { poem in
                                            VStack {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        
                                                        Text(poem.author)
                                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                            .foregroundColor(.primary)
                                                        
                                                        Text(poem.title)
                                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 8)
                                                    
                                                    Spacer()
                                                }
                                            }
                                            .frame(width: UIScreen.main.bounds.width - 16)
                                            .background(colorScheme == .light ? .white : .black)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                    .redacted(reason: .placeholder)
                                    
                                case .loaded:
                                    ForEach(viewModel.poems, id: \.self) { poem in
                                        NavigationLink {
                                            let sentPoem = Poem(title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.title)
                                            NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                                        } label: {
                                            LazyVStack {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(poem.title)
                                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                                        Text(poem.author)
                                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                            .foregroundColor(.primary)
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 8)
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.primary)
                                                        .padding(8)
                                                }
                                            }
                                            .background(colorScheme == .light ? .white : .black)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 8)
                                        }
                                        .buttonStyle(FlatLinkStyle())
                                        .disabled(isFocused)
                                    }
                                }
                            } else {
                                ForEach(authors.authors.filter { author in
                                    viewModel.searchTerm.isEmpty || author.lowercased().contains(viewModel.searchTerm.lowercased())
                                }, id: \.self) { author in
                                    NavigationLink {
                                        AuthorView(viewModel: viewModel, pcViewModel: pcViewModel, author: author)
                                    } label: {
                                        AuthorCell(author: author)
                                    }
                                    .buttonStyle(FlatLinkStyle())
                                    .disabled(isFocused)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .onTapGesture {
                        isFocused = false
                    }
                }
                .onAppear {
                    viewModel.listenToSearch()
                }
                .onChange(of: viewModel.searchState) { _ in
                    switch viewModel.searchState {
                    case .idle:
                        didFail = false
                    case .loading:
                        didFail = false
                    case .failed:
                        didFail = true
                    case .loaded:
                        didFail = false
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .PKHUD(isPresented: $didFail, HUDContent: .labeledError(title: "No Result or Error.", subtitle: "Try again."), delay: 1)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
