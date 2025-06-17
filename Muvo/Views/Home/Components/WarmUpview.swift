//
//  WarmUpview.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct WarmUpview: View {
    let geometry: GeometryProxy
    
    var body: some View {
        HStack{
            Image("imgBubbleChat")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.1)
                .offset(y: -60)
            
            VStack (alignment: .leading) {
                Text("Belajar")
                    .font(.custom("ApercuPro", size: 14))
                
                Text("Pemanasan dulu sebelum lancar ngobrol!")
                    .font(.custom("ApercuPro-Bold", size:20))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 12)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Semakin sering jawab, semakin lancar ngomongnya.")
                    .font(.custom("ApercuPro", size:12))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    // TODO: Add Action
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .frame(height: 8)
                            .foregroundColor(.white)
                        Text("Mulai")
                            .font(.custom("ApercuPro-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primColor)
                    .cornerRadius(24)
                }
                .padding(.top, 8)
            }
            .padding(22)
            .frame(width: geometry.size.width*0.5)
            .frame(maxHeight: .infinity)
            .glassmorphismCard()
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    HomeView()
}
