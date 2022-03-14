//
//  HomeView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State var refresh = Refresh(started: false, released: false)
    @State var count = 0
    
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                
                
                VStack(alignment: .center, spacing: 10) {
                    
                    Text("Hello, there.")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.semibold)
                    
                    Text("Here is a random poem")
                        .font(.system(.body, design: .serif))
                    Text("for your perusal.")
                        .font(.system(.body, design: .serif))
                    
                    
                    GeometryReader { geo in
                        ScrollView {
                            
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
                                VStack(alignment: .center) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.black)
                                        .frame(width: 150, height: 100)
                                        .padding()
                                    
                                    Text("Error: Search Again")
                                        .font(.system(.title, design: .serif))
                                }
                                .frame(maxWidth: . infinity)
                                .padding()
                            case .loaded:
                                NavigationLink {
                                    DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: viewModel.randomPoems[0].title, author: viewModel.randomPoems[0].author, lines: viewModel.randomPoems[0].lines, linecount: viewModel.randomPoems[0].linecount)
                                } label: {
                                    
                                    GeometryReader { reader -> AnyView in
                                        DispatchQueue.main.async {
                                            if refresh.startOffset == 0 {
                                                refresh.startOffset = reader.frame(in: .global).minY
                                            }
                                            
                                            refresh.offset = reader.frame(in: .global).minY
                                            
                                            if refresh.offset - refresh.startOffset > 80 && !refresh.started {
                                                refresh.started = true
                                            }
                                            
                                            if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
                                                
                                                withAnimation(Animation.linear) {
                                                    refresh.released = true
                                                }
                                                simpleSuccess()
                                                viewModel.loadRandomPoems(searchTerm: authors.authors[Int.random(in: 0..<authors.authors.count)].replacingOccurrences(of: " ", with: "%20"))
                                                refresh.started = false
                                                refresh.released = false
                                                
                                            }
                                        }
                                        return AnyView(Color.black)
                                    }
                                    .frame(width: 0, height: 0)
                                    
                                    ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                        
                                        
                                        Image(systemName: "arrow.down")
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundColor(.gray)
                                            .rotationEffect(.init(degrees: refresh.started ? 180 : 0))
                                            .offset(y: refresh.released ? 40 : -30)
                                            .animation(.easeIn)
                                        
                                        
                                        VStack {
                                            
                                            Text(viewModel.randomPoems[0].title.trimmingCharacters(in: .whitespacesAndNewlines))
                                                .font(.system(.title3, design: .serif))
                                                .fontWeight(.semibold)
                                                .padding(.top, 24)
                                                .padding(.horizontal)
                                            
                                            Text(viewModel.randomPoems[0].author.trimmingCharacters(in: .whitespacesAndNewlines))
                                                .font(.system(.body, design: .serif))
                                                .padding(.top, 1)
                                                .padding(.horizontal)
                                            
                                            Divider()
                                                .frame(width: geo.size.width / 2)
                                                .padding(10)
                                            
                                            VStack(alignment: .leading) {
                                                ForEach(0..<viewModel.randomPoems[0].lines.count, id: \.self) { index in
                                                    HStack {
                                                        
                                                        if viewModel.randomPoems[0].lines.count < 9 {
                                                            Text("\(index + 1)")
                                                                .font(.system(.caption2, design: .serif))
                                                                .frame(width: 22, height: 10)
                                                                .padding(.trailing, 5)
                                                            
                                                        } else {
                                                            Text((index + 1) % 5 == 0 ? "\(index + 1)" : "")
                                                                .font(.system(.caption2, design: .serif))
                                                                .frame(width: 22, height: 10)
                                                                .padding(.trailing, 5)
                                                        }
                                                        
                                                        
                                                        
                                                        
                                                        Text(viewModel.randomPoems[0].lines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                                                            .font(.system(.subheadline, design: .serif))
                                                    }
                                                    .padding(.trailing, 4)
                                                }
                                            }
                                            .padding(5)
                                        }
                                        
                                        .foregroundColor(.black)
                                        .frame(width: geo.size.width)
                                        
                                        
                                            
                                    }
                                    .offset(y: -10)
                                    
                                }
                                .buttonStyle(FlatLinkStyle())
                                
                            }
                            
                            
                        }
                        .background(
                            .white
                        )
                        .cornerRadius(10)
                    }
                    .padding(5)
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                
            }
            .navigationBarHidden(true)
            .onAppear {
                
                if count == 0 {
                    viewModel.loadRandomPoems(searchTerm: authors.authors[Int.random(in: 0..<authors.authors.count)].replacingOccurrences(of: " ", with: "%20"))
                    count += 1
                } else {
                    //nothing
                }
                
            }
            
            
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct Refresh {
    var startOffset: CGFloat = 0
    var offset: CGFloat = 0
    var started: Bool
    var released: Bool
}
