//
//  ContentView.swift
//  PoeticHomeViewPractice
//
//  Created by Dean Thompson on 2022/07/09.
//

import SwiftUI


struct PracticeView: View {
    
    @State var count = 0
    
    @ObservedObject var viewModel: SearchViewModel
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
        
        NavigationView {

                ZStack(alignment: .leading) {
                    
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
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
                            .padding(.top, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.randomPoems, id: \.self) { poem in
                                    
                                    NavigationLink {
                                        DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                                    } label: {
                                        PoemCard(poem: poem)
                                    }
                                    .padding(.leading, 8)
                                    .buttonStyle(FlatLinkStyle())
                                    
                                }
                            }
                        }
                        
                        Text("Recent")
                            .foregroundColor(.primary)
                            .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        ForEach(viewModel.viewedPoems, id: \.self) { poem in
                            
                            NavigationLink {
                                Text("Hello!")
                            } label: {
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(poem.author)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            
                                            Text(poem.title)
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
                        Spacer()
                            .padding(40)
                    }
                    .background(.clear)
                    .padding(.top, 48)
                }
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.loadRandomPoems(searchTerm: "5")
                }
        }
    }
}


//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForEach(ColorScheme.allCases, id: \.self) {
//            ContentView().preferredColorScheme($0)
//        }
//    }
//}
