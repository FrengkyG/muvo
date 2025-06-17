//
//  SentenceResultView.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

struct SentenceResultView: View {
    let result: PronunciationResult
    @ObservedObject var viewModel: PronunciationViewModel
    let failureCount: Int

    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 16) {
                    ZStack {
                        switch result.accuracy {
                        case .perfect:
                            Image("correctMascot")
                        case .almost:
                            Image("bothMascot(orange)")
                        case .tryAgain:
                            Image("wrongMascot")
                        }}

                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(getStatusColor())
                                .frame(width: 24, height: 24)

                            Image(systemName: getStatusIcon())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Text(getResultTitle())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(getStatusColor())
                    }
                }

                Text(getFeedbackMessage())
                    .font(.body)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(getBackgroundColor())

            VStack(spacing: 16) {
                if !result.recognizedText.isEmpty {
                    VStack(spacing: 8) {
                        Text("Yang kami tangkap:")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))

                        Text(result.recognizedText)
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }

                VStack(spacing: 12) {
                    if result.accuracy == .perfect {
                        Button(action: { viewModel.nextSentence() }) {
                            Text("Lanjut!")
                                .modifier(PrimaryButtonModifier())
                        }
                    } else if result.accuracy == .tryAgain && failureCount >= 3 {
                        Button(action: { viewModel.skipToNext() }) {
                            Text("Lanjut dulu deh~")
                                .modifier(PrimaryButtonModifier())
                        }
                    } else {
                        Button(action: { viewModel.showWordAnalysis() }) {
                            Text("Analisa per Kata")
                                .modifier(SecondaryButtonModifier())
                        }
                        Button(action: { viewModel.tryAgain() }) {
                            Text("Coba lagi")
                                .modifier(PrimaryButtonModifier())
                        }
                    }

                    Text("Karena dicek otomatis, hasilnya bisa aja ngga selalu akurat.")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(20)
    }

    private func getResultTitle() -> String {
        switch result.accuracy {
        case .perfect: return "Mantap!"
        case .almost: return "Hampir!"
        case .tryAgain: return "Coba lagi!"
        }
    }

    private func getFeedbackMessage() -> String {
        switch result.accuracy {
        case .perfect:
            return "Pengucapanmu udah bagus. Tapi kalau mau latihan per kata, bisa juga kok~"
        case .almost:
            return "Mungkin ada bagian yang belum jelas, atau kami belum nangkep."
        case .tryAgain:
            return "Masih belum pas pengucapannya. Mau ulang dari awal atau latihan per kata?"
        }
    }

    private func getBackgroundColor() -> Color {
        switch result.accuracy {
        case .perfect: return Color(red: 240/255, green: 248/255, blue: 255/255)
        case .almost: return Color(red: 255/255, green: 248/255, blue: 240/255)
        case .tryAgain: return Color(red: 248/255, green: 248/255, blue: 248/255)
        }
    }

    private func getStatusIcon() -> String {
        return result.accuracy == .perfect ? "checkmark" : "xmark"
    }

    private func getStatusColor() -> Color {
        switch result.accuracy {
        case .perfect: return .green
        case .almost: return .orange
        case .tryAgain: return .red
        }
    }
}
