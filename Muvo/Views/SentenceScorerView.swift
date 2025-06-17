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

struct PronunciationPracticeView: View {
    
    @StateObject private var viewModel = PronunciationViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 245/255, green: 246/255, blue: 248/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    TopBarView(
                        progress: viewModel.currentSentenceIndex,
                        total: viewModel.sentences.count
                    )
                    
                    VStack {
                        Spacer()
                        MainCardView(sentence: viewModel.currentSentence)
                        Spacer()
                        Text(getInstructionText())
                            .font(.headline)
                            .foregroundColor(.secondary)
                        MicrophoneButtonView(viewModel: viewModel)
                            .padding(.vertical, 30)
                        Spacer(minLength: 50)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.top)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                }
         
            }
            .edgesIgnoringSafeArea(.bottom)
            .padding(.horizontal, geometry.size.width * 0.07)
            .padding(.vertical)
        }
    }


private func getInstructionText() -> String {
    switch viewModel.state {
    case .idle:
        return "Pencet buat mulai ngomong"
    case .recording:
        return "Mendengarkan..."
    case .processing:
        return "Menganalisis..."
    }
}

struct SymmetricWaveformView: View {
    let samples: [CGFloat]
    let stopAction: () -> Void
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                let middleY = size.height / 2
                let barWidth: CGFloat = 3
                let spacing: CGFloat = 2
                let totalWidth = CGFloat(samples.count) * (barWidth + spacing)
                var xOffset = (size.width - totalWidth) / 2
                
                for sample in samples {
                    let barHeight = sample * (middleY * 0.8)
                    
                    // Draw top bar
                    var topPath = Path()
                    topPath.addRect(CGRect(x: xOffset, y: middleY - barHeight, width: barWidth, height: barHeight))
                    context.fill(topPath, with: .color(.blue.opacity(0.7)))
                    
                    // Draw bottom bar (mirrored)
                    var bottomPath = Path()
                    bottomPath.addRect(CGRect(x: xOffset, y: middleY, width: barWidth, height: barHeight))
                    context.fill(bottomPath, with: .color(.blue.opacity(0.7)))
                    
                    xOffset += barWidth + spacing
                }
            }
            
            Button(action: stopAction) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 10)
                    
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
}

struct PronunciationPracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PronunciationPracticeView()
    }
}
