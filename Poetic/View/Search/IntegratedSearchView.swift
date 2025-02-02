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
    @State private var didFail: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var isFocused: Bool
    var authors: Authors = Bundle.main.decode("Authors.json")

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundImage
                VStack(alignment: .leading) {
                    searchTypePicker
                    searchResultsView
                }
                .onAppear {
                    viewModel.listenToSearch()
                }
                .onChange(of: viewModel.searchState) { newState, _ in
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
        .searchable(text: $viewModel.searchTerm)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var backgroundImage: some View {
        Image(colorScheme == .light ? "background" : "background-dark")
            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
            .ignoresSafeArea()
    }

    private var searchTypePicker: some View {
        Picker("", selection: $viewModel.isTitle) {
            Text("Title").tag(true)
            Text("Author").tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, viewModel.isTitle ? 0 : 8)
    }

    @ViewBuilder
    private var searchResultsView: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                if viewModel.isTitle {
                    titleSearchResults
                } else {
                    authorSearchResults
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var titleSearchResults: some View {
        switch viewModel.searchState {
        case .idle, .failed:
            featuredAndRecommendedAuthors
        case .loading:
            loadingView
        case .loaded:
            loadedTitleResults
        }
    }

    @ViewBuilder
    private var featuredAndRecommendedAuthors: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Featured Authors")
                    .foregroundColor(.primary)
                    .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                    .padding(.horizontal, 16)

                ForEach(
                    [
                        viewModel.featuredAuthor1,
                        viewModel.featuredAuthor2,
                        viewModel.featuredAuthor3
                    ],
                    id: \.self
                ) { author in
                    NavigationLink {
                        AuthorView(
                            viewModel: viewModel,
                            pcViewModel: pcViewModel,
                            author: author
                        )
                    } label: {
                        AuthorCell(author: author)
                    }
                    .buttonStyle(FlatLinkStyle())
                }

                Text("Recommended")
                    .foregroundColor(.primary)
                    .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                ForEach(viewModel.randomPoems, id: \.self) { poem in
                    NavigationLink {
                        let sentPoem = Poem(
                            title: poem.title,
                            author: poem.author,
                            lines: poem.lines,
                            linecount: poem.title
                        )
                        NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                    } label: {
                        PoemCell(poem: poem, colorScheme: colorScheme)
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }
            .padding(.top, 8)
        }
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
    private var loadedTitleResults: some View {
        ForEach(viewModel.poems, id: \.self) { poem in
            NavigationLink {
                let sentPoem = Poem(title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.title)
                NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
            } label: {
                LazyVStack {
                    PoemCell(poem: poem, colorScheme: colorScheme)
                }
            }
            .buttonStyle(FlatLinkStyle())
        }
    }

    @ViewBuilder
    private var authorSearchResults: some View {
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
        .frame(width: UIScreen.main.bounds.width - 16)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}
