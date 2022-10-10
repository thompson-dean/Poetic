//
//  NewHomeView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/07/09.
//

import SwiftUI

struct NewHomeView: View {
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    PullToRefresh(viewModel: viewModel, coordinateSpaceName: "jazz") {
                        viewModel.loadRandomPoems(searchTerm: "5")
                    }
                    NewHomeContent(viewModel: viewModel, pcViewModel: pcViewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            pcViewModel.removeNotificationsOlderThan(days: 14)
            pcViewModel.fetchViewedPoems()
        }
    }
}

struct NewHomeContent: View {
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    let fonts = Fonts()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Poetic.")
                .fontWithLineHeight(font: fonts.newYorkFont, lineHeight: 48)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            Text("Discover Classic Poetry!")
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 16)
                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                .padding(.horizontal, 16)
            
            Text("Recommended")
                .foregroundColor(.primary)
                .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.randomPoems, id: \.self) { poem in
                        
                        switch viewModel.randomPoemState {
                        case .idle:
                            PoemCard(poem: poem)
                                .redacted(reason: .placeholder)
                                .onAppear {
                                    viewModel.loadRandomPoems(searchTerm: "5")
                                }
                        case .loading:
                            PoemCard(poem: poem)
                                .redacted(reason: .placeholder)
                        case .failed:
                            FailedPoemCard()
                        case .loaded:
                            NavigationLink {
                                NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: poem)
                            } label: {
                                PoemCard(poem: poem)
                            }
                            .disabled(false)
                        }
                    }
                    .padding(.leading, 8)
                    .buttonStyle(FlatLinkStyle())
                }
            }
            
            Text("Recent")
                .foregroundColor(.primary)
                    .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            
            if pcViewModel.viewedPoems.isEmpty {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("No Recents.")
                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                .foregroundColor(.primary)
                            
                            Text("Read some poems!")
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
                ForEach(pcViewModel.viewedPoems, id: \.self) { poem in
                    NavigationLink {
                        let sentPoem = Poem(title: poem.title ?? "", author: poem.author ?? "", lines: poem.lines ?? [], linecount: poem.title ?? "")
                        NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                    } label: {
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    Text(poem.author ?? "")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                        .foregroundColor(.primary)
                                    
                                    Text(poem.title ?? "")
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
            .padding(.top, 24)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        NewHomeView(viewModel: PoemViewModel(), pcViewModel: PersistenceController()).preferredColorScheme(.dark)
        
    }
}
