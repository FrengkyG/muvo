//
//  SuccessPracticeView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 19/06/25.
//

import SwiftUI

struct SuccessPracticeView: View {
    @StateObject private var viewModel = PronunciationViewModel()
    @State private var navigateToHome = false
    
    var body: some View {
        VStack{
            TopBarView(
                progress: viewModel.currentSentenceIndex + 1,
                total: viewModel.sentences.count
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 1)
            
            Spacer()
            
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(radius: 6)
                    
                    ZStack {
                        Image("orangeMascot")
                            .resizable()
                            .frame(height: 280)
                            .position(x: 300, y: 50)
                            .rotationEffect(.degrees(-23))
                            .offset(
                                x: geometry.size.width * 0.45,
                                y: -geometry.size.height * -0.1
                            )
                            .clipped()
                        
                        
                        Image("greenPolos")
                            .resizable()
                            .frame(width: 220, height: 220)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            .position(x: 60, y: 300)
                            .offset(
                                x: geometry.size.width * -0.12,
                                y: geometry.size.height * -0.12
                            )
                            .clipped()
                        
                        Image("yellowPolosHi")
                            .resizable()
                            .frame(width: 208, height: 190)
                            .position(x: 180, y: 350)
                            .offset(
                                y: geometry.size.height * 0.22
                            )
                            .clipped()
                        
                        VStack {
                            Text("Yay! Kamu berhasil belajar 5 kalimat!")
                                .font(.custom("ApercuPro", size: 20))
                                .multilineTextAlignment(.center)
                            
                        }
                        .padding()
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .glassmorphismCard()
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            
            
            Button(action: {
                navigateToHome = true
            }) {
                Group {
                    Text("Kembali ke ")
                        .font(.custom("ApercuPro-Bold", size: 18))
                    +
                    Text("home")
                        .font(.custom("ApercuPro-BoldItalic", size: 18))
                }.foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primColor)
                    .cornerRadius(28)
                
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)

    }
}



#Preview {
    SuccessPracticeView()
}
