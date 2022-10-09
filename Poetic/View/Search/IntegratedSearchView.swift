//
//  IntegratedSearchView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/09.
//

import SwiftUI

struct IntegratedSearchView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var isTitle: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    SearchBar(searchTerm: $viewModel.searchTerm)
                    if viewModel.searchTerm.isEmpty {
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    Text("Start Searching!")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                        .foregroundColor(.primary)
                                    
                                    Text("Search through thousands of peoms and authors.")
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
                    } else {
                        HStack(spacing: 16) {
                            Button {
                                isTitle.toggle()
                            } label: {
                                Text("title")
                                    .fontWeight(isTitle ? .semibold : .regular)
                                    .fontWithLineHeight(font: .systemFont(ofSize: 18), lineHeight: 18)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 2)
                                    )
                            }
                            .disabled(isTitle)
                            .foregroundColor(isTitle ? colorScheme == .light ? .lightThemeColor : .darkThemeColor : .primary)
                            Button {
                                isTitle.toggle()
                            } label: {
                                Text("author")
                                    .fontWeight(isTitle ? .regular : .semibold)
                                    .fontWithLineHeight(font: .systemFont(ofSize: 18), lineHeight: 18)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 2)
                                    )
                            }
                            .disabled(!isTitle)
                            .foregroundColor(isTitle ? .primary : colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                    }
                    
                    switch viewModel.searchState {
                        
                    case .idle:
                       Text("IDLE BRO")
                    case .loading:
                        Text("LOADING BRO")
                    case .failed:
                        Text("FAILED BRO")
                    case .loaded:
                        ScrollView(showsIndicators: false) {
                            if isTitle {
                                
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
                                
                            } else {
                                ForEach(viewModel.authorPoems, id: \.self) { poem in
                                    NavigationLink {
                                        Text("Author View: \(poem.author)")
                                    } label: {
                                        LazyVStack {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(poem.author)
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
                                        .background(colorScheme == .light ? .white : .black)
                                        .cornerRadius(8)
                                        .padding(.horizontal, 8)
                                    }
                                    .buttonStyle(FlatLinkStyle())
                                }
                            }
                        }
                        
                    }
                    Spacer()
                }
                .onChange(of: viewModel.searchTerm) { _ in
                    viewModel.fetchTitlesAndAuthors(searchTerm: viewModel.searchTerm)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
