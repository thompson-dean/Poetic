//
//  DevView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import SwiftUI

struct DevView: View {
    
    let links = Links()
    @State private var showLoading: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        Form {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Spacer()
                        Image("Dean-KeyStone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(75)
                            .padding(.vertical, 4)
                        Spacer()
                    }
                    Text("This app is made for those who want to read poetry on the go. When I was a university student, I would dedicate hours to reading poetry, but now, as I have gotten older, I have found myself reading less and less... That's why I built this app! So that I and others like me could read more poetry! I hope, with this app, I am able to give my love back to the art form that gave me so, so much. ")
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)
                        .font(.caption)
                }
            }
            
            Section(header: Text("Follow")) {
                NavigationLink {
                    if let url = URL(string: links.gitHubLink) {
                        WebView(url: url, showLoading: $showLoading)
                            .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                    } else {
                        
                    }
                } label: {
                    Text("GitHub")
                }
                NavigationLink {
                    if let url = URL(string: links.twitterURLString) {
                        WebView(url: url, showLoading: $showLoading)
                            .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                    } else {
                        
                    }
                } label: {
                    Text("Twitter @DeanWThompson")
                }
            }
            
            Section(header: Text("Support")) {
                Button {
                    if let url = URL(string: "itms-apps://apple.com/app/id1614416936") {
                                UIApplication.shared.open(url)
                            } else {
                                print("error with app store URL")
                            }
                } label: {
                        ZStack {
                            NavigationLink(destination: EmptyView()) {
                                
                            }
                            HStack {
                                Text("Leave a review")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                }
                NavigationLink {
                    if let url = URL(string: links.PoeticURLString) {
                        WebView(url: url, showLoading: $showLoading)
                            .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                    } else {
                        
                    }
                } label: {
                    Text("Star the repository")
                }
            }
            
            
        }.background(
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea()
            
        )
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            
        }
        .navigationTitle("About Poetic")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DevView_Previews: PreviewProvider {
    static var previews: some View {
        DevView()
            .preferredColorScheme(.dark)
            
    }
}
