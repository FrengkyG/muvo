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

class PronunciationViewModel: NSObject, ObservableObject, SNResultsObserving {
    
    // MARK: - Published Properties
    @Published var state: RecognitionState = .idle
    @Published var isRecordingButtonEnabled: Bool = true
    @Published var currentSentenceIndex: Int = 0
    @Published var lastResult: PronunciationResult?
    @Published var waveformSamples: [CGFloat] = []
    
    // Data for the view
    let sentences: [PracticeSentence] = [
        PracticeSentence(english: "My luggage is missing.", indonesian: "Koper saya hilang."),
        PracticeSentence(english: "Where is the immigration counter?", indonesian: "Di mana konter imigrasi?"),
        PracticeSentence(english: "I have a reservation.", indonesian: "Saya punya reservasi."),
        PracticeSentence(english: "A table for two, please.", indonesian: "Meja untuk dua orang."),
        PracticeSentence(english: "What time is my flight?", indonesian: "Jam berapa penerbangan saya?")
    ]
    
    var currentSentence: PracticeSentence {
        guard sentences.indices.contains(currentSentenceIndex) else {
            return PracticeSentence(english: "Loading...", indonesian: "...")
        }
        return sentences[currentSentenceIndex]
    }
    
    // MARK: - Private Properties
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var soundClassificationRequest: SNClassifySoundRequest?
    private var audioStreamAnalyzer: SNAudioStreamAnalyzer?
    private var analysisQueue = DispatchQueue(label: "AudioAnalysisQueue")
    
