//
//  FavoritesView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    @State private var isEditing: Bool = false
    
    init(viewModel: PoemViewModel, pcViewModel: PersistenceController) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        self.viewModel = viewModel
        self.pcViewModel = pcViewModel
    }
    
    var body: some View {
        NavigationView {
            if pcViewModel.favoritedPoems.isEmpty {
                VStack {
                    VStack {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.primary)
                                .font(.title)
                                .padding(.vertical, 8)
                                .padding(.leading, 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                
                                Text("No favorited poems...")
                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                    .foregroundColor(.primary)
                                
                                Text("Star your favorite poems.")
                                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                    .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            Spacer()
                        }
                    
                    }
                    .background(colorScheme == .light ? .white : .black)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                    Spacer()
                }
                .background( 
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea(.all)
                )
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(.primary)
                .toolbar {
                    ToolbarItem {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                           
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
            } else {
                if #available(iOS 16.0, *) {
                    List {
                        ForEach(pcViewModel.favoritedPoems) { poem in
                            ZStack {
                                
                                NavigationLink {
                                    let sentPoem = Poem(title: poem.title ?? "", author: poem.author ?? "", lines: poem.lines ?? [], linecount: poem.linecount ?? "")
                                    NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                                } label: {
                                    EmptyView().opacity(0.0)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(poem.author ?? "")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            
                                            Text(poem.title ?? "")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                        }
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                }
                                .background(colorScheme == .light ? .white : .black)
                                .cornerRadius(8)
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete { indexSet in
                            pcViewModel.deleteFavoritedPoem(indexSet: indexSet)
                        }
                    }
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea(.all)
                    )
                    .navigationTitle("Favorites")
                    .navigationBarTitleDisplayMode(.inline)
                    .foregroundColor(.primary)
                    .onAppear {
                        pcViewModel.fetchFavoritedPoems()
                    }
                    .toolbar {
                        ToolbarItem {
                            EditButton()
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                pcViewModel.poemsFilter.toggle()
                                pcViewModel.fetchFavoritedPoems()
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                    }
                } else {
                    List {
                        ForEach(pcViewModel.favoritedPoems) { poem in
                            ZStack {
                                NavigationLink {
                                    let sentPoem = Poem(title: poem.title ?? "", author: poem.author ?? "", lines: poem.lines ?? [], linecount: poem.linecount ?? "")
                                    NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                                } label: {
                                    EmptyView()
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(poem.author ?? "")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                                .foregroundColor(.primary)
                                            
                                            Text(poem.title ?? "")
                                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.primary)
                                        
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                }
                                .background(colorScheme == .light ? .white : .black)
                                .cornerRadius(8)
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete { indexSet in
                            pcViewModel.deleteFavoritedPoem(indexSet: indexSet)
                        }
                    }
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .background(
                        Image(colorScheme == .light ? "background" : "background-dark")
                            .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                            .ignoresSafeArea(.all)
                    )
                    .navigationTitle("Favorites")
                    .navigationBarTitleDisplayMode(.inline)
                    .foregroundColor(.primary)
                    .onAppear {
                        pcViewModel.fetchFavoritedPoems()
                    }
                    .toolbar {
                        ToolbarItem {
                            EditButton()
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                pcViewModel.poemsFilter.toggle()
                                pcViewModel.fetchFavoritedPoems()
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                    }
                }
            }
        }
    }
}
