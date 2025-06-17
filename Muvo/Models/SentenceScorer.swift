    //
    //  SentenceScorer.swift
    //  Muvo
    //
    //  Created by Rieno on 16/06/25.
    //

    import SwiftUI

    // MARK: - Model
    // These are the data structures for the app. They don't contain any logic.

    struct PracticeSentence: Identifiable {
        let id = UUID()
        let english: String
        let indonesian: String
    }

    enum RecognitionState {
        case idle
        case recording
        case processing
        case result
    }

    struct PronunciationResult {
        let score: Int
        let feedback: String
        let isCorrect: Bool
        let recognizedText: String
    }

    enum SpeechRecognitionResult {
        case success(String)
        case noSpeech
        case error(String)
    }

    enum PronunciationScoringResult {
        case result(PronunciationResult)
        case speechResult(SpeechRecognitionResult)
        case error(String)
    }
