//
//  SentenceResultView.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

// Renamed to PronunciationResultView for consistency
struct SentenceResultView: View {
    @ObservedObject var viewModel: PronunciationViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var navigateToWordCheck: Bool
    
    let failureCount: Int
    let result: PronunciationResult

    var body: some View {
        NavigationStack {
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
                            
                            switch result.accuracy {
                            case .perfect:
                                Image("correctMascot")
                                    .resizable()
                                    .scaledToFit()
                            case .almost:
                                Image("bothMascot(orange)")
                                    .resizable()
                                    .scaledToFit()
                            case .tryAgain:
                                Image("wrongMascot")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(height: geo.size.height * 0.3) // Control mascot size
                        
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(getStatusColor())
                                    .frame(width:geo.size.width * 0.075, height: geo.size.height * 0.075) // Control mascot size
                                Image(systemName: getStatusIcon())
                                    .frame(width:geo.size.width * 0.025, height: geo.size.height * 0.025)  // Control mascot size
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment:.leading, spacing: 4 ){
                                Text(getResultTitle())
                                    .font(.custom("Apercu-Bold", size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(getStatusColor())
                                Text(getFeedbackMessage())
                                    .font(.custom("Apercu-Pro", size: 13))
                                    .foregroundColor(.black.opacity(1))
                                    .multilineTextAlignment(.leading)
                                                               }
                        }.padding(.horizontal, 24)
                        
                    }
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                    .padding(.bottom, 24)
                // Bottom section with buttons
                VStack(spacing: 16) {
//                    if !result.recognizedText.isEmpty {
//                        //                        VStack(spacing: 8) {
//                        //                            Text("Yang kami tangkap:")
//                        //                                .font(.subheadline)
//                        //                                .foregroundColor(.black.opacity(0.6))
//                        //
//                        //                            Text("\"\(result.recognizedText)\"")
//                        //                                .font(.title3)
//                        //                                .foregroundColor(.black.opacity(0.8))
//                        //                                .fontWeight(.semibold)
//                        //                                .multilineTextAlignment(.center)
//                        //                                .padding(.horizontal, 20)
//                        //                        }
//                        //                        .padding(.top, 20)
//                    }
                    
                    actionButtons
                        .padding(.bottom, 30)
                }
                .padding(.horizontal, 30)
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
                        Button(action: {
                            dismiss()
                            viewModel.tryAgain()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToWordCheck = true
                            }
                        }) {
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
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack{if result.accuracy == .perfect {
                Button("Lanjut!", action: { viewModel.nextSentence() })
                    .modifier(PrimaryButtonModifier())
            } else if result.accuracy == .tryAgain && failureCount >= 3 {
                Button("Lanjut dulu deh~", action: { viewModel.skipToNext() })
                    .modifier(PrimaryButtonModifier())
            } else {
                Button("Analisa per Kata", action: { viewModel.showWordAnalysis() })
                    .modifier(SecondaryButtonModifier())
                Button("Coba lagi", action: { viewModel.tryAgain() })
                    .modifier(PrimaryButtonModifier())
            }
            }
            Text("Karena dicek otomatis, hasilnya bisa aja ngga selalu akurat.")
                .font(.custom("Apercu-Pro", size: 11))
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
        }
    }
    
    // MARK: - View Helpers
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
            return "Pengucapanmu udah sesuai nih! Kalo masih ngga yakin, nanti coba lagi aja~"
        case .almost:
            return "Mungkin ada bagian yang belum jelas, atau kami belum nangkep."
        case .tryAgain:
            return "Masih belum pas pengucapannya. Mau ulang dari awal atau latihan per kata?"
        }
    }
    
    private func getBackgroundColor() -> Color {
        // This function is no longer used for the main background but can be kept for other elements if needed.
        switch result.accuracy {
        case .perfect: return Color(red: 240/255, green: 248/255, blue: 255/255) // Light blue
        case .almost: return Color(red: 255/255, green: 248/255, blue: 240/255) // Light orange
        case .tryAgain: return Color(red: 248/255, green: 248/255, blue: 248/255) // Light gray
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

#Preview {
    // Using a ScrollView to display all result variations for easy testing.
    ScrollView {
        VStack(spacing: 20) {
            // --- PERFECT ---
            SentenceResultView(
                result: .init(
                    accuracy: .perfect,
                    recognizedText: "My luggage is missing.",
                    score: 100
                ),
                viewModel: PronunciationViewModel(),
                failureCount: 0
            )
            .frame(height: 600) // Give it a fixed height for preview layout
            
            // --- ALMOST ---
            SentenceResultView(
                result: .init(
                    accuracy: .almost,
                    recognizedText: "My luggage is messing.",
                    score: 50
                ),
                viewModel: PronunciationViewModel(),
                failureCount: 1
            )
            .frame(height: 600)
            
            // --- TRY AGAIN (First Try) ---
            SentenceResultView(
                result: .init(
                    accuracy: .tryAgain,
                    recognizedText: "My log is missing.",
                    score: 0
                ),
                viewModel: PronunciationViewModel(),
                failureCount: 1
            )
            .frame(height: 600)
            
            // --- TRY AGAIN (3+ Failures) ---
            SentenceResultView(
                result: .init(
                    accuracy: .tryAgain,
                    recognizedText: "My luggage missing.",
                    score: 0
                ),
                viewModel: PronunciationViewModel(),
                failureCount: 3
            )
            .frame(height: 600)
        }
    }
}
