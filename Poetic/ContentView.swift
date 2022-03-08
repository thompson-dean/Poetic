//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct LineBreak: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        
        
        
        return path
    }
}

struct ContentView: View {
    @StateObject var viewModel = SearchViewModel()
    @State private var authorSearch = true
    var body: some View {
        NavigationView {
            
            
            ZStack {
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    
                    Picker("", selection: $authorSearch) {
                        Text("Author").tag(true)
                        Text("Title").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    .padding()
                    
                    SearchBar(searchTerm: $viewModel.searchTerm)
                            .padding(.horizontal, 8)
                  
                    if viewModel.searchTerm.isEmpty {
                        VStack(alignment: .center) {
                            
                            Image(systemName: "eyeglasses")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                                .frame(width: 250, height: 200)
                            
                            Text("Start searching for poems!")
                                .font(.system(.title, design: .serif))
                            
                            
                        }
                        .frame(maxWidth: . infinity)
                    } else {
                        
                        GeometryReader { geo in
                            ScrollView {
                            ForEach(viewModel.poems) { poem in
                                NavigationLink {
                                    DetailView(title: poem.title, author: poem.author, poemLines: poem.lines, linecount: poem.linecount)
                                } label: {
                                    VStack(alignment: .center) {
                                        if authorSearch {
                                            HStack {
                                                Text(poem.author)
                                                    .font(.system(.headline, design: .serif))
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Text(poem.title)
                                                    .font(.system(.subheadline, design: .serif))
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                            }
                                            LineBreak()
                                                .stroke(.black, style: StrokeStyle(lineWidth: 0.5))
                                                .frame(width: geo.size.width / 2)
                                        } else {
                                            HStack {
                                                Text(poem.title)
                                                    .font(.system(.headline, design: .serif))
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                            }
                                            HStack {
                                                Text(poem.author)
                                                    .font(.system(.subheadline, design: .serif))
                                                Spacer()
                                            }
                                            LineBreak()
                                                .stroke(.black, style: StrokeStyle(lineWidth: 0.5))
                                                .frame(width: geo.size.width / 2)
                                        }
                                    }
                                    .frame(width: geo.size.width)
                                    .padding(.horizontal, 7)
                                    
                                    
                                    
                                    
                                    
                                }
                            }
                            }
                        }
                        .padding()
                        
                        
                        
                    }
                    
                    
                    Spacer()
                    
                }
                .onChange(of: viewModel.searchTerm) { _ in
                    if authorSearch {
                        viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .author)
                    } else {
                        viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .title)
                    }
                }
                .navigationTitle("Poetic")
                .foregroundColor(.black)
            }
            
        }
    }
}

struct SearchBar: UIViewRepresentable {
    typealias UIViewType = UISearchBar
    
    @Binding var searchTerm: String
    
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        return searchBar
        
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
    }
    
    func makeCoordinator() -> SearchBarCoordinator {
       
        return SearchBarCoordinator(searchTerm: $searchTerm)
    }
    
    class SearchBarCoordinator: NSObject, UISearchBarDelegate {
        @Binding var searchTerm: String
        
        init(searchTerm: Binding<String>) {
            self._searchTerm = searchTerm
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchTerm = searchBar.text ?? ""
            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
        }

    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

