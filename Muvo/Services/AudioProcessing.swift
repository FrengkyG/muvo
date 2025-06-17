//
//  AudioProcessing.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

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

    override init() {
        super.init()
        loadMLModels()
    }

    func startRecording(for category: PracticeCategory) {
        classificationResults = []
        
        guard setupAudioSession() else { return }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Error: Unable to create recognition request.")
            return
        }
        recognitionRequest.shouldReportPartialResults = false

        setupAudioStreamAnalyzer(for: category)
        setupRecognitionTask(with: recognitionRequest)
        startAudioEngine(with: recognitionRequest)
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
    }
    
    private func loadMLModels() {
        do {
            airportModel = try SNClassifySoundRequest(mlModel: soundclafAIR().model)
            hotelModel = try SNClassifySoundRequest(mlModel: soundclafHOT().model)
        } catch {
            print("Error loading ML Models: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            return true
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func setupAudioStreamAnalyzer(for category: PracticeCategory) {
        let modelRequest = (category == .airport) ? airportModel : hotelModel
        guard let request = modelRequest else {
            print("ML model for category \(category.rawValue) is not available.")
            return
        }
        
        audioStreamAnalyzer = SNAudioStreamAnalyzer(format: audioEngine.inputNode.outputFormat(forBus: 0))
        do {
            try audioStreamAnalyzer?.add(request, withObserver: self)
        } catch {
            print("Failed to add classification request: \(error.localizedDescription)")
        }
    }

    private func setupRecognitionTask(with request: SFSpeechAudioBufferRecognitionRequest) {
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            let isFinal = result?.isFinal ?? false
            
            if error != nil || isFinal {
                self.stopRecording()
                let recognizedText = result?.bestTranscription.formattedString ?? ""
                let bestClassification = self.getBestClassificationResult()
                
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
    
    private func startAudioEngine(with request: SFSpeechAudioBufferRecognitionRequest) {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            request.append(buffer)
            self.analysisQueue.async {
                self.audioStreamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            self.updateWaveform(from: buffer)
        }

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start failed: \(error.localizedDescription)")
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
        guard !classificationResults.isEmpty else { return nil }
        let frequency = classificationResults.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let classification = classificationResult.classifications.first,
              classification.confidence > confidenceThreshold else { return }
        
        classificationResults.append(classification.identifier)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound classification request failed: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("Sound classification analysis completed.")
    }
}
