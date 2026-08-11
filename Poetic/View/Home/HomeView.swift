//
//  HomeView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/07/09.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PoemViewModel
    @EnvironmentObject var store: PoemStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                backgroundImage
                ScrollView(.vertical, showsIndicators: false) {
                    content
                }
                .refreshable {
                    viewModel.loadRandomPoems(number: "5")
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var backgroundImage: some View {
        Image(colorScheme == .light ? "background" : "background-dark")
            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
            .ignoresSafeArea(.all)
    }

    private var content: some View {
        VStack(alignment: .leading) {
            header
            discoverText
            recommendedSection
            recentSection
        }
        .padding(.top, 24)
    }

    private var header: some View {
        Text("Poetic.")
            .fontWithLineHeight(font: Fonts.newYorkFont, lineHeight: 48)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
    }

    private var discoverText: some View {
        Text("Discover Classic Poetry!")
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 16)
            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
            .padding(.horizontal, 16)
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("Recommended")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    switch viewModel.state {
                    case .idle, .loading:
                        RedactedPoemCardView(type: .idle).disabled(true)
                    case .failed:
                        RedactedPoemCardView(type: .failed).disabled(true)
                    case .loaded:
                        poemCards
                    }
                }
                .padding(.leading, 8)
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("Recent")
            if store.recents.isEmpty {
                ContentUnavailableView("No recents", systemImage: "text.page")
            } else {
                viewedPoemsList
            }
        }
    }

    private var poemCards: some View {
        ForEach(viewModel.randomPoems, id: \.self) { poem in
            NavigationLink {
                DetailView(poem: poem)
            } label: {
                PoemCard(poem: poem)
            }
            .buttonStyle(FlatLinkStyle())
        }
    }

    private var viewedPoemsList: some View {
        ForEach(store.recents, id: \.self) { poem in
            NavigationLink {
                DetailView(poem: poem.asPoem())
            } label: {
                TitleAuthorDateHomeCell(poem: poem)
            }
            .buttonStyle(FlatLinkStyle())
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.primary)
            .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
            .padding(.horizontal, 16)
            .padding(.top, 12)
    }
}
