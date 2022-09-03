//
//  PracticePoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/08/27.
//

import SwiftUI

struct PracticePoemView: View {
    
    let poem: Poem
    
    var body: some View {
        VStack {
            Text(poem.title)
            Text(poem.author)
            ForEach(poem.lines, id: \.self) { line in
                Text(line)
            }
        }
    }
}

struct PracticePoemView_Previews: PreviewProvider {
    static var previews: some View {
        PracticePoemView(poem: Poem(title: "Sonnet", author: "William Shakespeare", lines: ["We", "are", "hungry"], linecount: "15"))
    }
}
