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



/// Manages the state and coordinates the logic for the pronunciation practice feature.
class PronunciationViewModel: NSObject, ObservableObject, AudioProcessingServiceDelegate {

    // MARK: - Published Properties
    @Published var state: RecognitionState = .idle
    @Published var isRecordingButtonEnabled: Bool = true
    @Published var currentSentenceIndex: Int = 0
    @Published var sentences: [PracticeSentence] = []
    @Published var lastResult: PronunciationResult?
    @Published var waveformSamples: [CGFloat] = []
    @Published var currentSentenceFailureCount: Int = 0

    // MARK: - Services
    private let sentenceProvider = SentenceProvider()
    private lazy var audioService: AudioProcessingService = {
        let service = AudioProcessingService()
        service.delegate = self
        return service
    }()
    
    // MARK: - State Management
    private var sentenceFailureCounts: [Int: Int] = [:]
    
    var currentSentence: PracticeSentence {
        guard sentences.indices.contains(currentSentenceIndex) else {
            return PracticeSentence(english: "Loading...", indonesian: "...", category: .airport, modelName: "soundclafAIR")
        }
        return sentences[currentSentenceIndex]
    }

    // MARK: - Initialization
    override init() {
        super.init()
        self.sentences = sentenceProvider.getRandomizedSentences()
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

    func nextSentence() {
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
        } else {
            sentences = sentenceProvider.getRandomizedSentences()
            currentSentenceIndex = 0
            sentenceFailureCounts.removeAll()
        }
        updateCurrentSentenceFailureCount()
        resetForNewRecording()
    }

    func skipToNext() {
        sentenceFailureCounts[currentSentenceIndex] = 0
        nextSentence()
    }

    func tryAgain() {
        resetForNewRecording()
    }
    
    func showWordAnalysis() {
        print("Feature: Showing word-by-word analysis...")
        // Future implementation for word analysis would go here.
        resetForNewRecording()
    }

    // MARK: - Recording Flow
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
    
    // MARK: - AudioProcessingServiceDelegate
    func didUpdateWaveform(samples: [CGFloat]) {
        self.waveformSamples.append(contentsOf: samples)
        if self.waveformSamples.count > 50 {
            self.waveformSamples.removeFirst(self.waveformSamples.count - 50)
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

    // MARK: - Scoring & State Helpers
    private func evaluatePronunciation(mlClassification: String?, recognizedText: String) -> PronunciationAccuracy {
        let normalizedTarget = normalizeText(currentSentence.english)
        let normalizedSTTResult = normalizeText(recognizedText)

        if let mlClassification = mlClassification, normalizeText(mlClassification) == normalizedTarget {
            return .perfect
        }
        
        let targetWordCount = normalizedTarget.components(separatedBy: " ").count
        let matchingWordCount = countMatchingWords(recognized: normalizedSTTResult, target: normalizedTarget)
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
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted { print("Microphone permission was denied.") }
        }
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized { print("Speech recognition permission was denied.") }
        }
    }
    
    private func updateFailureCount(for accuracy: PronunciationAccuracy) {
        if accuracy == .perfect {
            sentenceFailureCounts[currentSentenceIndex] = 0
        } else {
            sentenceFailureCounts[currentSentenceIndex, default: 0] += 1
        }
        updateCurrentSentenceFailureCount()
    }
    
    private func updateCurrentSentenceFailureCount() {
        currentSentenceFailureCount = sentenceFailureCounts[currentSentenceIndex] ?? 0
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
