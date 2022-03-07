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
        Form {
            Section(header: Text("title")) {
                Text(title)
            }
            Section(header: Text("Author")) {
                Text(author)
            }
            Section(header: Text("Poem")) {
                ForEach(0..<poemLines.count) { index in
                    
                    HStack {
                        Text("\(index + 1)")
                            .font(.caption2)
                            .frame(width: 15, height: 10)
                            .padding(.trailing)
                        
                        
                        Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.subheadline)
                            
                    }
                    
                }
            }
            Section(header: Text("Line Count")) {
                Text(linecount)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(title: "JazzBox", author: "Deano", poemLines: ["Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong", "Bong hello what are you you doing bro no way lad", "Bong" ], linecount: "14")
    }
}
