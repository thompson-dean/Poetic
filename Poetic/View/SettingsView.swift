//
//  SettingsView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let links = Links()
    @StateObject var notificationManager = NotificationManager()
    @ObservedObject var viewModel: SearchViewModel
    
    @State private var showLoading: Bool = false
    @State private var lightOrDark = false
 
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Form {
                    Section(header: Text("Appearance")) {
                        
                        Toggle("Adaptive background", isOn: $viewModel.systemThemeEnabled)
                            .onChange(of: viewModel.systemThemeEnabled) { _ in
                                SystemThemeManager.shared.handleTheme(darkMode: viewModel.darkModeEnabled, system: viewModel.systemThemeEnabled)
                            }
                        
                        if !viewModel.systemThemeEnabled {
                            Picker("", selection: $viewModel.darkModeEnabled) {
                                Text("Light").tag(false)
                                Text("Dark").tag(true)
                                
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: viewModel.darkModeEnabled) { _ in
                                SystemThemeManager.shared.handleTheme(darkMode: viewModel.darkModeEnabled, system: viewModel.systemThemeEnabled)
                            }
                        }
                        
                        
                    }
                    
                    Section(header: Text("Notifications")) {
                        Toggle("Notifications On", isOn: $notificationManager.notificationOn)
                            .onChange(of: notificationManager.notificationOn) { _ in
                                if notificationManager.notificationOn {
                                    notificationManager.addNotification()
                                    print("did it")
                                }
                            }
                    }
                    
                    Section(header: Text("Resources")) {
                        NavigationLink {
                            if let url = URL(string: links.poetryDBURLSTring) {
                                WebView(url: url, showLoading: $showLoading)
                                    .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                            } else {
                                
                            }
                        } label: {
                            Text("PoetryDB's fantastic poetry API")
                        }
                        NavigationLink {
                            if let url = URL(string: links.PoeticURLString) {
                                WebView(url: url, showLoading: $showLoading)
                                    .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                            } else {
                                
                            }
                        } label: {
                            Text("Poetic open source repository")
                        }
                    }
                    
                    
                    
                    Section {
                        
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
                                    Image(systemName: "hand.thumbsup")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .padding(.trailing)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Leave a rating")
                                        
                                        Text("Support this app, support poetry!")
                                            .font(.caption)
                                    }
                                    Spacer()
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        Button {
                            links.shareApp()
                        } label: {
                            ZStack {
                                NavigationLink(destination: EmptyView()) {
                                    
                                }
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .padding(.trailing)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Share")
                                        
                                        Text("Send to your friend's who love poetry.")
                                            .font(.caption)
                                    }
                                    Spacer()
                                }
                                .foregroundColor(.primary)
                            }
                            
                        }
                        
                        NavigationLink {
                            if let url = URL(string: links.twitterPoeticURLString) {
                                WebView(url: url, showLoading: $showLoading)
                                    .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                            } else {
                                
                            }
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(.trailing)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Send feedback")
                                    
                                    Text("Want new features? Found a bug?")
                                        .font(.caption)
                                }
                            }
                        }
                        NavigationLink {
                            DevView()
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(.trailing)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("About the app")
                                        
                                    Text("App and developer information")
                                        .font(.caption)
                                }
                            }
                        }
                        
                    }
                    
                    Section {
                        NavigationLink {
                            if let url = URL(string: links.twitterURLString) {
                                WebView(url: url, showLoading: $showLoading)
                                    .overlay(showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView())
                            } else {
                                
                            }
                        } label: {
                            HStack {
                                Image("poeticPic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Poetic version 1.2")
                                    HStack(spacing: 3) {
                                        Text("Made with love by")
                                        
                                        Text("@DeanWThompson")
                                            .foregroundColor(.blue)
                                        
                                    }
                                    .font(.caption)
                                    
                                    
                                }
                                
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
                .background(
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                )
                .onAppear {
                    // Set the default to clear
                    UITableView.appearance().backgroundColor = .clear
                    
                }
        
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
    
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SearchViewModel())
            .preferredColorScheme(.light)
    }
}

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
