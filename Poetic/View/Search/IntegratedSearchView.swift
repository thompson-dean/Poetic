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
    @State private var didFail: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var isFocused: Bool
    var authors: Authors = Bundle.main.decode("Authors.json")

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundImage
                VStack(alignment: .leading) {
                    searchResultsView
                }
                .onChange(of: viewModel.searchState) { _, newState in
                    if newState == .failed {
                        alertMessage = viewModel.searchListLoadingError
                        didFail = true
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $didFail) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchTerm, prompt: "Poems, lines, or poets")
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var backgroundImage: some View {
        Image(colorScheme == .light ? "background" : "background-dark")
            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
            .ignoresSafeArea()
    }

    @ViewBuilder
    private var searchResultsView: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                switch viewModel.searchState {
                case .idle, .failed:
                    featuredAndRecommendedAuthors
                case .loading:
                    loadingView
                case .loaded:
                    loadedResults
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var featuredAndRecommendedAuthors: some View {
        VStack(alignment: .leading) {
            Text("Featured Authors")
                .foregroundColor(.primary)
                .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                .padding(.horizontal, 16)

            ForEach(Array(viewModel.featuredAuthors.enumerated()), id: \.element) { index, author in
                NavigationLink {
                    AuthorView(viewModel: viewModel, author: author)
                } label: {
                    AuthorCell(author: author, badge: index == 0 ? "Poet of the Day" : nil)
                }
                .buttonStyle(FlatLinkStyle())
            }

            NavigationLink {
                AuthorIndexView(viewModel: viewModel, authors: authors.authors)
            } label: {
                HStack {
                    Text("Browse all authors")
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            .buttonStyle(FlatLinkStyle())

            Text("Discover")
                .foregroundColor(.primary)
                .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ForEach(viewModel.discoverPoems, id: \.self) { poem in
                NavigationLink {
                    DetailView(poem: poem)
                } label: {
                    PoemCell(poem: poem, colorScheme: colorScheme)
                }
                .buttonStyle(FlatLinkStyle())
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.randomPoems, id: \.self) { poem in
                PoemCell(poem: poem, colorScheme: colorScheme)
                    .redacted(reason: .placeholder)
            }
        }
    }

    @ViewBuilder
    private var loadedResults: some View {
        LazyVStack(alignment: .leading) {
            if !viewModel.searchAuthors.isEmpty {
                sectionTitle("Poets")
                ForEach(viewModel.searchAuthors, id: \.self) { author in
                    NavigationLink {
                        AuthorView(viewModel: viewModel, author: author)
                    } label: {
                        AuthorCell(author: author)
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }

            if !viewModel.searchPoems.isEmpty {
                sectionTitle("Poems")
                ForEach(viewModel.searchPoems, id: \.self) { match in
                    NavigationLink {
                        DetailView(poem: match.poem)
                    } label: {
                        SearchResultCell(match: match, colorScheme: colorScheme)
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }

            if viewModel.searchAuthors.isEmpty && viewModel.searchPoems.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchTerm)
                    .padding(.top, 40)
            }
        }
        .padding(.top, 8)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.primary)
            .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

struct AuthorIndexView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: PoemViewModel
    let authors: [String]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                ForEach(authors, id: \.self) { author in
                    NavigationLink {
                        AuthorView(viewModel: viewModel, author: author)
                    } label: {
                        AuthorCell(author: author)
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }
            .padding(.top, 8)
        }
        .background(
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea()
        )
        .navigationTitle("All Authors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchResultCell: View {
    let match: PoemSearchMatch
    let colorScheme: ColorScheme

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.poem.author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                        .foregroundColor(.primary)

                    Text(match.poem.title)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)

                    if let line = match.matchedLine {
                        Text("“\(line)”")
                            .fontWithLineHeight(font: .italicSystemFont(ofSize: 14), lineHeight: 20)
                            .foregroundColor(.primary.opacity(0.6))
                            .lineLimit(1)
                    }
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
}

struct PoemCell: View {
    let poem: Poem
    let colorScheme: ColorScheme

    var body: some View {
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
        .frame(maxWidth: .infinity)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}
