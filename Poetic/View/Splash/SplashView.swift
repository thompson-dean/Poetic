//
//  SplashView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/29.
//

import SwiftUI

struct SplashView: View {
    let fonts = Fonts()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingError: Bool = false
    @ObservedObject var storeKitManager: StoreKitManager
    @StateObject var viewModel = PoemViewModel(apiService: APIService(), csvManager: CSVManager())
    @State private var quote = ""
    let fullQuote = "Discover Poetry!"
    @State private var timer: Timer? = nil
    @State private var poeticOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                .ignoresSafeArea(.all)
            
            switch viewModel.csvPoemState {
            case .loading:
                VStack(alignment: .leading) {
                    Text("Poetic.")
                        .fontWithLineHeight(font: fonts.newYorkFont, lineHeight: 48)
                        .foregroundColor(.primary)
                        .opacity(poeticOpacity)
                        .animation(.easeInOut(duration: 2), value: poeticOpacity)
                    
                    Text(quote)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 16)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                        .padding(.horizontal, 16)
                        .onAppear {
                            startTyping()
                        }
                        .animation(.default, value: quote)
                }
                .onAppear {
                    Task {
                        await viewModel.fetchCSVPoems()
                    }
                }
            case .failed:
                Text("Poetic.")
                    .fontWithLineHeight(font: fonts.newYorkFont, lineHeight: 48)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .onAppear {
                        isShowingError = true
                    }
                    .alert(isPresented: $isShowingError) {
                        Alert(title: Text("Unable to load .csv. Please try again later."))
                    }
            case .loaded:
                ContentView(viewModel: viewModel, storeKitManager: storeKitManager)
            }
        }
    }
    
    func startTyping() {
        var charIndex = fullQuote.startIndex
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if charIndex != fullQuote.endIndex {
                quote.append(fullQuote[charIndex])
                charIndex = fullQuote.index(after: charIndex)
            } else {
                timer?.invalidate()
                timer = nil
                poeticOpacity = 1.0
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(storeKitManager: StoreKitManager())
    }
}
