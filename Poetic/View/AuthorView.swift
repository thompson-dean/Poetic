//
//  AuthorView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import SwiftUI

struct AuthorView: View {
    @StateObject var viewModel = AuthorViewModel()
    
    let author: String
    
    var body: some View {
        
        VStack {
            GeometryReader { geo in
                    ScrollView {
                        switch viewModel.state {
                            
                        case .idle:
                            VStack(alignment: .center) {
                                ProgressView()
                            }
                            .frame(maxWidth: . infinity)
                            
                        case .loading:
                            VStack(alignment: .center) {
                                ProgressView()
                            }
                            .frame(maxWidth: . infinity)
                            
                        case .failed:
                            VStack(alignment: .center) {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                                    .frame(width: 250, height: 200)
                                
                                Text("Error: Search Again")
                                    .font(.system(.title, design: .serif))
                            }
                            .frame(maxWidth: . infinity)
                            
                        case .loaded:
                            ForEach(viewModel.authorPoems) { poem in
                                NavigationLink {
                                    
                                } label: {
                                    VStack(alignment: .center) {
                                        HStack {
                                            Text(poem.title)
                                                .font(.system(.headline, design: .serif))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding(.horizontal, 30)
                                        .padding(.top, 4)
                                        LineBreak()
                                            .stroke(.black, style: StrokeStyle(lineWidth: 0.5))
                                            .frame(width: geo.size.width / 1.4)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
            }
            
        }
        .onAppear {
            print("appeared")
            self.viewModel.loadAuthorPoem(searchTerm: author)
        }
        
        
        
    }
}

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView(viewModel: AuthorViewModel(), author: "Anne Bronte")
    }
}
