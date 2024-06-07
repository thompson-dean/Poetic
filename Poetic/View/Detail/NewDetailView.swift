//
//  PracticePoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/08/27.
//

import SwiftUI

struct NewDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showWebView = false
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    let fonts = Fonts()
    let links = Links()
    let poem: Poem
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    
                    Text("Poetic.")
                        .fontWithLineHeight(font: fonts.smallNewYorkFont, lineHeight: 16)
                        .foregroundColor(.primary)
                    
                    Text("Discover Classic Poetry!")
                        .fontWithLineHeight(font: .systemFont(ofSize: 8, weight: .medium), lineHeight: 8)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    
                    Text(poem.author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 18)
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                    
                    Text(poem.title)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 14.32)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                        .padding(.bottom, 16)
                    ZStack(alignment: .leading) {
                        HStack {
                            RoundedRectangle(cornerRadius: 1)
                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                .frame(width: 2, alignment: .leading)
                                .padding(.top, 2)
                            
                            Spacer()
                        }
                        .frame(alignment: .leading)
                        
                        
                        VStack(alignment: .leading) {
                            ForEach(0..<poem.lines.count, id: \.self) { index in
                                PoemView(viewModel: viewModel, pcViewModel: pcViewModel, author: poem.author, title: poem.title, index: index, poemLines: poem.lines)
                                
                            }
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding(16)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {}
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let entity = pcViewModel.favoritedPoems.first(where: { $0.title == poem.title}) {
                            pcViewModel.deleteFavoritedPoemFromTappingStar(entity: entity)
                        } else {
                            pcViewModel.addFavoritePoem(id: UUID(), title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                        }
                        
                    } label: {
                        if pcViewModel.favoritedPoems.contains(where: { $0.title == poem.title })  {
                            Image(systemName: "star.fill")
                        } else {
                            Image(systemName: "star")
                        }
                    }
                }
                ToolbarItem {
                    Button {
                        links.sharePoem(poem: poem.lines, title: poem.title, author: poem.author)
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
            if (pcViewModel.viewedPoems.first(where: { $0.title == poem.title}) == nil) {
                pcViewModel.addViewedPoem(id: UUID(), title: poem.title, author: poem.author, lines: poem.lines)
            }
        }
        .sheet(isPresented: $showWebView) {
            if let urlString = links.authorLinksDictionary[poem.author], let url = URL(string: urlString) {
                SafariView(url: url)
            } else {
                Text("No link available")
                    .font(.headline)
                    .padding()
            }
        }
    }
}

struct PracticePoemView_Previews: PreviewProvider {
    static var previews: some View {
        NewDetailView(viewModel: PoemViewModel(apiService: APIService()), pcViewModel: PersistenceController(), poem: Poem.stub)
    }
}
