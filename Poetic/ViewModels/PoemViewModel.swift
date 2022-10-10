//
//  PoemViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import Combine
import CoreHaptics

class PoemViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed
        case loaded
    }
    
    enum SearchTitleState {
        case idle
        case loading
        case failed
        case loaded
    }
    
    enum RandomPoemState  {
        case idle
        case loading
        case failed
        case loaded
    }

    @AppStorage("darkModeEnabled") var darkModeEnabled = false
    @AppStorage("systemThemeEnabled") var systemThemeEnabled = true
   
    @Published private(set) var poems = [Poem]()
    @Published private(set) var randomPoems = [Poem]()
    @Published var searchTerm: String = ""
    @Published var isTitle: Bool = true
    
    private let apiService: APIServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var chatListLoadingError: String = ""
    @Published var showAlert: Bool = false
    
    var authorTitleCache: [String: [Poem]] = [:]
    
    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    @Published private(set) var randomPoemState = RandomPoemState.idle
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func loadRandomPoems(searchTerm: String) {
        randomPoemState = .loading
        randomPoems = exampleData()
        apiService.fetchPoems(searchTerm: searchTerm, filter: .random)
            .sink { [weak self] (dataResponse) in
                if dataResponse.error != nil {
                    self?.createAlert(with: dataResponse.error!)
                    self?.randomPoemState = .failed
                } else {
                    self?.randomPoems = dataResponse.value!
                    self?.randomPoemState = .loaded
                }
            }.store(in: &cancellables)
    }
    
    func fetchTitles(searchTerm: String) {
        searchState = .loading
        randomPoems = exampleData()
        apiService.fetchPoems(searchTerm: searchTerm, filter: .title)
            .sink { [weak self] (dataResponse) in
                if dataResponse.error != nil {
                    self?.createAlert(with: dataResponse.error!)
                    self?.searchState = .failed
                } else {
                    self?.poems = dataResponse.value!
                    self?.searchState = .loaded
                }
            }.store(in: &cancellables)
    }
    
    func listenToSearch() {
        $searchTerm
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] delayQuery in
                guard let self = self else { return }
                if !delayQuery.isEmpty {
                    if self.isTitle {
                        self.fetchTitles(searchTerm: self.searchTerm)
                    } 
                } else {
                    self.searchState = .idle
                }
            }.store(in: &cancellables)
        
    }
    
    func createAlert( with error: NetworkError ) {
        chatListLoadingError = error.backendError == nil ? error.initialError.localizedDescription : error.backendError!.message
        self.showAlert = true
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
    
    func exampleData() -> [Poem] {
        let poems = [
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
        return poems
    }
}



