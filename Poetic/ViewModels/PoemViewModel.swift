//
//  PoemViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import Combine
import BackgroundTasks

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
    
    enum AuthorPoemState  {
        case idle
        case loading
        case failed
        case loaded
    }
    
    enum CSVPoemState  {
        case loading
        case failed(Error)
        case loaded([CSVPoem])
    }

//    @AppStorage(Constants.poemOfTheDay) var poemOfTheDay: CSVPoem?
    @AppStorage(Constants.darkModeEnable) var darkModeEnabled = false
    @AppStorage(Constants.systemThemeEnabled) var systemThemeEnabled = true
    @AppStorage(Constants.featuredAuthor1) var featuredAuthor1: String = ""
    @AppStorage(Constants.featuredAuthor2) var featuredAuthor2: String = ""
    @AppStorage(Constants.featuredAuthor3) var featuredAuthor3: String = ""
   
    @Published private(set) var csvPoems = [CSVPoem]()
    @Published private(set) var poems = [Poem]()
    @Published private(set) var randomPoems = [CSVPoem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published var searchTerm: String = ""
    @Published var isTitle: Bool = true
    
    private let apiService: APIServiceProtocol
    private let csvManager: CSVManagerDelegate
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var searchListLoadingError: String = ""
    @Published var showAlert: Bool = false
    
    var authorTitleCache: [String: [Poem]] = [:]
    var poemTitleSearchCache: [String: [Poem]] = [:]
   
    @Published private(set) var csvPoemState: CSVPoemState = .loading
    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    @Published private(set) var authorPoemState = AuthorPoemState.idle
    
    init(apiService: APIServiceProtocol, csvManager: CSVManagerDelegate) {
        self.apiService = apiService
        self.csvManager = csvManager
    }
    
    @MainActor
    func fetchCSVPoems() async {
        csvPoemState = .loading
        do {
            csvPoems = try await csvManager.parseCSV(fileName: "PoetryFoundationData", fileType: "csv")
            csvPoemState = .loaded(csvPoems)
        } catch {
            csvPoemState = .failed(error)
        }
    }
    
    func loadRandomPoems(number: Int) {
        state = .loading
        var uniquePoems = Set<CSVPoem>()
        
        DispatchQueue.global().async {
            while uniquePoems.count < number {
                if let randomPoem = self.csvPoems.randomElement() {
                    uniquePoems.insert(randomPoem)
                }
            }
            
            DispatchQueue.main.async {
                self.state = .loaded
                self.randomPoems = Array(uniquePoems)
                print(self.randomPoems)
            }
        }
    }
    
    func schedulePoemUpdate() {
            let request = BGAppRefreshTaskRequest(identifier: Constants.updatePoemIdentifier)
            request.earliestBeginDate = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(hour: 9),
                matchingPolicy: .nextTime
            )
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule poem update: \(error)")
            }
        }

        func handleAppRefresh(task: BGAppRefreshTask) {
            schedulePoemUpdate()
            getPoemOfTheDay()
            task.setTaskCompleted(success: true)
        }
    
    func getPoemOfTheDay() {
            // Check if the poem of the day has already been selected.
//            if let storedPoem = poemOfTheDay {
//                // Use the stored poem of the day.
//                poemOfTheDay = storedPoem
//            } else {
//                // Pick a new poem of the day.
//                if let newPoemOfTheDay = csvPoems.randomElement() {
//                    poemOfTheDay = newPoemOfTheDay
//                }
//            }
        }

    func fetchTitles(searchTerm: String) {
        if let cache = poemTitleSearchCache[searchTerm] {
            self.authorPoemState = .loaded
            self.authorPoems = cache
            return
        }
        let trimmedString = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString != "" {
            searchState = .loading
            apiService.fetchPoems(searchTerm: trimmedString, filter: .title)
                .sink { [weak self] (dataResponse) in
                    if dataResponse.error != nil {
                        self?.createAlert(with: dataResponse.error!)
                        self?.searchState = .failed
                    } else {
                        self?.poems = dataResponse.value!
                        self?.poemTitleSearchCache[searchTerm] = self?.poems
                        self?.searchState = .loaded
                    }
                }.store(in: &cancellables)
        } else {
            return
        }
    }
    
    func listenToSearch() {
        $searchTerm
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main, options: .none)
            .removeDuplicates()
            .sink { [weak self] delayQuery in
                guard let self = self else { return }
                if !delayQuery.isEmpty {
                    if self.isTitle {
                        self.fetchTitles(searchTerm: delayQuery)
                    }
                } else {
                    self.searchState = .idle
                }
            }
            .store(in: &self.cancellables)
    }
    
    func loadAuthorPoem(searchTerm: String) {
        if let cache = authorTitleCache[searchTerm] {
            self.authorPoemState = .loaded
            self.authorPoems = cache
            return
        }
        
        authorPoems = []
        authorPoemState = .loading
        
        apiService.fetchPoems(searchTerm: searchTerm, filter: .author)
            .sink { [weak self] (dataResponse) in
                if dataResponse.error != nil {
                    self?.createAlert(with: dataResponse.error!)
                    self?.authorPoemState = .failed
                } else {
                    self?.authorPoems = dataResponse.value!
                    self?.authorTitleCache[searchTerm] = self?.authorPoems
                    self?.authorPoemState = .loaded
                }
            }.store(in: &cancellables)
    }
    
    func createAlert(with error: NetworkError) {
        searchListLoadingError = error.backendError == nil ? error.initialError.localizedDescription : error.backendError!.message
        self.showAlert = true
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



