//
//  PracticePoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/08/27.
//

import SwiftUI

struct NewDetailView: View {
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    let links = Links()
    let poem: Poem
    
    var body: some View {
        VStack {
            Text(poem.title)
            Text(poem.author)
            ForEach(poem.lines, id: \.self) { line in
                Text(line)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {}
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let entity = pcViewModel.favoritedPoems.first(where: { $0.title == poem.title}) {
                        pcViewModel.deleteFavoritedPoemFromTappingStar(entity: entity)
                    } else {
                        pcViewModel.addFavoritePoem(id: UUID(), title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                    }
                    
                } label: {
                    if pcViewModel.favoritedPoems.contains(where: { $0.title == poem.title })  {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            }
            ToolbarItem {
                Button {
                    links.sharePoem(poem: poem.lines, title: poem.title, author: poem.author)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

struct PracticePoemView_Previews: PreviewProvider {
    static var previews: some View {
        NewDetailView(viewModel: PoemViewModel(), pcViewModel: PersistenceController(), poem: Poem(title: "Sonnet", author: "William Shakespeare", lines: ["We", "are", "hungry"], linecount: "15"))
    }
}
