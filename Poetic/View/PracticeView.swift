//
//  ContentView.swift
//  PoeticHomeViewPractice
//
//  Created by Dean Thompson on 2022/07/09.
//

import SwiftUI


struct PracticeView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationView {

                ZStack(alignment: .leading) {
                    
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                    
                    VStack(alignment: .leading) {
                        Text("Poetic")
                            .font(.system(size: 48, weight: .bold, design: .serif))
                            .lineSpacing(48)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                        
                        Text("Discover Classic Poetry!")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .lineSpacing(24)
                            .foregroundColor(colorScheme == .light ? Color(0x8030BF) : Color(0xDAAFFC))
                            .padding(.horizontal, 8)
                        
                        Text("Recommended")
                            .foregroundColor(.primary)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.randomPoems, id: \.self) { poem in
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        Text(poem.author)
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .lineSpacing(24)
                                            .padding(.top, 8)
                                            .foregroundColor(.primary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            ForEach(0..<6, id: \.self) { index in
                                                HStack {
                                                    Text(poem.lines[index])
                                                        .lineLimit(1)
                                                        .foregroundColor(.primary)
                                                        .font(.system(size: 16, weight: .medium, design: .default))
                                                    Spacer()
                                                }
                                                
                                            }
                                        }
                                        
                                        Text(poem.title)
                                            .foregroundColor(colorScheme == .light ? Color(0x8030BF) : Color(0xDAAFFC))
                                            .lineSpacing(24)
                                            .padding(.bottom, 8)
                                    }
                                    .padding(.horizontal, 8)
                                    .frame(width: 240, height: 224)
                                    .background(colorScheme == .light ? .white : .black)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        Text("Recent")
                            .foregroundColor(.primary)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                        ScrollView(.vertical, showsIndicators: false) {
                        ForEach(0...10, id: \.self) { index in
                            
                            NavigationLink {
                                Text("Hello!")
                            } label: {
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text("Algeron Charles Swinebourne")
                                                .font(.system(size: 16, weight: .bold, design: .default))
                                                .lineSpacing(24)
                                                .foregroundColor(.primary)
                                            
                                            Text("The Eve of Revolution")
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .lineSpacing(24)
                                                .foregroundColor(colorScheme == .light ? Color(0x8030BF) : Color(0xDAAFFC))
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.primary)
                                            .padding(8)
                                    }
                                }
                                .background(colorScheme == .light ? .white : .black)
                                .cornerRadius(8)
                            }
                            
                        }
                        Spacer()
                    }
                    }
                    .padding(.top, 48)
                    .padding(8)
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.loadRandomPoems(searchTerm: "5")
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
