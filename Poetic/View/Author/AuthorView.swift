//
//  AuthorView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/13.
//

import SwiftUI

struct AuthorView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    @State var count = 0
    let author: String

    var body: some View {

            VStack {
                switch viewModel.authorPoemState {

                case .idle:
                    ZStack {
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()

                        VStack(alignment: .center) {
                            ProgressView()
                        }
                        .frame(maxWidth: . infinity)
                    }

                case .loading:
                    ZStack {
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()

                        VStack(alignment: .center) {
                            ProgressView("loading")
                        }
                        .frame(maxWidth: . infinity)
                    }

                case .failed:
                    ZStack {
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()

                        VStack(alignment: .center) {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .padding()

                            Text("Connection error: Connect to the internet and try again")
                                .font(.system(.body, design: .serif))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Spacer()

                        }
                        .frame(maxWidth: . infinity)
                    }

                case .loaded:
                    ScrollView {
                        ForEach(0..<viewModel.authorPoems.count, id: \.self) { index in
                            NavigationLink {
                                NewDetailView(
                                    viewModel: viewModel,
                                    pcViewModel: pcViewModel,
                                    poem: viewModel.authorPoems[index]
                                )
                            } label: {
                                AuthorPoemCell(poem: viewModel.authorPoems[index], indexString: String(index + 1))
                            }
                        }
                    }
                    .background(
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea()

                    )
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
            .navigationTitle(author)
            .navigationBarTitleDisplayMode(.inline)

            .onAppear {
                viewModel.loadAuthorPoem(searchTerm: author.replacingOccurrences(of: " ", with: "%20"))
            }

    }

}
