//
//  MainCardVirw.swift
//  Muvo
//
//  Created by Rieno on 17/06/25.
//

import SwiftUI

struct MainCardView: View {
    let sentence: PracticeSentence
    @ObservedObject var viewModel: PronunciationViewModel // <-- ViewModel passed in

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

                HStack {
                    Text(sentence.category.rawValue)
                        .font(.custom("ApercuPro", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
//                        .background(
//                            Capsule().fill(sentence.category == .airport ? Color.blue : Color.green)
//                        )
                    Spacer()
                }
                .padding(.bottom, 8)

                Text("Yuk, intip kalimatnya!")
                    .font(.custom("ApercuPro", size: 20))
                Text("Tap speaker buat denger cara bacanya.")
                    .font(.custom("ApercuPro", size: 14))
                    .padding(.bottom, 20)

                HStack(alignment: .center, spacing: 16) {
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
                        Text(sentence.indonesian)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .glassmorphismCard()

                Spacer()
            }.padding(.top, 100)
        }
    }
}
