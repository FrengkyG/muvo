//
//  PronunciationScorerModel.swift
//  Muvo
//
//  Created by Rieno on 16/06/25.
//

import SwiftUI

import SwiftUI
import AVFoundation
import Speech
import CoreML
import SoundAnalysis



// MARK: - ViewModel
// This class holds all the state and business logic for the practice screen.
class PronunciationViewModel: NSObject, ObservableObject, SNResultsObserving {
    
    // MARK: - Published Properties (for the View)
    @Published var state: RecognitionState = .idle
    @Published var isRecordingButtonEnabled: Bool = true
    @Published var currentSentenceIndex: Int = 0
    @Published var lastResult: PronunciationResult?
    
    // Data for the view
    let sentences: [PracticeSentence] = [
        PracticeSentence(english: "My luggage is missing.", indonesian: "Koper saya hilang."),
        PracticeSentence(english: "Where is the immigration counter?", indonesian: "Di mana loket imigrasi?"),
        PracticeSentence(english: "I lost my boarding pass.", indonesian: "Saya kehilangan boarding pass saya."),
        PracticeSentence(english: "I missed my flight.", indonesian: "Saya ketinggalan pesawat."),
        PracticeSentence(english: "Here is my passport and ticket", indonesian: "Ini paspor dan tiket saya")
    ]
    
    var currentSentence: PracticeSentence {
        sentences[currentSentenceIndex]
    }
    
    // MARK: - Private Properties (for internal logic)
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
    }
    
    // MARK: - Public Methods (called by the View)
    
    func handleRecordingAction() {
        switch state {
        case .idle:
            startRecording()
        case .recording:
            guard isRecordingButtonEnabled else { return }
            stopRecording()
        case .processing:
            break // Button is disabled
        }
    }
    
    func nextSentence() {
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
        } else {
            // Optionally, handle quiz completion
            currentSentenceIndex = 0 // loop back to start
        }
        lastResult = nil
    }
    
    // MARK: - Private Logic
    
    private func setupSoundAnalysis() {
        guard let modelURL = Bundle.main.url(forResource: "soundclafAFP1", withExtension: "mlmodelc") else {
            print("Could not find compiled model file: soundclafAFP1.mlmodelc.")
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
        lastResult = nil
        classificationResults.removeAll()
        isAnalyzing = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed")
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
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            state = .recording
            isRecordingButtonEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.state == .recording {
                    self.isRecordingButtonEnabled = true
                }
            }
        } catch {
            print("Audio engine start failed")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                let recognizedText = result?.bestTranscription.formattedString ?? ""
                
                DispatchQueue.main.async {
                    if recognizedText.isEmpty && error == nil {
                         self.processWithHybridApproach(result: .noSpeech)
                    } else if error != nil {
                        self.processWithHybridApproach(result: .error(error!.localizedDescription))
                    } else {
                        self.processWithHybridApproach(result: .success(recognizedText))
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioStreamAnalyzer?.completeAnalysis()
        
        state = .processing
        isRecordingButtonEnabled = false
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
        isAnalyzing = false
        
        switch result {
        case .success(let recognizedText):
            let mlResult = getBestClassificationResult()
            if let mlClassification = mlResult {
                handleMLResult(mlClassification: mlClassification, recognizedText: recognizedText)
            } else {
                let feedbackMessage = "Recognition error: The model didn't provide a confident classification."
                self.lastResult = PronunciationResult(score: 0, feedback: feedbackMessage, isCorrect: false, recognizedText: recognizedText)
            }
        case .noSpeech:
            self.lastResult = PronunciationResult(score: 0, feedback: "We couldn't hear anything. Please try again.", isCorrect: false, recognizedText: "")
        case .error(let message):
            self.lastResult = PronunciationResult(score: 0, feedback: "Error: \(message)", isCorrect: false, recognizedText: "")
        }
        
        // Reset state
        self.state = .idle
        self.isRecordingButtonEnabled = true
        
        // After scoring, automatically move to the next sentence if correct
        if lastResult?.isCorrect == true {
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.nextSentence()
             }
        }
    }
    
    private func getBestClassificationResult() -> String? {
        // Logic to find the most frequent classification result...
        guard !classificationResults.isEmpty else { return nil }
        let frequency = classificationResults.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    private func handleMLResult(mlClassification: String, recognizedText: String) {
        // Your existing scoring logic...
        self.lastResult = PronunciationResult(score: 100, feedback: "Great job!", isCorrect: true, recognizedText: recognizedText)
    }
    
    // MARK: - SNResultsObserving Delegate Methods
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let classification = classificationResult.classifications.first else { return }
        
        if classification.confidence > 0.5 {
            classificationResults.append(classification.identifier)
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound classification failed: \(error)")
    }
}
