    //
    //  SentenceScorer.swift
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


/// Represents the current state of the speech recognition process.
enum RecognitionState {
    case idle, recording, processing, result
}

/// Defines the categories for practice sentences.
enum PracticeCategory: String {
    case hotel = "Hotel"
    case airport = "Airport"
}

/// Represents the accuracy of the user's pronunciation.
enum PronunciationAccuracy {
    case perfect, almost, tryAgain
}

/// A wrapper for the result of a speech recognition task.
enum SpeechRecognitionResult {
    case success(String)
    case noSpeech
    case error(String)
}

/// Represents a single practice sentence, now with an associated audio file.
struct PracticeSentence {
    let english: String
    let indonesian: String
    let category: PracticeCategory
    let modelName: String
    let audioFileName: String
}

/// Represents the final result of a pronunciation attempt.
struct PronunciationResult {
    let accuracy: PronunciationAccuracy
    let recognizedText: String
    let score: Int 
}
