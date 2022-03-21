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
                VStack(alignment: .center, spacing: 10) {
                    HStack {
                        Spacer()
                        Image("Dean-KeyStone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(12)
                            .padding()
                        Spacer()
                    }
                    Text("This app is made for those who want to read poetry on the go. During university, I was able to read so many poems, but now that I am working full-time, I am having trouble finding the time to read poetry. This is way I built this app. 1. as a way to read more poetry, but also 2. as a way to give back to the art that gave me so much love when I was younger.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
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
                        Text("Leave a review")
                        .foregroundColor(.primary)
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
            // Set the default to clear
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
