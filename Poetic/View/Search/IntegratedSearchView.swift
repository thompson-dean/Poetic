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
                    HStack(spacing: 16) {
                        Button {
                            viewModel.isTitle = true
                        } label: {
                            Text("title")
                                .fontWeight(viewModel.isTitle ? .bold : .regular)
                                .fontWithLineHeight(font: .systemFont(ofSize: 16), lineHeight: 16)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 2)
                                )
                        }
                        .disabled(viewModel.isTitle)
                        .foregroundColor(viewModel.isTitle ? colorScheme == .light ? .lightThemeColor : .darkThemeColor : .primary)
                        Button {
                            viewModel.isTitle = false
                        } label: {
                            Text("author")
                                .fontWeight(viewModel.isTitle ? .regular : .bold)
                                .fontWithLineHeight(font: .systemFont(ofSize: 16), lineHeight: 16)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 2)
                                )
                        }
                        .disabled(!viewModel.isTitle)
                        .foregroundColor(viewModel.isTitle ? .primary : colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
                    
                    
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
                                                .padding(.top, 16)
                                        
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
                                                .padding(.top, 16)
                                        
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
                                }
                                
                            case  .loading:
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(alignment: .leading) {
                                        ForEach(viewModel.randomPoems, id: \.self) { poem in
                                            VStack(alignment: .leading, spacing: 2) {
                                                
                                                Text(poem.author)
                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(3)
                                                
                                                Text(poem.title)
                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                    .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                                    .lineLimit(3)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                    .redacted(reason: .placeholder)
                                }
                            
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
                                }
                            }
                        
                        
                    }
                    .onTapGesture {
                        isFocused = false
                    }
                    Spacer()
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


