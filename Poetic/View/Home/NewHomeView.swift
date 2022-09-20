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
    
    let dataManager = DataManager()
    
    @Environment(\.colorScheme) var colorScheme
    
    var newYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 48, weight: .bold).fontDescriptor
        
        if let serif = descriptor.withDesign(.serif) {
            return UIFont(descriptor: serif, size: 0.0)
        }
        return UIFont(descriptor: descriptor, size: 0.0)
    }
    
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
    
    @Environment(\.colorScheme) var colorScheme
    
    var newYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 48, weight: .bold).fontDescriptor
        
        if let serif = descriptor.withDesign(.serif) {
            return UIFont(descriptor: serif, size: 0.0)
        }
        return UIFont(descriptor: descriptor, size: 0.0)
    }
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("Poetic.")
                    .fontWithLineHeight(font: newYorkFont, lineHeight: 48)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                
                Text("Discover Classic Poetry!")
                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 16)
                    .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
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
                                NavigationLink {
                                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                                } label: {
                                    
                                    PoemCard(poem: poem)
                                        .onAppear {
                                            viewModel.loadRandomPoems(searchTerm: "5")
                                        }
                                }
                                .disabled(true)
                            case .loading:
                                NavigationLink {
                                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                                } label: {
                                    PoemCard(poem: poem)
                                        .redacted(reason: .placeholder)
                                }
                                .disabled(true)
                            case .failed:
                                NavigationLink {
                                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                                } label: {
                                    FailedPoemCard()
                                }
                                .disabled(true)
                            case .loaded:
                                NavigationLink {
                                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
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
                ForEach(pcViewModel.viewedPoems, id: \.self) { poem in
                    NavigationLink {
                        Text("Hello!")
                    } label: {
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    Text(poem.author ?? "")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                        .foregroundColor(.primary)
                                    
                                    Text(poem.title ?? "")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                        .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
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
            .padding(.top, 48)
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        NewHomeView(viewModel: PoemViewModel(), pcViewModel: PersistenceController()).preferredColorScheme(.dark)
        
    }
}


public struct RefreshableScrollView<Content: View>: View {
    
    var content: Content
    var onRefresh: () -> Void

    public init(content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
        
        UITableView.appearance().showsVerticalScrollIndicator = false
    }

    public var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .background(.clear)
        }
        .listStyle(.plain)
        
        .refreshable {
            onRefresh()
        }
    }
}
