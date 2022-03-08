//
//  DetailView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct DetailView: View {
    
    let title: String
    let author: String
    let poemLines: [String]
    let linecount: String
    
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                VStack {
                    
                    Text(title)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .padding(.vertical, 9)
                        .padding(.horizontal)
                
                    Text(author)
                        .font(.system(.headline, design: .serif))
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        ForEach(0..<poemLines.count) { index in
                            HStack {
                                if poemLines.count < 9 {
                                    Text("\(index + 1)")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 20, height: 10)
                                        .padding(.trailing, 5)
                                } else {
                                    Text((index + 1) % 5 == 0 ? "\(index + 1)" : "")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 20, height: 10)
                                        .padding(.trailing, 5)
                                }
                                
                                Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.system(.subheadline, design: .serif))
                            }
                        }
                    }
                    .padding(5)
                }
                .frame(width: geo.size.width)
            }
            .background(
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
            )
        }
        
        
    }
        
    
}

struct DetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            DetailView(title: "Jazz Box", author: "Dean Thompson", poemLines: ["Bong hello what are you  no way lad", "Bong asdf f f asdfasdf",  "Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong asdfga asdfgasd", "Bong hello what are you  no way lad", "Bong asdf f f asdfasdf",  "Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong asdfga asdfgasd", "Bong hello what are you  no way lad", "Bong asdf f f asdfasdf",  "Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong asdfga asdfgasd", "Bong hello what are you  no way lad", "Bong asdf f f asdfasdf",  "Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong asdfga asdfgasd"  ], linecount: "14")
                .navigationBarBackButtonHidden(false)
            
        }
        
        
    }
}
