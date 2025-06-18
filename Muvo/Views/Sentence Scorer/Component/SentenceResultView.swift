//
//  SentenceResultView.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

struct SentenceResultView: View {
    @ObservedObject var viewModel: PronunciationViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var navigateToWordCheck: Bool
    
 
    let failureCount: Int
    let result: PronunciationResult

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // MARK: - Main Content
                VStack(spacing: 20) {
                    // Mascot Image
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
                    .frame(height: geo.size.height * 0.4) // Control mascot size
                    
                    // Feedback Message
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(getStatusColor())
                                .frame(width: geo.size.width * 0.075, height: geo.size.height * 0.075)
                            Image(systemName: getStatusIcon())
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.035, height: geo.size.height * 0.035)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getResultTitle())
                                .font(.custom("Apercu-Bold", size: 20))
                                .foregroundColor(getStatusColor())
                            Text(getFeedbackMessage())
                                .font(.custom("Apercu-Pro", size: 13))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()
                    .padding(.bottom, 24)
            
                VStack(spacing: 16) {
                    actionButtons
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(Color("light-blue")) 
                     .cornerRadius(48)
                     .ignoresSafeArea()
                     .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12){
            if result.accuracy == .perfect {
                Button(action: {
                    dismiss()
                    viewModel.nextSentence()
                }) {
                    Text("Lanjut!")
                        .modifier(PrimaryButtonModifier())
                }
            } else if viewModel.shouldShowSkipButton {
                Button(action: {
                    dismiss()
                    viewModel.skipToNext()
                }) {
                    Text("Lanjut dulu deh~")
                        .modifier(PrimaryButtonModifier())
                }
            } else {
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToWordCheck = true
                        }
                    }) {
                        Text("Analisa per Kata")
                            .modifier(SecondaryButtonModifier())
                    }
                    
                    Button(action: {
                        dismiss()
                        viewModel.tryAgain()
                    }) {
                        Text("Coba lagi")
                            .modifier(PrimaryButtonModifier())
                    }
                }
            }
            
            Text("Karena dicek otomatis, hasilnya bisa aja ngga selalu akurat.")
                .font(.custom("Apercu-Pro", size: 11))
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
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
            return "Pengucapanmu udah sesuai nih! Kalo masih ngga yakin, nanti coba lagi aja~"
        case .almost:
            return "Mungkin ada bagian yang belum jelas, atau kami belum nangkep."
        case .tryAgain:
            return "Masih belum pas pengucapannya. Mau ulang dari awal atau latihan per kata?"
        }
    }
    
    private func getStatusIcon() -> String {
        switch result.accuracy {
        case .perfect: return "checkmark"
        default: return "xmark"
        }
    }
    
    private func getStatusColor() -> Color {
        switch result.accuracy {
        case .perfect: return .green
        case .almost: return .orange
        case .tryAgain: return .red
        }
    }
}
