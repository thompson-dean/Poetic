//
//  PoemReader.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import AVFoundation
import Combine

/// Reads a poem aloud with the system's on-device voices, one line at a
/// time, and publishes which line is being spoken so the reading screen
/// can highlight and follow it. Free, offline, and works for every poem.
@MainActor
final class PoemReader: NSObject, ObservableObject {
    enum State: Equatable {
        case idle, speaking, paused
    }

    @Published private(set) var state: State = .idle
    /// Index into the poem's `lines` currently being spoken.
    @Published private(set) var currentLine: Int?

    private let synthesizer = AVSpeechSynthesizer()
    /// Maps each queued utterance back to its line index.
    private var lineForUtterance: [ObjectIdentifier: Int] = [:]
    private var lastUtterance: AVSpeechUtterance?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func toggle(_ lines: [String]) {
        switch state {
        case .idle: start(lines)
        case .speaking: pause()
        case .paused: resume()
        }
    }

    func start(_ lines: [String]) {
        stop()
        activateAudioSession()
        let voice = Self.bestVoice()
        for (index, raw) in lines.enumerated() {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else {
                // Stanza break: a longer breath after the previous line.
                lastUtterance?.postUtteranceDelay = 0.7
                continue
            }
            let utterance = AVSpeechUtterance(string: line)
            utterance.voice = voice
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.88
            utterance.postUtteranceDelay = 0.25
            lineForUtterance[ObjectIdentifier(utterance)] = index
            lastUtterance = utterance
            synthesizer.speak(utterance)
        }
        state = lineForUtterance.isEmpty ? .idle : .speaking
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
        state = .paused
    }

    func resume() {
        synthesizer.continueSpeaking()
        state = .speaking
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        lineForUtterance.removeAll()
        lastUtterance = nil
        currentLine = nil
        state = .idle
    }

    private func activateAudioSession() {
        // .playback so it's heard with the silent switch on; spoken-audio
        // mode lets other apps pause/duck appropriately.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// The highest-quality installed voice for the user's English locale
    /// (Premium > Enhanced > default). Users can download better voices in
    /// Settings > Accessibility > Spoken Content.
    static func bestVoice() -> AVSpeechSynthesisVoice? {
        let preferred = Locale.preferredLanguages.first { $0.hasPrefix("en") } ?? "en-US"
        let english = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        let ranked = english.sorted { lhs, rhs in
            if lhs.quality != rhs.quality { return lhs.quality.rawValue > rhs.quality.rawValue }
            return (lhs.language == preferred) && (rhs.language != preferred)
        }
        return ranked.first ?? AVSpeechSynthesisVoice(language: preferred)
    }
}

extension PoemReader: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            if let line = self.lineForUtterance[id] {
                self.currentLine = line
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            guard self.lineForUtterance[id] != nil else { return }
            self.lineForUtterance[id] = nil
            if self.lineForUtterance.isEmpty {
                self.currentLine = nil
                self.state = .idle
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
    }
}
