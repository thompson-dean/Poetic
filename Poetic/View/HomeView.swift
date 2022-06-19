//
//  HomeView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let links = Links()
    
    @State private var isShowingPoem: Bool = false
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    
    @State var count = 0
    
    var body: some View {
        
        NavigationView {
            
            
            ZStack {
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea(.all)
                GeometryReader { geo in
                    
                        
                        VStack(alignment: .center, spacing: 10) {
                            
                            Text("Poetic.")
                                .font(.system(.largeTitle, design: .serif))
                                .bold()
                                .padding(.top, 10)
                                
      
                            Text("Discover Classic Poetry!")
                                .font(.system(.title, design: .serif))
                                .padding(.top, 10)
                               
                            
                            Text("Recommended")
                                .font(.system(.title2, design: .serif))
                                .padding(.top, 10)
                                
                            
                            switch viewModel.state {
                            case .idle:
                                VStack(alignment: .center) {
                                    ProgressView()
                                }
                                .frame(maxWidth: . infinity)
                                .padding()
                            case .loading:
                                VStack(alignment: .center) {
                                    ProgressView("loading")
                                }
                                .frame(maxWidth: . infinity)
                                .padding()
                            case .failed:
                                VStack() {
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                        .padding(.top, 5)
                                    
                                    Text("Please connect to the internet")
                                        .font(.system(.body, design: .serif))
                                        .padding(.top, 3)
                                }
                                .frame(maxWidth: . infinity)
                                .padding()
                                
                            case .loaded:
                                RecommendedPoems(viewModel: viewModel, pcViewModel: pcViewModel)
                                    .padding(.leading, 10)
                            }
                            Text("Recently Viewed Poems")
                                .font(.system(.title2, design: .serif))
                                .padding(.top, 15)
                            
                            if viewModel.viewedPoems.count == 0 {
                                    
                                    VStack {
                                        Text("No results. Start Exploring!")
                                            .font(.system(.body, design: .serif))
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                                    .background(colorScheme == .light ? Color.white : Color("homeScreenDark"))
                                    .cornerRadius(15)
                                    .padding(.horizontal, 10)
                                
                            } else {
                                List(viewModel.viewedPoems, id: \.self) { poem in
                                    NavigationLink {
                                        DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text(poem.title)
                                                .font(.system(.headline, design: .serif))
                                                .multilineTextAlignment(.leading)
                                            Text(poem.author)
                                                .font(.system(.subheadline, design: .serif))
                                        }
                                    }
                                }
                            }
                            
                            

                                                        
                        }
                        
                        
                    
                
            }
            .navigationBarHidden(true)
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
        }
    }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}

//ButtonStyle for Navigation Link. Stops it from going to .opacity(0.5)
struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct RecommendedPoems: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SearchViewModel
    @StateObject var pcViewModel: PersistenceController
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(viewModel.randomPoems, id: \.id) { randomPoem in
                    
                    NavigationLink {
                        DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: randomPoem.title, author: randomPoem.author, lines: randomPoem.lines, linecount: randomPoem.linecount)
                    } label: {
                        VStack(alignment: .center) {
                            Text(randomPoem.title)
                                .font(.system(.body, design: .serif))
                                .fontWeight(.semibold)
                                .padding(.vertical, 9)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                            Text(randomPoem.author)
                                .font(.system(.headline, design: .serif))
                                .italic()
                                .padding(.bottom, 10)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                            Divider()
                            
                            VStack(alignment: .leading) {
                                ForEach(0..<4, id: \.self) { index in
                                    HStack {
                                        Text(randomPoem.lines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                                            .font(.system(.caption, design: .serif))
                                            .multilineTextAlignment(.leading)
                                            .padding(.bottom, 5)
                                        Spacer()
                                    }
                                    
                                }
                                
                                Text("Read More...")
                                    .foregroundColor(.blue)
                                    .font(.system(.caption, design: .serif))
                                    .padding(.bottom, 10)
                                 
                            }
                            .padding(.horizontal, 15)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.66)
                        .frame(minHeight: 270)
                        .background(colorScheme == .light ? Color.white : Color("homeScreenDark"))
                        .cornerRadius(15)
                        .padding(.horizontal, 10)
                        
                        
                    }
                    .buttonStyle(FlatLinkStyle())
                }
            }
        }
    }
}