    private var classificationResults: [String] = []
    private var isAnalyzing = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSoundAnalysis()
        requestPermissions()
    }
    
    // MARK: - Public Methods
    func handleRecordingAction() {
        switch state {
        case .idle:
            startRecording()
        case .recording:
            stopRecording()
        default:
            break
        }
    }
    
    func nextSentence() {
        // Move to next sentence
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
        } else {
            currentSentenceIndex = 0 // Loop back to start
        }
        resetForNewRecording()
    }
    
    func dismissResult() {
        // Just go back to idle state to dismiss the modal
        resetForNewRecording()
    }
    
    func tryAgain() {
        // Stay on same sentence, just reset
        resetForNewRecording()
    }
    
    // MARK: - Private Methods
    private func resetForNewRecording() {
        lastResult = nil
        state = .idle
        isRecordingButtonEnabled = true
        waveformSamples = []
        classificationResults.removeAll()
    }
    
    private func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    private func setupSoundAnalysis() {
        guard let modelURL = Bundle.main.url(forResource: "soundclafAIR", withExtension: "mlmodelc") else {
            print("Could not find compiled model file: soundclafAIR.mlmodelc.")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            soundClassificationRequest = try SNClassifySoundRequest(mlModel: mlModel)
            print("SoundAnalysis model loaded successfully")
        } catch {
            print("Failed to load SoundAnalysis model: \(error)")
        }
    }
    
    private func startRecording() {
        print("Starting recording...")
        self.waveformSamples = []
        lastResult = nil
        classificationResults.removeAll()
        isAnalyzing = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = false
        
        setupAudioStreamAnalyzer()
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            self.recognitionRequest?.append(buffer)
            self.analyzeAudioBuffer(buffer, at: time)
            self.updateWaveform(from: buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.state = .recording
                self.isRecordingButtonEnabled = true // Enable immediately for stopping
            }
        } catch {
            print("Audio engine start failed: \(error)")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            // This callback will be triggered when recording stops
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                let recognizedText = result?.bestTranscription.formattedString ?? ""
                print("Recognition completed: \(recognizedText)")
                
                DispatchQueue.main.async {
                    if recognizedText.isEmpty && error == nil {
                        self.processWithHybridApproach(result: .noSpeech)
                    } else if let error = error {
                        self.processWithHybridApproach(result: .error(error.localizedDescription))
                    } else {
                        self.processWithHybridApproach(result: .success(recognizedText))
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        print("Stopping recording...")
        DispatchQueue.main.async {
            self.state = .processing
            self.isRecordingButtonEnabled = false
        }
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioStreamAnalyzer?.completeAnalysis()
        self.waveformSamples = []
        
        // Give a small delay to ensure all processing is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.state == .processing && self.lastResult == nil {
                // If we're still processing and no result, create a default result
                let defaultResult = PronunciationResult(
                    score: 0,
                    feedback: "Tidak ada suara yang terdeteksi. Coba lagi!",
                    isCorrect: false,
                    recognizedText: ""
                )
                self.lastResult = defaultResult
                self.state = .result
                self.isRecordingButtonEnabled = true
            }
        }
    }
    
    private func updateWaveform(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let dataPointer = UnsafeBufferPointer(start: channelData.pointee, count: Int(buffer.frameLength))
        let rms = vDSP.rootMeanSquare(dataPointer)
        
        let amplification: CGFloat = 150.0
        let normalizedValue = min(max(CGFloat(rms) * amplification, 0.0), 1.0)
        
        DispatchQueue.main.async {
            self.waveformSamples.append(normalizedValue)
            if self.waveformSamples.count > 50 {
                self.waveformSamples.removeFirst()
            }
        }
    }
    
    private func setupAudioStreamAnalyzer() {
        guard let request = soundClassificationRequest else { return }
        audioStreamAnalyzer = SNAudioStreamAnalyzer(format: audioEngine.inputNode.outputFormat(forBus: 0))
        do {
            try audioStreamAnalyzer?.add(request, withObserver: self)
        } catch {
            print("Failed to add classification request: \(error)")
        }
    }
    
    private func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let analyzer = audioStreamAnalyzer, isAnalyzing else { return }
        analysisQueue.async {
            analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }
    
    private func processWithHybridApproach(result: SpeechRecognitionResult) {
        print("Processing hybrid approach with result: \(result)")
        isAnalyzing = false
        
        switch result {
        case .success(let recognizedText):
            let mlResult = getBestClassificationResult()
            handleMLResult(mlClassification: mlResult, recognizedText: recognizedText)
        case .noSpeech:
            self.lastResult = PronunciationResult(
                score: 0,
                feedback: "Kami tidak mendengar suara. Silakan coba lagi!",
                isCorrect: false,
                recognizedText: ""
            )
        case .error(let message):
            self.lastResult = PronunciationResult(
                score: 0,
                feedback: "Terjadi kesalahan: \(message)",
                isCorrect: false,
                recognizedText: ""
            )
        }
        
        DispatchQueue.main.async {
            self.state = .result
            self.isRecordingButtonEnabled = true
            print("Result set: \(String(describing: self.lastResult))")
        }
    }
    
    private func getBestClassificationResult() -> String? {
        guard !classificationResults.isEmpty else {
            print("No classification results available")
            return nil
        }
        let frequency = classificationResults.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        let best = frequency.max(by: { $0.value < $1.value })?.key
        print("Best ML classification: \(String(describing: best)) from \(classificationResults.count) results")
        return best
    }
    
    private func handleMLResult(mlClassification: String?, recognizedText: String) {
        let normalizedTarget = normalizeText(currentSentence.english)
        let normalizedSTTResult = normalizeText(recognizedText)
        
        print("Target: \(normalizedTarget)")
        print("STT Result: \(normalizedSTTResult)")
        print("ML Classification: \(String(describing: mlClassification))")
        
        var finalScore: Int
        var isCorrect: Bool
        var feedbackMessage: String
        
        if let mlClassification = mlClassification {
            let normalizedMLResult = normalizeText(mlClassification)
            print("Normalized ML: \(normalizedMLResult)")
            
            if normalizedMLResult == normalizedTarget {
                // ML model recognized correctly
                if normalizedSTTResult == normalizedTarget {
                    // Both ML and STT are correct
                    finalScore = 100
                    isCorrect = true
                    feedbackMessage = "Luar biasa! Pengucapanmu sempurna."
                } else {
                    // ML correct, STT different
                    finalScore = 85
                    isCorrect = true
                    feedbackMessage = "Bagus! Pengucapanmu sudah benar."
                }
            } else {
                // ML didn't match target
                if normalizedSTTResult == normalizedTarget {
                    // STT is correct even though ML wasn't
                    finalScore = 90
                    isCorrect = true
                    feedbackMessage = "Bagus! Kata-katamu sudah tepat."
                } else {
                    // Neither ML nor STT matched
                    finalScore = calculatePartialScore(normalizedSTTResult, normalizedTarget)
                    isCorrect = finalScore >= 70
                    feedbackMessage = isCorrect ? "Cukup bagus! Terus berlatih." : "Coba lagi! Fokus pada pengucapan yang jelas."
                }
            }
        } else {
            // No ML result, use STT only
            if normalizedSTTResult == normalizedTarget {
                finalScore = 80
                isCorrect = true
                feedbackMessage = "Bagus! Kata-katamu sudah tepat."
            } else {
                finalScore = calculatePartialScore(normalizedSTTResult, normalizedTarget)
                isCorrect = finalScore >= 70
                feedbackMessage = isCorrect ? "Cukup bagus!" : "Coba lagi dengan pengucapan yang lebih jelas."
            }
        }
        
        self.lastResult = PronunciationResult(
            score: finalScore,
            feedback: feedbackMessage,
            isCorrect: isCorrect,
            recognizedText: recognizedText
        )
        
        print("Final result: Score=\(finalScore), Correct=\(isCorrect)")
    }
    
    private func calculatePartialScore(_ recognized: String, _ target: String) -> Int {
        let recognizedWords = recognized.components(separatedBy: " ")
        let targetWords = target.components(separatedBy: " ")
        
        let matchingWords = recognizedWords.filter { targetWords.contains($0) }
        let scorePercentage = Double(matchingWords.count) / Double(targetWords.count)
        
        return Int(scorePercentage * 60) // Max 60 points for partial matches
    }
    
    private func normalizeText(_ text: String) -> String {
        return text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    // MARK: - SNResultsObserving
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let classification = classificationResult.classifications.first else { return }
        
        if classification.confidence > 0.3 { // Lowered threshold for more results
            classificationResults.append(classification.identifier)
            print("ML Classification: \(classification.identifier) (confidence: \(classification.confidence))")
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound classification failed: \(error)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Sound classification completed")
    }
}
