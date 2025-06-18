//
//  TopBar View.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

struct TopBarView: View {
    @Environment(\.dismiss) var dismiss
    let progress: Int
    let total: Int

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
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
                        Capsule().foregroundColor(Color.grayProgressLighter)
                        Capsule()
                            .frame(width: geometry.size.width * (total > 0 ? CGFloat(progress) / CGFloat(total) : 0))
                            .foregroundColor(.greenProgressDarker)
                    }
                }
                .frame(height: 12)

                Group {
                    Text("\(progress)")
                        .font(.custom("ApercuPro-Bold", size: 20))
                        .foregroundColor(.primColor)
                    +
                    Text("/\(total)")
                        .font(.custom("ApercuPro", size: 16))
                        .foregroundColor(.black)
                }
                
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

#Preview {
    SentencePracticeView()
}
