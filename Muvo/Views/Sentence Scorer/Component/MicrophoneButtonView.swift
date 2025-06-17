//
//  MicrophoneButtonView.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

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
