//
//  SettingsView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var lightOrDark = false
    @State private var fontAmount = 0.0
    @State private var exampleText = "The quick brown fox jumps over the lazy dog"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Form {
                    Section(header: Text("Appearance")) {
                        Picker("", selection: $lightOrDark) {
                            Text("Light").tag(false)
                            Text("Dark").tag(true)
                            
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        
                        
                        Text("The quick brown fox jumps over the lazy dog")
                            .font(.system(size: CGFloat(fontAmount), design: .serif))
                            .frame(maxWidth: .infinity)
                        
                            .padding()
                            .background(colorScheme == .light ? Color.black.opacity(0.8) : Color.white)
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .cornerRadius(5)
                        
                        
                        
                        Slider(value: $fontAmount, in: 12...26, step: 1)
                        Text("Drag to change font size")
                            .font(.caption)
                    }
                    
                    Section(header: Text("Resources")) {
                        NavigationLink {
                            
                        } label: {
                            Text("PoetryDB's fantastic poetry API")
                        }
                        NavigationLink {
                            
                        } label: {
                            Text("Poetic open source repository")
                        }
                    }
                    
                    Section {
                        HStack(spacing: 10) {
                            Image("poeticIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                            VStack(spacing: 5) {
                                Text("Poetic version 1.2")
                                HStack(spacing: 0) {
                                    Text("Made with love by ")
                                    Button {
                                        
                                    } label: {
                                        Text("@DeanWThompson")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .font(.caption)
                                
                                
                            }
                            
                        }
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(.trailing)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Leave a rating")
                                    .font(.headline)
                                Text("Support this app, support poetry!")
                                    .font(.caption)
                            }
                        }
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(.trailing)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Share")
                                        .font(.headline)
                                    Text("Send to your friend's who love poetry.")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Image(systemName: "envelope")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(.trailing)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Send feedback")
                                    .font(.headline)
                                Text("Want new features? Found a bug?")
                                    .font(.caption)
                            }
                        }
                        NavigationLink {
                            
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(.trailing)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("About the app")
                                        .font(.headline)
                                    Text("App and developer information")
                                        .font(.caption)
                                }
                            }
                        }
                        
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.light)
    }
}
