//
//  WaveformView.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI
import SwiftUI
import AVFoundation
import Speech
import CoreML
import SoundAnalysis
import Accelerate

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
                    let barHeight = sample * middleY
                    var topPath = Path()
                    topPath.addRect(CGRect(x: xOffset, y: middleY - barHeight, width: barWidth, height: barHeight))
                    context.fill(topPath, with: .color(.blue.opacity(0.7)))

                    var bottomPath = Path()
                    bottomPath.addRect(CGRect(x: xOffset, y: middleY, width: barWidth, height: barHeight))
                    context.fill(bottomPath, with: .color(.blue.opacity(0.7)))

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
