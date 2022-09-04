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
                                        PracticePoemView(poem: poem)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 12) {
                                            
                                            Text(poem.author)
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                .padding(.top, 8)
                                                .foregroundColor(.primary)
                                            
                                            
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                ForEach(0..<3, id: \.self) { index in
                                                    HStack {
                                                        Text(poem.lines[index].trimmingCharacters(in: .whitespaces))
                                                            .fixedSize(horizontal: false, vertical: true)
                                                            .lineLimit(2)
                                                            .foregroundColor(.primary)
                                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
                                                        Spacer()
                                                    }
                                                }
                                                Text("...")
                                            }
                                            
                                            Spacer()
                                            HStack(alignment: .top) {
                                                Text(poem.title)
                                                    .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .lineLimit(3)
                                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
                                            }
                                            .frame(width: 264, height: 80, alignment: .leading)
                                            .padding(.bottom, 8)
                                        }
                                        .padding(.horizontal, 8)
                                        .frame(width: 280)
                                        .background(colorScheme == .light ? .white : .black)
                                        .cornerRadius(8)
                                    }
                                    .padding(.horizontal, 8)
                                    .buttonStyle(FlatLinkStyle())
                                    
                                }
                            }
                        }
                        
                        Text("Recent")
                            .foregroundColor(.primary)
                            .fontWithLineHeight(font: .systemFont(ofSize: 24, weight: .bold), lineHeight: 28.64)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        ForEach(0...50, id: \.self) { index in
                            
                            NavigationLink {
                                Text("Hello!")
                            } label: {
                                LazyVStack {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text("Algeron Charles Swinebourne")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            
                                            Text("The Eve of Revolution")
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
                    }
                    .background(.clear)
                    .padding(.top, 48)
                }
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .onAppear {
                    count += 1
                    if count == 0 {
                        viewModel.loadRandomPoems(searchTerm: "5")
                    }
                    
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            ContentView().preferredColorScheme($0)
        }
    }
}
