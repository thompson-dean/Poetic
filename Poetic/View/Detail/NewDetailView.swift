//
//  PracticePoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/08/27.
//

import SwiftUI

struct NewDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    let fonts = Fonts()
    let links = Links()
    let poem: Poem
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    
//                    Text("Poetic.")
//                        .fontWithLineHeight(font: fonts.smallNewYorkFont, lineHeight: 24)
//                        .foregroundColor(.primary)
//
//                    Text("Discover Classic Poetry!")
//                        .fontWithLineHeight(font: .systemFont(ofSize: 8, weight: .medium), lineHeight: 8)
//                        .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                    
                    Text(poem.author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 18)
//                        .foregroundColor(.primary)
                        .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                        .padding(.top, 16)
                    
                    Text(poem.title)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 14.32)
                        .foregroundColor(.primary)
//                        .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                        .padding(.bottom, 16)
                    ZStack(alignment: .leading) {
                        HStack {
                            Rectangle()
                                .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                                .frame(width: 2, alignment: .leading)
                                .padding(.leading, 6)
                                .padding(.top, 4)
                                
                            Spacer()
                        }
                        .frame(alignment: .leading)
                        
                        
                        VStack(alignment: .leading) {
                            ForEach(0..<poem.lines.count, id: \.self) { index in
                                
                                    HStack {
                                        if (index + 1) % 5 == 0 {
                                            Text("\(index + 1)")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 8, weight: .light), lineHeight: 8)
                                                
                                                .background(
                                                    Image(colorScheme == .light ? "background" : "background-dark")
                                                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                                                )
                                                .padding(.vertical, 4)
                                                .frame(width: 24, height: 8, alignment: .bottomLeading)
                                                
                        
                                                
                                        } else {
                                            Text("")
                                                .foregroundColor(.clear)
                                                .frame(width: 24, alignment: .bottomLeading)
                                                
                                        }
                                        Text(poem.lines[index])
                                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
                                    }
                            }
                        }
                        
                    }
                    
                    
                }
                .padding(8)
                
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
}

struct PracticePoemView_Previews: PreviewProvider {
    static var previews: some View {
        NewDetailView(viewModel: PoemViewModel(), pcViewModel: PersistenceController(), poem: Poem(
            title: "Sonnet 1: From fairest creatures we desire increase",
            author: "William Shakespeare",
            lines: [
                "From fairest creatures we desire increase, ",
                "That thereby beauty's rose might never die, ",
                "But as the riper should by time decease, ",
                "His tender heir might bear his memory: ",
                "But thou contracted to thine own bright eyes,",
                "Feed'st thy light's flame with self-substantial fuel,",
                "Making a famine where abundance lies,",
                "Thy self thy foe, to thy sweet self too cruel:",
                "Thou that art now the world's fresh ornament,",
                "And only herald to the gaudy spring,",
                "Within thine own bud buriest thy content,",
                "And tender churl mak'st waste in niggarding:",
                "Pity the world, or else this glutton be,",
                "To eat the world's due, by the grave and thee."
            ],
            linecount: "14"))
    }
}
