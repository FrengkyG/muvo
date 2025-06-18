//
//  PronunciationScorerModel.swift
//  Muvo
//
//  Created by Rieno on 16/06/25.
//

import SwiftUI
import AVFoundation
import Speech
import CoreML
import SoundAnalysis
import Accelerate

class PronunciationViewModel: NSObject, ObservableObject, AudioProcessingServiceDelegate {

    // MARK: - Published Properties
    @Published var state: RecognitionState = .idle
    @Published var isRecordingButtonEnabled: Bool = true
    @Published var currentSentenceIndex: Int = 0
    @Published var sentences: [PracticeSentence] = []
    @Published var lastResult: PronunciationResult?
    @Published var waveformSamples: [CGFloat] = []
    @Published var currentGroup: Int = 1
    
    // --- Separate failure counters for internal logic ---
    @Published private var currentAlmostFailureCount: Int = 0
    @Published private var currentTryAgainFailureCount: Int = 0
    
    var audioPlayer: AVAudioPlayer?

    // MARK: - Services
    private let sentenceProvider = SentenceProvider()
    private lazy var audioService: AudioProcessingService = {
        let service = AudioProcessingService()
        service.delegate = self
        return service
    }()
    
    // MARK: - State Management
    // --- Dictionaries to store separate failure counts for all sentences ---
    private var sentenceAlmostFailureCounts: [Int: Int] = [:]
    private var sentenceTryAgainFailureCounts: [Int: Int] = [:]
    
    var currentSentence: PracticeSentence {
        guard sentences.indices.contains(currentSentenceIndex) else {
            return PracticeSentence(english: "Loading...", indonesian: "...", category: .airport, modelName: "soundclafAIR", audioFileName: "")
        }
        return sentences[currentSentenceIndex]
    }
    
    /// A computed property that provides the correct failure count to the UI based on the last result.
    var currentSentenceFailureCount: Int {
        guard let lastAccuracy = lastResult?.accuracy else { return 0 }
        
        switch lastAccuracy {
        case .almost:
            return currentAlmostFailureCount
        case .tryAgain:
            return currentTryAgainFailureCount
        case .perfect:
            return 0
        }
    }
    
    /// A computed property to determine if the "skip" button should be shown based on separate failure counts.
    var shouldShowSkipButton: Bool {
        let canSkipOnAlmost = (currentAlmostFailureCount >= 3)
        let canSkipOnTryAgain = (currentTryAgainFailureCount >= 2)
        
        return canSkipOnAlmost || canSkipOnTryAgain
    }

    // MARK: - Initialization
    override init() {
        super.init()
        loadSentences(for: currentGroup)
        requestPermissions()
    }

    // MARK: - Public User Actions
    func handleRecordingAction() {
        if state == .idle {
            startRecording()
        } else if state == .recording {
            stopRecording()
        }
    }
    
    func playCurrentSentenceAudio() {
        guard let url = Bundle.main.url(forResource: currentSentence.audioFileName, withExtension: nil) else {
            print("Error: Audio file '\(currentSentence.audioFileName)' not found.")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing audio: \(currentSentence.audioFileName)")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func nextSentence() {
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
        } else {
            currentGroup = (currentGroup == 1) ? 2 : 1
            loadSentences(for: currentGroup)
        }
        updateCurrentFailureCounts()
        resetForNewRecording()
    }

    func skipToNext() {
        // Reset counters for the sentence being skipped before moving on
        sentenceAlmostFailureCounts[currentSentenceIndex] = 0
        sentenceTryAgainFailureCounts[currentSentenceIndex] = 0
        nextSentence()
    }

    func tryAgain() {
        resetForNewRecording()
    }
    
    func showWordAnalysis() {
        print("Feature: Showing word-by-word analysis...")
        resetForNewRecording()
    }
    
    // MARK: - Private Methods
    
    /// Loads the sentences for a specific group and resets all failure count states.
    private func loadSentences(for group: Int) {
        print("[INFO] Loading sentences for group \(group).")
        self.sentences = sentenceProvider.getSentences(for: group)
        self.currentSentenceIndex = 0
        self.sentenceAlmostFailureCounts.removeAll()
        self.sentenceTryAgainFailureCounts.removeAll()
        updateCurrentFailureCounts()
    }

