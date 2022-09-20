//
//  PoemViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import CoreHaptics

class PoemViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    enum SearchTitleState {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    enum RandomPoemState  {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    
    let dataManager = DataManager()
    
    @Published var fontSize: CGFloat = 14
    @AppStorage("darkModeEnabled") var darkModeEnabled = false
    @AppStorage("systemThemeEnabled") var systemThemeEnabled = true
    
    var floatedFontSize: CGFloat {
        CGFloat(fontSize)
    }
    
    //Arrays
    @Published private(set) var poems = [Poem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published private(set) var randomPoems = [Poem]()

    @Published var searchTerm: String = ""
    
    var authorTitleCache: [String: [Poem]] = [:]
    
    var timer: Timer?
    
    //State change variables
    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    @Published private(set) var randomPoemState = RandomPoemState.idle
    
    //SearchView Handling - fetchs data for title search.
    
    func loadPoem(searchTerm: String, filter: DataManager.SearchFilter) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { _ in
            self.poems = []
            
            if searchTerm == "" {
                self.searchState = .idle
                return
            } else {
                self.searchState = .loading
                
                self.dataManager.loadData(filter: DataManager.SearchFilter.title, searchTerm: searchTerm) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .failure(let error):
                            self.searchState = .failed(error)
                            self.simpleHapticError()
                            print(error.localizedDescription)
                        case .success(let searchedPoems):
                            self.searchState = .loaded
                            self.poems = searchedPoems
                        }
                    }
                }
            }
        }
    }
    
    //AuthorView Handling - loads authors poems in AuthorView
    func loadAuthorPoem(searchTerm: String) {
        //use cache to stop the API calling again.
        if let cache = authorTitleCache[searchTerm] {
            self.state = .loaded
            self.authorPoems = cache
            return
        }
        
        authorPoems = []
        state = .loading
        
        dataManager.loadData(filter: DataManager.SearchFilter.author, searchTerm: searchTerm) { result in
            DispatchQueue.main.async {
                switch result {
                    
                case .failure(let error):
                    self.state = .failed(error)
                    print(error.localizedDescription)
                    self.simpleHapticError()
                case .success(let searchedPoems):
                    self.state = .loaded
                    self.authorPoems = searchedPoems
                    self.authorTitleCache[searchTerm] = searchedPoems

                }
            }
        }
    }
    
    //HomeView Handling - fetchs random poem for Home Screen.
    func loadRandomPoems(searchTerm: String) {
        randomPoems = [
            Poem(
                title: "Sonnet 1: From fairest creatures we desire increase",
                author: "William Shakespeare",
                lines: [
                    "From fairest creatures we desire increase,",
                    "That thereby beauty's rose might never die,",
                    "But as the riper should by time decease, ",
                    "His tender heir might bear his memory",
                    "But thou contracted to thine own bright eyes,",
                    "Feed'st thy light's flame with self-substantial fuel,",
                    "Making a famine where abundance lies,",
                    "Thy self thy foe, to thy sweet self too cruel:",
                    "Thou that art now the world's fresh ornament,",
                    "And only herald to the gaudy spring,",
                    "Within thine own bud buriest thy content,",
                    "And tender churl mak'st waste in niggarding:",
                    " Pity the world, or else this glutton be,",
                    " To eat the world's due, by the grave and thee."
                ],
                linecount: "14"),
            Poem(
                title: "Sonnet 1: From fairest creatures we desire increase",
                author: "William Shakespeare",
                lines: [
                    "From fairest creatures we desire increase,",
                    "That thereby beauty's rose might never die,",
                    "But as the riper should by time decease, ",
                    "His tender heir might bear his memory",
                    "But thou contracted to thine own bright eyes,",
                    "Feed'st thy light's flame with self-substantial fuel,",
                    "Making a famine where abundance lies,",
                    "Thy self thy foe, to thy sweet self too cruel:",
                    "Thou that art now the world's fresh ornament,",
                    "And only herald to the gaudy spring,",
                    "Within thine own bud buriest thy content,",
                    "And tender churl mak'st waste in niggarding:",
                    " Pity the world, or else this glutton be,",
                    " To eat the world's due, by the grave and thee."
                ],
                linecount: "14")
        ]
        randomPoemState = .idle
        randomPoemState = .loading
        dataManager.loadData(filter: DataManager.SearchFilter.random, searchTerm: searchTerm) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.randomPoemState = .failed(error)
                    print(error.localizedDescription)
                    self.simpleHapticError()
                case .success(let searchedPoems):
                    self.randomPoems = searchedPoems
                    self.randomPoemState = .loaded
                    
                }
            } 
        }
    }
    
    //Handle Haptics
    func simpleHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func simpleHapticError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func mediumImpactHaptic() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred(intensity: 1.0)
    }
}



