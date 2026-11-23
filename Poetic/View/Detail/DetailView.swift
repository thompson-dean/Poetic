//
//  DetailView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/08/27.
//

import StoreKit
import SwiftUI

extension Notification.Name {
    /// Posted when the reading screen goes away — ContentView uses it to
    /// show the widget announcement after a new user's first poem.
    static let poemDidClose = Notification.Name("poemDidClose")
}

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    @Environment(\.requestReview) private var requestReview
    @State private var showWebView = false
    @Environment(\.isPresented) private var isPresented
    @State private var openedAt = Date()
    @State private var hasLoggedView = false
    @StateObject private var reader = PoemReader()
    @EnvironmentObject var store: PoemStore
    let poem: Poem
    /// Where the poem was opened from — analytics only, defaulted so
    /// incidental call sites don't have to care.
    var source: String = "unknown"

    var body: some View {
        ZStack(alignment: .leading) {
            ThemeBackgroundView()
                .ignoresSafeArea(.all)

            ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {

                    Text("Poetic.")
                        .fontWithLineHeight(font: theme.titleFont(size: 16), lineHeight: 16)
                        .foregroundColor(.primary)

                    Text("Discover Classic Poetry!")
                        .fontWithLineHeight(font: .systemFont(ofSize: 8, weight: .medium), lineHeight: 8)
                        .foregroundColor(theme.accent(for: colorScheme))

                    Text(poem.author)
                        .fontWithLineHeight(font: theme.bodyFont(size: 16, weight: .bold), lineHeight: 18)
                        .foregroundColor(.primary)
                        .padding(.top, 16)

                    Text(poem.title)
                        .fontWithLineHeight(font: theme.bodyFont(size: 16, weight: .semibold), lineHeight: 14.32)
                        .foregroundColor(theme.accent(for: colorScheme))
                        .padding(.bottom, 16)
                    ZStack(alignment: .leading) {
                        HStack {
                            RoundedRectangle(cornerRadius: 1)
                                .foregroundColor(theme.accent(for: colorScheme))
                                .frame(width: 2, alignment: .leading)
                                .padding(.top, 2)

                            Spacer()
                        }
                        .frame(alignment: .leading)

                        VStack(alignment: .leading) {
                            ForEach(0..<poem.lines.count, id: \.self) { index in
                                PoemView(
                                    author: poem.author,
                                    title: poem.title,
                                    index: index,
                                    poemLines: poem.lines,
                                    isSpoken: reader.currentLine == index
                                )
                                .id(index)

                            }
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding(16)

            }
            // Keep the line being read in view.
            .onChange(of: reader.currentLine) { _, line in
                guard let line else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    proxy.scrollTo(line, anchor: .center)
                }
            }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if reader.state == .idle {
                            AnalyticsEvents.poemListenStarted(title: poem.title, author: poem.author)
                        }
                        reader.toggle(poem.lines)
                    } label: {
                        Image(systemName: reader.state == .speaking ? "pause.circle" : "play.circle")
                    }
                    .accessibilityLabel(reader.state == .speaking ? "Pause reading" : "Read aloud")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.toggleFavorite(poem)
                        HapticFeedbackGenerator.shared.simpleHapticSuccess()
                    } label: {
                        Image(systemName: store.isFavorited(poem) ? "star.fill" : "star")
                    }
                }
                ToolbarItem {
                    Button {
                        Links.sharePoem(poem: poem.lines, title: poem.title, author: poem.author)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem {
                    Button {
                        showWebView.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        .onAppear {
            // onAppear also fires when returning from another tab; count the
            // visit once.
            guard !hasLoggedView else { return }
            hasLoggedView = true
            store.markViewed(poem)
            AnalyticsEvents.poemViewed(title: poem.title, author: poem.author, source: source)
            openedAt = Date()
            ReviewPrompter().recordPoemOpened()
        }
        .onDisappear {
            reader.stop()
        }
        .onChange(of: isPresented) { _, presented in
            // Unlike onDisappear (which also fires on a tab switch or when
            // something is pushed on top), this flips only on a real "back".
            guard !presented else { return }
            NotificationCenter.default.post(name: .poemDidClose, object: nil)
            // Ask only as someone leaves a poem they loved — never mid-read.
            let prompter = ReviewPrompter()
            guard prompter.shouldPrompt(
                poemIsFavorited: store.isFavorited(poem),
                secondsOnPoem: Date().timeIntervalSince(openedAt),
                favoritesCount: store.favorites.count
            ) else { return }
            prompter.markPrompted()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                requestReview()
            }
        }
        .sheet(isPresented: $showWebView) {
            if let urlString = Links.authorLinksDictionary[poem.author],
                let url = URL(string: urlString) {
                SafariView(url: url)
            } else {
                Text("No link available")
                    .font(.headline)
                    .padding()
            }
        }
    }
}