    private func startRecording() {
        state = .recording
        waveformSamples = []
        audioService.startRecording(for: currentSentence.category)
    }

    private func stopRecording() {
        state = .processing
        isRecordingButtonEnabled = false
        audioService.stopRecording()
    }
    
    func didUpdateWaveform(samples: [CGFloat]) {
        self.waveformSamples.append(contentsOf: samples)
        if self.waveformSamples.count > 100 {
             self.waveformSamples.removeFirst(self.waveformSamples.count - 100)
        }
    }
    
    func didFinishProcessing(result: SpeechRecognitionResult, classification: String?) {
        let finalAccuracy: PronunciationAccuracy
        var recognizedTextResult = ""

        switch result {
        case .success(let recognizedText):
            recognizedTextResult = recognizedText
            finalAccuracy = evaluatePronunciation(mlClassification: classification, recognizedText: recognizedText)
        case .noSpeech, .error:
            finalAccuracy = .tryAgain
        }
        
        // This must be called BEFORE the dispatch block to ensure the new counts are available for the computed property.
        updateFailureCount(for: finalAccuracy)
        
        DispatchQueue.main.async {
            self.lastResult = PronunciationResult(
                accuracy: finalAccuracy,
                recognizedText: recognizedTextResult,
                score: self.score(for: finalAccuracy)
            )
            self.state = .result
            self.isRecordingButtonEnabled = true
        }
    }

    private func evaluatePronunciation(mlClassification: String?, recognizedText: String) -> PronunciationAccuracy {
        let normalizedTarget = normalizeText(currentSentence.english)
        let normalizedSTTResult = normalizeText(recognizedText)

        if let mlClassification = mlClassification, normalizeText(mlClassification) == normalizedTarget {
            return .perfect
        }
        
        let targetWordCount = normalizedTarget.components(separatedBy: " ").count
        let matchingWordCount = countMatchingWords(recognized: normalizedSTTResult, target: recognizedText)
        if targetWordCount > 0 && Double(matchingWordCount) / Double(targetWordCount) >= 0.6 {
            return .almost
        }
        
        return .tryAgain
    }
    
    private func resetForNewRecording() {
        lastResult = nil
        state = .idle
    }

    private func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    /// Updates the appropriate failure counter based on the result accuracy.
    private func updateFailureCount(for accuracy: PronunciationAccuracy) {
        switch accuracy {
        case .perfect:
            sentenceAlmostFailureCounts[currentSentenceIndex] = 0
            sentenceTryAgainFailureCounts[currentSentenceIndex] = 0
        case .almost:
            sentenceAlmostFailureCounts[currentSentenceIndex, default: 0] += 1
            sentenceTryAgainFailureCounts[currentSentenceIndex] = 0 // Reset other counter
        case .tryAgain:
            sentenceTryAgainFailureCounts[currentSentenceIndex, default: 0] += 1
            sentenceAlmostFailureCounts[currentSentenceIndex] = 0 // Reset other counter
        }
        updateCurrentFailureCounts()
    }
    
    /// Updates the published properties for the current sentence's failure counts.
    private func updateCurrentFailureCounts() {
        currentAlmostFailureCount = sentenceAlmostFailureCounts[currentSentenceIndex] ?? 0
        currentTryAgainFailureCount = sentenceTryAgainFailureCounts[currentSentenceIndex] ?? 0
    }

    private func normalizeText(_ text: String) -> String {
        return text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func countMatchingWords(recognized: String, target: String) -> Int {
        let recognizedWords = Set(recognized.components(separatedBy: " "))
        let targetWords = Set(target.components(separatedBy: " "))
        return recognizedWords.intersection(targetWords).count
    }

    private func score(for accuracy: PronunciationAccuracy) -> Int {
        switch accuracy {
        case .perfect: return 100
        case .almost: return 50
        case .tryAgain: return 0
        }
    }
}
