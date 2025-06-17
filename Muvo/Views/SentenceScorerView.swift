//
//  PronunciationScorerView.swift
//  Muvo
//
//  Created by Rieno on 16/06/25.
//

import SwiftUI
import AVFoundation
import Speech
import CoreML
import SoundAnalysis

struct SentencePracticeView: View {
    @StateObject private var viewModel = PronunciationViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 245/255, green: 246/255, blue: 248/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    TopBarView(
                        progress: viewModel.currentSentenceIndex + 1,
                        total: viewModel.sentences.count
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 1)
                    
                    VStack {
                        Spacer()
                        
                        // Show different content based on state
                        if viewModel.state == .result {
                            // Show result modal when in result state
                            if let result = viewModel.lastResult {
                                PronunciationResultView(result: result, viewModel: viewModel)
                            }
                        } else {
                            // Show normal practice content when not in result state
                            MainCardView(sentence: viewModel.currentSentence)
                            Spacer()
                            Text(getInstructionText())
                                .font(.custom("ApercuPro", size: 16))
                            
                            if viewModel.state == .recording {
                                SymmetricWaveformView(samples: viewModel.waveformSamples) {
                                    viewModel.handleRecordingAction()
                                }
                            } else {
                                MicrophoneButtonView(viewModel: viewModel)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.top)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, geometry.size.width * 0.07)
                .padding(.vertical)
            }
        }
    }

    private func getInstructionText() -> String {
        switch viewModel.state {
        case .idle:
            return "Tekan mic untuk mulai berbicara"
        case .recording:
            return "Pencet lagi buat berhenti"
        case .processing:
            return "Menganalisis..."
        case .result:
            return ""
        }
    }
}

struct SymmetricWaveformView: View {
    let samples: [CGFloat]
    let stopAction: () -> Void
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                let middleY = size.height / 2
                let barWidth: CGFloat = 2
                let spacing: CGFloat = 1
                let totalWidth = CGFloat(samples.count) * (barWidth + spacing)
                var xOffset = (size.width - totalWidth) / 2
                
                for sample in samples {
                    let barHeight = sample * (middleY)
                    var topPath = Path()
                    topPath.addRect(CGRect(x: xOffset, y: middleY - barHeight, width: barWidth, height: barHeight))
                    context.fill(topPath, with: .color(.blue.opacity(0.7)))
                    
                    var bottomPath = Path()
                    bottomPath.addRect(CGRect(x: xOffset, y: middleY, width: barWidth, height: barHeight))
                    context.fill(bottomPath, with: .color(.red.opacity(0.7)))
                    
                    xOffset += barWidth + spacing
                }
            }
            
            Button(action: stopAction) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                        .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                    
                    Image(systemName: "square.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(height: 100)
    }
}

struct PronunciationResultView: View {
    let result: PronunciationResult
    @ObservedObject var viewModel: PronunciationViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Character illustration with stars
            VStack(spacing: 16) {
                ZStack {
                    // Character (using star as placeholder for your character)
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    // Expression lines around character
                    if getResultType() == .perfect {
                        ForEach(0..<3, id: \.self) { index in
                            Rectangle()
                                .frame(width: 3, height: 15)
                                .foregroundColor(.orange)
                                .rotationEffect(.degrees(Double(index * 30 - 30)))
                                .offset(x: 50, y: -20)
                        }
                    }
                }
                
                // Status indicator
                HStack(spacing: 8) {
                    Image(systemName: getStatusIcon())
                        .font(.title2)
                        .foregroundColor(getStatusColor())
                    
                    Text(getResultTitle())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(getStatusColor())
                }
            }
            
            // Feedback message
            Text(result.feedback)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // What we heard section
            if !result.recognizedText.isEmpty {
                VStack(spacing: 8) {
                    Text("Yang kami tangkap:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result.recognizedText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                if getResultType() != .perfect {
                    Button(action: {
                        viewModel.dismissResult()
                    }) {
                        Text("Analisa per Kata")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
                
                Button(action: {
                    viewModel.tryAgain()
                }) {
                    Text("Coba lagi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                
                if getResultType() != .tryAgain {
                    Text("Karena dicek otomatis, hasilnya bisa aja nggak selalu akurat.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    private func getResultType() -> ResultType {
        if result.score >= 90 {
            return .perfect
        } else if result.score >= 60 {
            return .hampir
        } else {
            return .tryAgain
        }
    }
    
    private func getResultTitle() -> String {
        switch getResultType() {
        case .perfect:
            return "Perfect!"
        case .hampir:
            return "Hampir!"
        case .tryAgain:
            return "Coba lagi!"
        }
    }
    
    private func getStatusIcon() -> String {
        switch getResultType() {
        case .perfect:
            return "checkmark.circle.fill"
        case .hampir:
            return "exclamationmark.triangle.fill"
        case .tryAgain:
            return "xmark.circle.fill"
        }
    }
    
    private func getStatusColor() -> Color {
        switch getResultType() {
        case .perfect:
            return .green
        case .hampir:
            return .orange
        case .tryAgain:
            return .red
        }
    }
}

enum ResultType {
    case perfect
    case hampir
    case tryAgain
}

struct TopBarView: View {
    let progress: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            HStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .foregroundColor(Color.gray.opacity(0.2))
                        
                        Capsule()
                            .frame(width: geometry.size.width * (total > 0 ? CGFloat(progress) / CGFloat(total) : 0))
                            .foregroundColor(.blue)
                    }
                }
                .frame(height: 12)
                
                Text("\(progress)/\(total)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.bottom, 8)
    }
}

struct MainCardView: View {
    let sentence: PracticeSentence
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("yellowintip")
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.8))
                    .foregroundColor(.yellow.opacity(0.5))
                    .position(x: geo.size.width / 1.8, y: geo.size.height * 0.4)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text("Yuk, intip kalimatnya!")
                    .font(.custom("Apercu-Bold", size: 20))
                    .bold(true)
                Text("Tap speaker buat denger cara bacanya.")
                    .font(.custom("ApercuPro", size: 14))
                    .padding(.bottom, 20)
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color(red: 255/255, green: 126/255, blue: 0/255))
                                    .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(sentence.english)
                            .font(.custom("ApercuPro-Bold", size: 20))
                            .bold()
                        Text(sentence.indonesian).font(.body).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .cornerRadius(16)
                
                Spacer()
            }.padding(.top, 100)
        }
    }
}

struct MicrophoneButtonView: View {
    @ObservedObject var viewModel: PronunciationViewModel
    
    var body: some View {
        Button(action: {
            viewModel.handleRecordingAction()
        }) {
            ZStack {
                Circle()
                    .fill(viewModel.state == .recording ? Color.red: Color.blue)
                    .frame(width: 80, height: 80)
                    .shadow(color: (viewModel.state == .recording ? Color.red : Color.blue).opacity(0.5), radius: 10, x: 0, y: 10)
                
                if viewModel.state == .recording {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .scaleEffect(viewModel.state == .recording ? 1.2 : 1.0)
                        .opacity(viewModel.state == .recording ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: viewModel.state)
                }
                
                Image(systemName: viewModel.state == .recording ? "stop.fill" : "mic.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .disabled(!viewModel.isRecordingButtonEnabled)
    }
}

// MARK: - Preview Provider
struct SentencePracticeViewView_Previews: PreviewProvider {
    static var previews: some View {
        SentencePracticeView()
    }
}
