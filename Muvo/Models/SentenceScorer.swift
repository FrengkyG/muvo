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

enum RecognitionState {
    case idle, recording, processing, result
}

enum PracticeCategory: String {
    case hotel = "Hotel"
    case airport = "Airport"
}

enum PronunciationAccuracy {
    case perfect, almost, tryAgain
}

enum SpeechRecognitionResult {
    case success(String)
    case noSpeech
    case error(String)
}

struct PracticeSentence {
    let english: String
    let indonesian: String
    let category: PracticeCategory
    let modelName: String
}

// THIS IS THE MODIFIED STRUCT
struct PronunciationResult {
    let accuracy: PronunciationAccuracy
    let recognizedText: String
    let score: Int // Optional score
}

