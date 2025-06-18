//
//  AudioProcessing.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import Foundation
import AVFoundation
import Speech
import CoreML
import SoundAnalysis
import Accelerate

protocol AudioProcessingServiceDelegate: AnyObject {
    func didUpdateWaveform(samples: [CGFloat])
    func didFinishProcessing(result: SpeechRecognitionResult, classification: String?)
}

class AudioProcessingService: NSObject, SNResultsObserving {

    weak var delegate: AudioProcessingServiceDelegate?

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var airportModel: SNClassifySoundRequest?
    private var hotelModel: SNClassifySoundRequest?
    private var audioStreamAnalyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "AudioAnalysisQueue")
    
    private var classificationResults: [String] = []
    private let confidenceThreshold: Double = 0.3
    
    // Add recording state tracking
    private var isRecording = false
    private var recognitionTimer: Timer?

    override init() {
        super.init()
        loadMLModels()
        setupAudioInterruptionHandling()
    }
    
    deinit {
        cleanup()
        NotificationCenter.default.removeObserver(self)
    }

    func startRecording(for category: PracticeCategory) {
        // Prevent multiple simultaneous recordings
        guard !isRecording else {
            print("[WARNING] Already recording, ignoring start request.")
            return
        }
        
        // Check permissions first
        guard checkPermissions() else {
            delegate?.didFinishProcessing(result: .error("Permissions not granted"), classification: nil)
            return
        }
        
        classificationResults = []
        
        guard setupAudioSession() else {
            delegate?.didFinishProcessing(result: .error("Audio session setup failed"), classification: nil)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("[ERROR] Unable to create recognition request.")
            delegate?.didFinishProcessing(result: .error("Recognition request creation failed"), classification: nil)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true  // Changed to true for better debugging
        recognitionRequest.requiresOnDeviceRecognition = false
        recognitionRequest.taskHint = .dictation

        setupAudioStreamAnalyzer(for: category)
        setupRecognitionTask(with: recognitionRequest)
        
        if startAudioEngine(with: recognitionRequest) {
            isRecording = true
            // Start a timer to handle potential timeout
            startRecognitionTimer()
            print("[INFO] Recording started successfully.")
        } else {
            cleanup()
            delegate?.didFinishProcessing(result: .error("Audio engine failed to start"), classification: nil)
        }
    }

    func stopRecording() {
        guard isRecording else {
            print("[WARNING] Not currently recording, ignoring stop request.")
            return
        }
        
        // Cancel the timer
        recognitionTimer?.invalidate()
        recognitionTimer = nil
        
        isRecording = false
        print("[INFO] Stopping recording...")
        
        // Stop audio engine and remove tap
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End audio input for recognition (but don't cancel the task yet)
        recognitionRequest?.endAudio()
        
        // Let the recognition task complete naturally
        // Don't cancel it here - let it finish processing
        
        print("[INFO] Recording stopped, waiting for recognition to complete...")
    }
    
    private func cleanup() {
        isRecording = false
        
        // Cancel timer
        recognitionTimer?.invalidate()
        recognitionTimer = nil
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("[WARNING] Failed to cleanup audio session: \(error.localizedDescription)")
        }
    }
    
    private func performFinalCleanup() {
        // Clean up recognition task
        recognitionTask?.finish()
        recognitionTask = nil
        recognitionRequest = nil
        
        // Clean up audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("[INFO] Audio session deactivated after recognition completion.")
        } catch {
            print("[WARNING] Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    private func checkPermissions() -> Bool {
        // Check microphone permission
        let micPermission = AVAudioSession.sharedInstance().recordPermission
        guard micPermission == .granted else {
            print("[ERROR] Microphone permission not granted: \(micPermission)")
            return false
        }
        
        // Check speech recognition permission
        let speechPermission = SFSpeechRecognizer.authorizationStatus()
        guard speechPermission == .authorized else {
            print("[ERROR] Speech recognition permission not granted: \(speechPermission)")
            return false
        }
        
        // Check if speech recognizer is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("[ERROR] Speech recognizer not available")
            return false
        }
        
        return true
    }
    
    private func loadMLModels() {
        do {
            airportModel = try SNClassifySoundRequest(mlModel: soundclafAIR().model)
            hotelModel = try SNClassifySoundRequest(mlModel: soundclafHOT().model)
            print("[INFO] ML Models loaded successfully.")
        } catch {
            print("[ERROR-ML] Error loading ML Models: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() -> Bool {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("[INFO] Audio session setup complete.")
            return true
        } catch {
            print("[ERROR] Audio session setup failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func setupAudioInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("[INFO] Audio interruption began")
            if isRecording {
                stopRecording()
                delegate?.didFinishProcessing(result: .error("Audio interrupted"), classification: nil)
            }
        case .ended:
            print("[INFO] Audio interruption ended")
            // Don't automatically restart - let user initiate
        @unknown default:
            break
        }
    }
    
    private func setupAudioStreamAnalyzer(for category: PracticeCategory) {
        let modelRequest = (category == .airport) ? airportModel : hotelModel
        
        print("[DEBUG-ML] Setting up analyzer for category: \(category.rawValue)")

        guard let request = modelRequest else {
            print("[ERROR-ML] ML model for category \(category.rawValue) is not available.")
            return
        }
        
        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioStreamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        do {
            try audioStreamAnalyzer?.add(request, withObserver: self)
            print("[DEBUG-ML] Sound analysis request added to stream analyzer.")
        } catch {
            print("[ERROR-ML] Failed to add classification request: \(error.localizedDescription)")
        }
    }

    private func setupRecognitionTask(with request: SFSpeechAudioBufferRecognitionRequest) {
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            print("[DEBUG-STT] Recognition task handler invoked.")
            
            // Cancel timer on any result
            self.recognitionTimer?.invalidate()
            self.recognitionTimer = nil

            let isFinal = result?.isFinal ?? false
            
            if let error = error {
                print("[ERROR-STT] Recognition task failed with error: \(error.localizedDescription)")
                
                // Handle specific error types
                let nsError = error as NSError
                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1101 {
                    print("[ERROR-STT] Audio input problem - likely microphone access issue")
                }
            }
            
            if isFinal {
                print("[DEBUG-STT] Recognition is final.")
            }
            
            // Show partial results for debugging
            if let result = result {
                print("[DEBUG-STT] Partial result: '\(result.bestTranscription.formattedString)' (isFinal: \(result.isFinal))")
            }
            
            if error != nil || isFinal {
                let recognizedText = result?.bestTranscription.formattedString ?? ""
                print("[DEBUG-STT] Final recognized text: '\(recognizedText)'")
                
                let bestClassification = self.getBestClassificationResult()
                
                // Clean up resources after recognition completes
                self.performFinalCleanup()
                
                DispatchQueue.main.async {
                    if let error = error {
                        self.delegate?.didFinishProcessing(result: .error(error.localizedDescription), classification: bestClassification)
                    } else if recognizedText.isEmpty {
                        self.delegate?.didFinishProcessing(result: .noSpeech, classification: bestClassification)
                    } else {
                        self.delegate?.didFinishProcessing(result: .success(recognizedText), classification: bestClassification)
                    }
                }
            }
        }
    }
    
    private func startRecognitionTimer() {
        recognitionTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            print("[WARNING] Recognition timeout - forcing completion")
            self?.handleRecognitionTimeout()
        }
    }
    
    private func handleRecognitionTimeout() {
        guard isRecording else { return }
        
        print("[INFO] Handling recognition timeout")
        
        // Force stop everything
        isRecording = false
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        performFinalCleanup()
        
        DispatchQueue.main.async {
            self.delegate?.didFinishProcessing(result: .noSpeech, classification: nil)
        }
    }
    
    private func startAudioEngine(with request: SFSpeechAudioBufferRecognitionRequest) -> Bool {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Validate format
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("[ERROR] Invalid recording format")
            return false
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            guard let self = self, self.isRecording else { return }
            
            request.append(buffer)
            self.analysisQueue.async {
                self.audioStreamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            self.updateWaveform(from: buffer)
        }

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("[INFO] Audio engine started successfully.")
            return true
        } catch {
            print("[ERROR] Audio engine start failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func updateWaveform(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let dataPointer = UnsafeBufferPointer(start: channelData.pointee, count: Int(buffer.frameLength))
        let rms = vDSP.rootMeanSquare(dataPointer)
        let normalizedValue = min(max(CGFloat(rms) * 150.0, 0.0), 1.0)
        
        DispatchQueue.main.async {
            self.delegate?.didUpdateWaveform(samples: [normalizedValue])
        }
    }
    
    private func getBestClassificationResult() -> String? {
        print("[DEBUG-ML] Final classifications being tallied: \(classificationResults)")

        guard !classificationResults.isEmpty else {
            print("[DEBUG-ML] No classifications passed the confidence threshold.")
            return nil
        }
        let frequency = classificationResults.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        
        print("[DEBUG-ML] Frequency of classifications: \(frequency)")

        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - SNResultsObserving Delegate Methods
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        if let topClassification = classificationResult.classifications.first {
            print("[DEBUG-ML] Raw Classification: '\(topClassification.identifier)' with confidence: \(String(format: "%.2f", topClassification.confidence))")
        }

        guard let classification = classificationResult.classifications.first,
              classification.confidence > confidenceThreshold else { return }
        
        classificationResults.append(classification.identifier)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("[ERROR-ML] Sound classification request failed: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("[INFO-ML] Sound classification analysis completed for the stream.")
    }
}
