//
//  AuthorView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import SwiftUI

struct AuthorView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    let author: String
    
    var body: some View {
        
        VStack {
//            GeometryReader { geo in
                   
                        switch viewModel.state {
                            
                        case .idle:
                            ZStack {
                                Image("background")
                                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                                    .ignoresSafeArea()
                                
                                
                                VStack(alignment: .center) {
                                    ProgressView("Idle")
                                }
                                .frame(maxWidth: . infinity)
                            }
                            
                            
                        case .loading:
                            ZStack {
                                Image("background")
                                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                                    .ignoresSafeArea()
                                
                                
                                VStack(alignment: .center) {
                                    ProgressView("loading")
                                }
                                .frame(maxWidth: . infinity)
                            }
                            
                            
                        case .failed:
                            ZStack {
                                Image("background")
                                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                                    .ignoresSafeArea()
                                
                                
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
                            }
                            
                            
                        case .loaded:
                            List(0..<viewModel.authorPoems.count, id: \.self) { index in
                                NavigationLink {
                                    DetailView(viewModel: viewModel,
                                               title: viewModel.authorPoems[index].title,
                                               author: viewModel.authorPoems[index].author,
                                               poemLines: viewModel.authorPoems[index].lines,
                                               linecount: viewModel.authorPoems[index].linecount)
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(index + 1)")
                                                .font(.system(.caption2, design: .serif))
                                                .frame(width: 20, height: 10)
                                                .padding(.trailing, 5)
                                            Text(viewModel.authorPoems[index].title)
                                                .multilineTextAlignment(.leading)
                                                .font(.system(.headline, design: .serif))
                                            Spacer()
//                                            Image(systemName: "chevron.right")
                                        }
//                                        .padding(.horizontal, 30)
//                                        .padding(.top, 4)
//                                            LineBreak()
//                                                .stroke(.black, style: StrokeStyle(lineWidth: 0.5))
//                                                .frame(width: geo.size.width / 1.4)
//                                                .padding(.leading, 50)
                                        
                                        
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                            .background(
                                Image("background")
                                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                                    .ignoresSafeArea()
                                
                            )
                            .onAppear {
                                // Set the default to clear
                                UITableView.appearance().backgroundColor = .clear
                            }
                        }
                    
//            }
            
        }
        
//        .padding(.top)
        .onAppear {
            viewModel.loadAuthorPoem(searchTerm: author.replacingOccurrences(of: " ", with: "%20"))
            print(viewModel.searchTerm)
        }
        
    }
    
}

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView(viewModel: SearchViewModel(), author: "Anne Bronte")
    }
}
