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
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State var refresh = Refresh(started: false, released: false)
    @State var count = 0
    
    var body: some View {
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
                    GeometryReader { reader -> AnyView in
                        { () -> AnyView in
                            DispatchQueue.main.async {
                                if refresh.startOffset == 0 {
                                    refresh.startOffset = reader.frame(in: .global).minY
                                }
                                
                                refresh.offset = reader.frame(in: .global).minY
                                
                                if refresh.offset - refresh.startOffset > 80 && !refresh.started {
                                    refresh.started = true
                                    viewModel.mediumImpactHaptic()
                                }
                                
                                if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
                                    
                                    withAnimation(Animation.linear) {
                                        refresh.released = true
                                        
                                    }
                                    viewModel.simpleHapticSuccess()
                                    viewModel.loadRandomPoems(searchTerm: "1")
                                    refresh.started = false
                                    refresh.released = false
                                    
                                }
                            }
                            return AnyView(Color.black)
                        }()
                    }
                    .frame(width: 0, height: 0)
                    
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.gray)
                            .rotationEffect(.init(degrees: refresh.started ? 180 : 0))
                            .offset(y: refresh.released ? 40 : -30)
                            .animation(Animation.easeIn, value: refresh.offset)
                        VStack(alignment: .center) {
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
                    }
                case .loaded:
                    
                    
                    VStack {
                        
                        Text(viewModel.randomPoems[0].title)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.semibold)
                            .padding(.vertical, 9)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.randomPoems[0].author)
                            .font(.system(.title3, design: .serif))
                            .padding(.bottom, 10)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                        
                        Divider()
                            .frame(width: geo.size.width / 2)
                            .padding(10)
                        
                        VStack(alignment: .leading) {
                            ForEach(0..<viewModel.randomPoems[0].lines.count, id: \.self) { index in
                                HStack {
                                    if viewModel.randomPoems[0].lines.count < 9 {
                                        Text("\(index + 1)")
                                            .font(.system(.caption2, design: .serif))
                                            .frame(width: 20, height: 10)
                                            .padding(.trailing, 5)
                                        
                                    } else {
                                        Text((index + 1) % 5 == 0 ? "\(index + 1)" : "")
                                            .font(.system(.caption2, design: .serif))
                                            .frame(width: 30, height: 10)
                                            .padding(.trailing, 5)
                                        
                                    }
                                    
                                    PoemView(viewModel: viewModel, pcViewModel: pcViewModel, author: viewModel.randomPoems[0].author, title: viewModel.randomPoems[0].title, index: index, poemLines: viewModel.randomPoems[0].lines)
                                    
                                }
                                .padding(.vertical, 1)
                            }
                        }
                        .padding(5)
                        .padding(.horizontal, 15)
                    }
                    .frame(width: geo.size.width)
                }
            }
            .background(
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
            )
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                UIApplication.shared.applicationIconBadgeNumber = 0
                if count == 0 {
                    viewModel.loadRandomPoems(searchTerm: "1")
                    count += 1
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

//Model used for "swipe to refresh"
struct Refresh {
    var startOffset: CGFloat = 0
    var offset: CGFloat = 0
    var started: Bool
    var released: Bool
}


//GeometryReader { reader -> AnyView in
//    { () -> AnyView in
//        DispatchQueue.main.async {
//            if refresh.startOffset == 0 {
//                refresh.startOffset = reader.frame(in: .global).minY
//            }
//            
//            refresh.offset = reader.frame(in: .global).minY
//            
//            if refresh.offset - refresh.startOffset > 80 && !refresh.started {
//                refresh.started = true
//                viewModel.mediumImpactHaptic()
//            }
//            
//            if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
//                
//                withAnimation(Animation.linear) {
//                    refresh.released = true
//                    
//                }
//                viewModel.simpleHapticSuccess()
//                viewModel.loadRandomPoems(searchTerm: authors.authors[Int.random(in: 0..<authors.authors.count)].replacingOccurrences(of: " ", with: "%20"))
//                refresh.started = false
//                refresh.released = false
//                
//            }
//        }
//        return AnyView(Color.black)
//    }()
//}
//.frame(width: 0, height: 0)
