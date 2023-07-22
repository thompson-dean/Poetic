//
//  PoeticApp.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

@main
struct PoeticApp: App {
    
    @StateObject private var persistenceController = PersistenceController()
    @StateObject private var storeKitManager = StoreKitManager()
    
    var body: some Scene {
        WindowGroup {
            PracJazz()
//            ContentView(storeKitManager: storeKitManager)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct PracJazz: View {
    @State private var showSheet: Bool = false
    @State private var showSheet1: Bool = false
    @State private var showSheet2: Bool = false
    @State private var showSheet3: Bool = false
    let csvPoems: [CSVPoem]
    
    init() {
        let result = CSVManager.shared.parseCSV(fileName: "PoetryFoundationData", fileType: "csv")
        csvPoems = result
    }
    
    var body: some View {
        VStack {
            Button("Show Sheet") {
                showSheet.toggle()
            }
            .sheet(isPresented: $showSheet) {
                PracticeView(poem: csvPoems[100])
            }
            Button("Show Sheet") {
                showSheet1.toggle()
            }
            .sheet(isPresented: $showSheet1) {
                PracticeView(poem: csvPoems[50])
            }
            Button("Show Sheet") {
                showSheet2.toggle()
            }
            .sheet(isPresented: $showSheet2) {
                PracticeView(poem: csvPoems[1343])
            }
            Button("Show Sheet") {
                showSheet3.toggle()
            }
            .sheet(isPresented: $showSheet3) {
                PracticeView(poem: csvPoems[1234])
            }
        }
    }
}

struct PracticeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let fonts = Fonts()
    let links = Links()
    let poem: CSVPoem
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    
                    Text("Poetic.")
                        .fontWithLineHeight(font: fonts.smallNewYorkFont, lineHeight: 16)
                        .foregroundColor(.primary)
                    
                    Text("Discover Poetry!")
                        .fontWithLineHeight(font: .systemFont(ofSize: 8, weight: .medium), lineHeight: 8)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    
                    Text(poem.cleanedPoet)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 18)
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                    
                    Text(poem.cleanedTitle)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 14.32)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                        .padding(.bottom, 16)
                    ZStack(alignment: .leading) {
                        HStack {
                            RoundedRectangle(cornerRadius: 1)
                                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                                .frame(width: 2, alignment: .leading)
                                .padding(.top, 2)
                            
                            Spacer()
                        }
                        .frame(alignment: .leading)
                        
                        
                        VStack(alignment: .leading) {
                            Text(poem.cleanedPoem.trimmingCharacters(in: .whitespaces))
                                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding(16)
                
            }
        }
        
    }
}
