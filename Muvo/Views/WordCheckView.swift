//
//  WordCheckView.swift
//  Muvo
//
//  Created by Marcelinus Gerardo on 16/06/25.
//

import SwiftUI
import AVFoundation
import Speech
import UIKit
import CoreML
import SoundAnalysis

struct WordConfidence: Hashable {
    let word: String
    let confidence: Double
}

struct WordCheckView: View {
    // Audio, recording, transcription management
    @State private var exportFolderURL: URL = FileManager
        .default
        .temporaryDirectory
        .appendingPathComponent("word_exports", isDirectory: true)
    @State private var isRecording = false
    @State private var waveformSamples: [CGFloat] = []
    
    private var audioFileURL: URL { FileManager.default.temporaryDirectory.appendingPathComponent("recorded.m4a") }
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio format conversion
    @State private var transcription = ""
    @State private var wordConfidences: [WordConfidence] = []
    @State private var wordConfidenceDict: [String: String] = [:]
    
    let VGGISH_TARGET_SAMPLE_LENGTH: Int = 15600
    
    // Split sentences
    @State var sentence: String
    @State var translation: String
    private var splittedSentence: [String] {
        sentence
            .lowercased()
            .components(separatedBy: .whitespaces)
            .map { $0.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression) }
    }
    
    var body: some View {

            VStack(spacing: 30) {
                wordCheckContent()
                    .padding(.top, 40)
                
                infoTabView()
                
                Spacer()
                
                if isRecording {
                    SymmetricWaveformView(samples: waveformSamples) {
                        stopRecording()
                        isRecording = false
                    }
                    .padding(.bottom, 30)
                } else {
                    Button(action: {
                        startRecording()
                        isRecording = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 10)
                            
                            Image(systemName: "mic.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            .onAppear {
                requestPermissions()
                createExportFolderIfNeeded()
            }
            .onAppear {
                for word in splittedSentence {
                    wordConfidenceDict[word] = "-"
                }
            }
    }
    
    func wordCheckContent() -> some View {
        VStack(spacing: 2) {
            ForEach(chunked(splittedSentence, size: 3), id: \.self) { chunk in
                HStack(spacing: 2) {
                    ForEach(chunk, id: \.self) { word in
                        let isConfident = wordConfidenceDict[word] ?? "-"
                        Text(word)
                            .font(.custom("ApercuPro-Bold", size: 20))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(
                                isConfident == "y" ? Color.green.opacity(0.6) :
                                    isConfident == "n" ? Color.red.opacity(0.6) :
                                    Color.clear
                            )
                            .cornerRadius(6)
                    }
                }
            }
            
            Text(translation)
                .font(.custom("ApercuPro", size: 14))
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
    
    func infoTabView() -> some View {
        VStack {
            if wordConfidenceDict.values.allSatisfy({ $0 == "y" }) {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(Color.greenProgressDarker)
                    VStack(alignment: .leading) {
                        Text("Good job!")
                            .font(.custom("ApercuPro-Bold", size: 16))
                            .foregroundColor(Color.greenProgressDarker)
                        Text("Semuanya udah bagus. Yuk lanjutin latihan lain.")
                            .font(.custom("ApercuPro", size: 12))
                    }
                    Spacer()
                }
                .padding(8)
                .frame(minWidth: 320, maxWidth: 320)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
            } else {
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Tips biar bagus!")
                            .font(.custom("ApercuPro-Bold", size: 16))
                            .foregroundColor(.blue)
                        Text("Coba ngomong perlahan dengan jelas di tempat yang gak rame deh.")
                            .font(.custom("ApercuPro", size: 12))
                    }
                    Spacer()
                }
                .padding(8)
                .frame(minWidth: 320, maxWidth: 320)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if wordConfidenceDict.values.contains("n") {
                HStack(alignment: .top) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(.deepYellow)
                    VStack(alignment: .leading) {
                        Text("Coba ulang kata yang masih merah")
                            .font(.custom("ApercuPro-Bold", size: 16))
                            .foregroundColor(.deepYellow)
                        Text("Kamu bisa langsung coba ucapin kata yang masih merah loh.")
                            .font(.custom("ApercuPro", size: 12))
                    }
                    Spacer()
                }
                .padding(8)
                .frame(minWidth: 320, maxWidth: 320)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack {
                Spacer()
                Button("Reset") {
                    wordConfidences.removeAll()
                    for key in wordConfidenceDict.keys {
                        wordConfidenceDict[key] = "-"
                    }
                }
                .foregroundColor(.red)
                .font(.subheadline)
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
    }
    
    func startRecording() {
        clearExportFolder()
        waveformSamples.removeAll()
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .default)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        let audioFileRef: AVAudioFile?
        
        do {
            audioFileRef = try AVAudioFile(forWriting: audioFileURL, settings: inputFormat.settings)
        } catch {
            print("Error: Cannot create AVAudioFile -- \(error)")
            return
        }
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            try? audioFileRef?.write(from: buffer)
            self.processBuffer(buffer)

            let channelData = buffer.floatChannelData?[0]
            let frameLength = Int(buffer.frameLength)
            if let channelData = channelData {
                var rms: Float = 0.0
                for i in 0..<frameLength {
                    rms += pow(channelData[i], 2)
                }
                rms = sqrt(rms / Float(frameLength))
                
                let normalized = min(max(CGFloat(rms) * 20, 0), 1)
                
                DispatchQueue.main.async {
                    waveformSamples.append(normalized)
                    if waveformSamples.count > 100 {
                        waveformSamples.removeFirst()
                    }
                }
            }
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        transcribeAndCrop(audioURL: audioFileURL)
        print(wordConfidenceDict)
    }
    
    
    func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard buffer.frameLength > 0 else {
            print("Error: processBuffer received an empty buffer or buffer with zero frameLength.")
            return
        }
        
        var audioSamples = [Float](repeating: 0.0, count: VGGISH_TARGET_SAMPLE_LENGTH)
        let channelData = buffer.floatChannelData![0]
        let samplesToCopy = min(Int(buffer.frameLength), VGGISH_TARGET_SAMPLE_LENGTH)
        
        for i in 0..<samplesToCopy {
            audioSamples[i] = channelData[i]
        }
        
        guard let mlArray = try? MLMultiArray(shape: [NSNumber(value: VGGISH_TARGET_SAMPLE_LENGTH)], dataType: .float32) else {
            print("Error: Cannot create MLMultiArray with target length \(VGGISH_TARGET_SAMPLE_LENGTH)")
            return
        }
        
        for i in 0..<VGGISH_TARGET_SAMPLE_LENGTH {
            mlArray[i] = NSNumber(value: audioSamples[i])
        }
        
        do {
            var predictedLabel = ""
            var confidence = 0.0
            
            if (sentence == "I have a reservation under my name.") {
                let model = try H1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                predictedLabel = output.target
                confidence = output.targetProbability[predictedLabel] ?? 0.0
            } else if (sentence == "My luggage is missing.") {
                let model = try A1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                predictedLabel = output.target
                confidence = output.targetProbability[predictedLabel] ?? 0.0
            } else {
                let model = try BE7_3_1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                predictedLabel = output.target
                confidence = output.targetProbability[predictedLabel] ?? 0.0
            }
            
            print("processBuffer Prediction: Label '\(predictedLabel)', Confidence: \(String(format: "%.2f", confidence))")
        } catch {
            print("Error: Cannot connect to model in processBuffer -- \(error)")
        }
    }
    
    func evaluateWithBE7Model(audioURL: URL, targetText: String, completion: @escaping (Double) -> Void) {
        let asset = AVAsset(url: audioURL)
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            print("Error: Cannot create reader for \(audioURL.lastPathComponent) -- \(error)")
            completion(0.0)
            return
        }
        
        guard let track = asset.tracks(withMediaType: .audio).first else {
            print("Error: Audio track not found in \(audioURL.lastPathComponent)")
            completion(0.0)
            return
        }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsNonInterleaved: false,
        ]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        
        var rawSamples: [Float] = []
        if reader.startReading() {
            while reader.status == .reading {
                if let sampleBuffer = output.copyNextSampleBuffer(),
                   let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                    let length = CMBlockBufferGetDataLength(blockBuffer)
                    let numSamplesInBuffer = length / MemoryLayout<Float>.size
                    var data = [Float](repeating: 0, count: numSamplesInBuffer)
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: &data)
                    rawSamples.append(contentsOf: data)
                } else if reader.status == .failed {
                    print("Error: AVAssetReader failed while reading \(audioURL.lastPathComponent): \(reader.error?.localizedDescription ?? "Unknown error")")
                    completion(0.0)
                    return
                } else if reader.status == .completed {
                    break
                }
            }
        } else {
            print("Error: AVAssetReader could not start reading for \(audioURL.lastPathComponent): \(reader.error?.localizedDescription ?? "Unknown error")")
            completion(0.0)
            return
        }
        
        if rawSamples.isEmpty {
            print("Warning: No audio samples read from \(audioURL.lastPathComponent). Duration: \(asset.duration.seconds)s. Skipping evaluation.")
            completion(0.0)
            return
        }
        
        var finalSamples = [Float](repeating: 0.0, count: VGGISH_TARGET_SAMPLE_LENGTH)
        
        if rawSamples.count >= VGGISH_TARGET_SAMPLE_LENGTH {
            for i in 0..<VGGISH_TARGET_SAMPLE_LENGTH {
                finalSamples[i] = rawSamples[i]
            }
            print("Truncated/used first \(VGGISH_TARGET_SAMPLE_LENGTH) from \(rawSamples.count) samples for '\(targetText)' (\(audioURL.lastPathComponent))")
        } else {
            for i in 0..<rawSamples.count {
                finalSamples[i] = rawSamples[i]
            }
            print("Padded \(VGGISH_TARGET_SAMPLE_LENGTH - rawSamples.count) zeros to \(rawSamples.count) samples for '\(targetText)' (\(audioURL.lastPathComponent))")
        }
        
        guard let mlArray = try? MLMultiArray(shape: [NSNumber(value: VGGISH_TARGET_SAMPLE_LENGTH)], dataType: .float32) else {
            print("Error: Cannot create MLMultiArray of target length \(VGGISH_TARGET_SAMPLE_LENGTH) for '\(targetText)'")
            completion(0.0)
            return
        }
        
        for i in 0..<VGGISH_TARGET_SAMPLE_LENGTH {
            mlArray[i] = NSNumber(value: finalSamples[i])
        }
        
        do {
            var probs: [String:Double]
            let targetLower = targetText.lowercased()
            
            if (sentence == "I have a reservation under my name.") {
                let model = try H1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                probs = output.targetProbability
            } else if (sentence == "My luggage is missing.") {
                let model = try A1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                probs = output.targetProbability
            } else {
                let model = try BE7_3_1(configuration: MLModelConfiguration())
                let output = try model.prediction(audioSamples: mlArray)
                probs = output.targetProbability
            }
            
            if let conf = probs[targetLower] {
                completion(conf)
            } else {
                print("⚠️ Kata '\(targetText)' (normalized: '\(targetLower)') tidak ditemukan di targetProbability model. File: \(audioURL.lastPathComponent)")
                print("   Label yang tersedia di model: \(probs.keys.sorted().joined(separator: ", "))")
                completion(0.0)
            }
        } catch {
            print("Error: Failed to evaluate model for '\(targetText)' (\(audioURL.lastPathComponent)) -- \(error)")
            completion(0.0)
        }
    }
    
    // ===================================== Utils
    
    func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    func createExportFolderIfNeeded() {
        if !FileManager.default.fileExists(atPath: exportFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: exportFolderURL, withIntermediateDirectories: true)
                print("Folder export dibuat di: \(exportFolderURL.path)")
            } catch {
                print("Gagal membuat folder export: \(error)")
            }
        }
    }
    
    func openCroppedAudioFiles() {
        do {
            let audioFiles = try FileManager.default.contentsOfDirectory(at: exportFolderURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "m4a" }
            
            guard !audioFiles.isEmpty else {
                print("File not found.")
                return
            }
            
            let controller = UIActivityViewController(activityItems: audioFiles, applicationActivities: nil)
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(controller, animated: true)
            }
        } catch {
            print("Error: Cannot list files in export folder -- \(error)")
        }
    }
    
    func transcribeAndCrop(audioURL: URL) {
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        
        speechRecognizer.recognitionTask(with: request) { result, error in
            guard let result = result, result.isFinal else { return }
            
            DispatchQueue.main.async {
                transcription = result.bestTranscription.formattedString
            }
            
            let segments = result.bestTranscription.segments
            cropAudioPerWord(audioURL: audioURL, segments: segments)
        }
    }
    
    func cropAudioPerWord(audioURL: URL, segments: [SFTranscriptionSegment]) {
        wordConfidences.removeAll()
        
        // Digunakan untuk mapping ke label model
        let allowedWords = ["a", "and", "boarding", "breakfast", "check", "counter",
                            "flight", "have", "here", "i", "id", "immigration", "in",
                            "included", "is", "like", "lost", "luggage", "missed", "missing",
                            "my", "name", "need", "non", "pass", "passport", "please", "problem",
                            "reservation", "room", "smoking", "the", "there", "ticket", "to",
                            "under", "where", "with"]
        
        for (index, segment) in segments.enumerated() {
            let word = segment.substring
            let normalized = word
                .lowercased()
                .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
            
            print("ini \(normalized)")
            guard allowedWords.contains(normalized) else {
                print("Skip '\(normalized)': Invalid label")
                continue
            }
            
            let start = segment.timestamp
            let end = (index + 1 < segments.count) ? segments[index + 1].timestamp : start + 0.5
            let duration = end - start
            let sanitizedWord = normalized.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
            let outputURL = exportFolderURL.appendingPathComponent("word_\(index)_\(sanitizedWord).m4a")
            
            print("Cropping '\(sanitizedWord)': start \(start), duration \(duration)")
            
            cropAudio(inputURL: audioURL, startTime: start, duration: duration, outputURL: outputURL) { success in
                if success {
                    print("Audio file saved: \(outputURL.lastPathComponent)")
                    evaluateWithBE7Model(audioURL: outputURL, targetText: normalized) { confidence in
                        // Atur hasil prediksi
                        DispatchQueue.main.async {
                            let confidenceFlag = confidence > 0.5 ? "y" : "n"
                            if (wordConfidenceDict[normalized] == "n" || wordConfidenceDict[normalized] == "-") {
                                wordConfidenceDict[normalized] = confidenceFlag
                            }
                        }
                        
                        print(word + " : " + String(confidence))
                    }
                } else {
                    print("Failed to save \(sanitizedWord)")
                }
            }
        }
    }
    
    func cropAudio(inputURL: URL, startTime: Double, duration: Double, outputURL: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVAsset(url: inputURL)
        let audioDuration = asset.duration.seconds
        let safeStart = min(startTime, audioDuration)
        let safeDuration = min(duration, audioDuration - safeStart)
        
        guard safeDuration > 0 else {
            print("Skip: Invalid duration (\(safeDuration)) at start \(safeStart)")
            completion(false)
            return
        }
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
                print("Old audio file deleted: \(outputURL.lastPathComponent)")
            } catch {
                print("Error: Cannot delete old audio file: \(error)")
            }
        }
        
        guard let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session")
            completion(false)
            return
        }
        
        export.outputURL = outputURL
        export.outputFileType = .m4a
        export.timeRange = CMTimeRange(start: CMTime(seconds: safeStart, preferredTimescale: 600),
                                       duration: CMTime(seconds: safeDuration, preferredTimescale: 600))
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                if export.status == .completed {
                    completion(true)
                } else {
                    print("Export failed with status: \(export.status), error: \(export.error?.localizedDescription ?? "unknown error")")
                    completion(false)
                }
            }
        }
    }
    
    func clearExportFolder() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: exportFolderURL, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "m4a" {
                try FileManager.default.removeItem(at: file)
            }
            print("Audio files cleared.")
        } catch {
            print("Error: Cannot clear export folder -- \(error)")
        }
    }
}

#Preview {
    WordCheckView(
        sentence: "Hello World hallaware turnitin facebook and linkedin",
        translation: "Hello World hallaware turnitin facebook and linkedin"
    )
}
