//
//  CardBannerView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct CardBannerView: View {
    @State private var selectedTopik = "Semua"
    @State private var showDropdown = false
    
    @State private var progress: Double = 0.3
    let topikList = ["Semua", "Hotel", "Bandara"]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text ("Progress Belajar")
                    .font(.custom("ApercuPro-Bold", size: 20))
                Spacer()
            }.padding(.bottom, 2)
            
            Text("Kamu berhasil mempelajari ")
                .font(.custom("ApercuPro", size: 14))
            
            + Text("5")
                .font(.custom("ApercuPro-Bold", size: 14))
                .foregroundColor(.primColor)
            
            + Text(" kalimat")
                .font(.custom("ApercuPro", size: 14))
            
            
            HStack {
                ZStack(alignment: .leading) {
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.grayProgressColor ?? Color.gray.opacity(0.3))
                            .frame(height: 16)
                        
                        Rectangle()
                            .fill(Color.greenProgressColor ?? Color.green)
                            .frame(width: geometry.size.width * progress, height: 16)
                            .cornerRadius(progress == 1 ? 20 : 10)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                    
                    .frame(height: 16)
                }
                
                
                Text("\(progress*100, specifier: "%.0f")%")
                    .font(.custom("ApercuPro-Bold", size: 14))
                    .foregroundColor(.primColor)
            }
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.bottom, 24)
    }
}

#Preview {
    HomeView()
}

