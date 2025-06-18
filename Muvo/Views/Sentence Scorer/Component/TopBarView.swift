//
//  TopBar View.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

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
                        Capsule().foregroundColor(Color.gray.opacity(0.2))
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
