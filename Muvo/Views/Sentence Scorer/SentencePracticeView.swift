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
import Accelerate

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

                        MainCardView(sentence: viewModel.currentSentence)
                        
                        Text(getInstructionText())
                            .font(.custom("ApercuPro", size: 16))

                        if viewModel.state == .recording {
                            SymmetricWaveformView(samples: viewModel.waveformSamples) {
                                viewModel.handleRecordingAction()
                            }
                        } else {
                            MicrophoneButtonView(viewModel: viewModel)
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
        .sheet(isPresented: .constant(viewModel.state == .result)) {
            if let result = viewModel.lastResult {
                SentenceResultView(
                    result: result,
                    viewModel: viewModel,
                    failureCount: viewModel.currentSentenceFailureCount
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .cornerRadius(12)
                .foregroundColor(Color("light-blue"))
            }
        }
        .navigationBarBackButtonHidden(true)
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


struct SentencePracticeView_Previews: PreviewProvider {
    static var previews: some View {
        SentencePracticeView()
    }
}
