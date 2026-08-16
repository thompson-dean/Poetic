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
    @Binding var path: NavigationPath
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .leading) {
                backgroundImage
                ScrollView(.vertical, showsIndicators: false) {
                    content
                }
                .refreshable {
                    viewModel.loadRandomPoems(number: "5")
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(.primary)
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: Poem.self) { poem in
                DetailView(poem: poem, source: "deep_link")
            }
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
            poetOfTheDaySection
            recentSection
        }
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

    private var poetOfTheDaySection: some View {
        VStack(alignment: .leading) {
            if let poet = DailyPoetPicker.poet(for: Date(), in: PoetBios.all) {
                sectionTitle("Poet of the Day")
                NavigationLink {
                    AuthorView(viewModel: viewModel, author: poet.author)
                } label: {
                    PoetOfTheDayCard(bio: poet)
                }
                .buttonStyle(FlatLinkStyle())
                .simultaneousGesture(TapGesture().onEnded {
                    AnalyticsEvents.poetOfTheDayOpened(author: poet.author, surface: "home")
                })
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("Recent")
            if store.recents.isEmpty {
                Text("Poems you read will appear here.")
                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            } else {
                viewedPoemsList
            }
        }
    }

    private var poemCards: some View {
        ForEach(viewModel.randomPoems, id: \.self) { poem in
            NavigationLink {
                DetailView(poem: poem, source: "home_recommended")
            } label: {
                PoemCard(poem: poem)
            }
            .buttonStyle(FlatLinkStyle())
        }
    }

    /// Capped: recents only expire after 14 days, so a heavy reader could
    /// otherwise put hundreds of rows on the home screen.
    private var viewedPoemsList: some View {
        ForEach(store.recents.prefix(20), id: \.self) { poem in
            NavigationLink {
                DetailView(poem: poem.asPoem(), source: "home_recent")
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
