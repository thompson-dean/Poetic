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
    @State private var authorSearchTerm: String = ""
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    SearchBar(searchTerm: $viewModel.searchTerm)
                    if !viewModel.searchTerm.isEmpty {
                        HStack(spacing: 16) {
                            Button {
                                viewModel.isTitle = true
                            } label: {
                                Text("title")
                                    .fontWeight(viewModel.isTitle ? .semibold : .regular)
                                    .fontWithLineHeight(font: .systemFont(ofSize: 18), lineHeight: 18)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 2)
                                    )
                            }
                            .disabled(viewModel.isTitle)
                            .foregroundColor(viewModel.isTitle ? colorScheme == .light ? .lightThemeColor : .darkThemeColor : .primary)
                            Button {
                                viewModel.isTitle = false
                            } label: {
                                Text("author")
                                    .fontWeight(viewModel.isTitle ? .regular : .semibold)
                                    .fontWithLineHeight(font: .systemFont(ofSize: 18), lineHeight: 18)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 2)
                                    )
                            }
                            .disabled(!viewModel.isTitle)
                            .foregroundColor(viewModel.isTitle ? .primary : colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                    }
                        
                    ScrollView(showsIndicators: false) {
                        if viewModel.isTitle {
                            switch viewModel.searchState {
                            case .idle:
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.primary)
                                            .font(.largeTitle)
                                            .padding(.vertical, 8)
                                            .padding(.leading, 8)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Search for poems or authors.")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            Text("Thousands of poems to discover!")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
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
                            case .loading:
                                VStack {
                                    ProgressView()
                                        .padding()
                                    VStack {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundColor(.primary)
                                                .font(.largeTitle)
                                                .padding(.vertical, 8)
                                                .padding(.leading, 8)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Search for poems or authors.")
                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                    .foregroundColor(.primary)
                                                Text("Thousands of poems to discover!")
                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
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
                                    .redacted(reason: .placeholder)
                                }
                                
                            case .failed:
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.primary)
                                            .font(.largeTitle)
                                            .padding(.vertical, 8)
                                            .padding(.leading, 8)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Search for poems or authors.")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            Text("Thousands of poems to discover!")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
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
                                }
                            }
                                
                            } else {
                                ForEach(authors.authors.filter { author in
                                    viewModel.searchTerm.isEmpty || author.lowercased().contains(viewModel.searchTerm.lowercased())
                                }, id: \.self) { author in
                                    NavigationLink {
                                        Text("Author View: \(author)")
                                    } label: {
                                        LazyVStack {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(author)
                                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
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
    }
}
