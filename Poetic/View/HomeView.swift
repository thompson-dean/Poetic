//
//  HomeView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var example = Poem(title: "A Song of Autumn", author: "Adam Lindsay Gordon", lines: [
        "‘WHERE shall we go for our garlands glad",
        "At the falling of the year,",
        "When the burnt-up banks are yellow and sad,",
        "When the boughs are yellow and sere?",
        "Where are the old ones that once we had,",
        "And when are the new ones near?",
        "What shall we do for our garlands glad",
        "At the falling of the year?’",
        "‘Child! can I tell where the garlands go?",
        "Can I say where the lost leaves veer",
        "On the brown-burnt banks, when the wild winds blow,",
        "When they drift through the dead-wood drear?",
        "Girl! when the garlands of next year glow,",
        "You may gather again, my dear—",
        "But I go where the last year’s lost leaves go",
        "At the falling of the year.’"
    ], linecount: "16")
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 10) {
                    
                    Text("Hello, Dean")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.semibold)
                    
                    Text("Here is today's classic poem")
                        .font(.system(.body, design: .serif))
                    Text("for your perusal.")
                        .font(.system(.body, design: .serif))
                    
                    
                    GeometryReader { geo in
                        ScrollView {
                            NavigationLink {
                                DetailView(viewModel: viewModel, title: example.title, author: example.author, poemLines: example.lines, linecount: example.linecount)
                            } label: {
                                VStack {
                                    
                                    Text(example.title)
                                        .font(.system(.title3, design: .serif))
                                        .fontWeight(.semibold)
                                        .padding(.top, 17)
                                        .padding(.horizontal)
                                    
                                    Text(example.author)
                                        .font(.system(.body, design: .serif))
                                        .padding(.top, 1)
                                        .padding(.horizontal)
                                    
                                    LineBreak()
                                        .stroke(.black, style: StrokeStyle(lineWidth: 0.5))
                                        .frame(width: geo.size.width / 1.4)
                                        .padding(.horizontal, 20)
                                    
                                    VStack(alignment: .leading) {
                                        ForEach(0..<example.lines.count, id: \.self) { index in
                                            HStack {
                                                
                                                Text("\(index + 1)")
                                                    .font(.system(.caption2, design: .serif))
                                                    .frame(width: 22, height: 10)
                                                    .padding(.trailing, 5)
                                                
                                                
                                                Text(example.lines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                                                    .font(.system(.subheadline, design: .serif))
                                            }
                                        }
                                    }
                                    .padding(5)
                                }
                                .foregroundColor(.black)
                                .frame(width: geo.size.width)
                            }
                            .buttonStyle(FlatLinkStyle())
                        }
                        .background(
                            Color.black.opacity(0.1)
                        )
                        .cornerRadius(10)
                    }
                    .padding(10)
                    
                    
                    
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarHidden(true)
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: SearchViewModel())
    }
}

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
