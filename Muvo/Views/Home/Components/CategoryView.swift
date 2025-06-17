//
//  CategoryView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct CategoryView: View{
    var body: some View{
        VStack(alignment: .leading) {
            Text("Lagi pengen belajar apa hari ini?")
                .font(.custom("ApercuPro-Bold", size: 16))
                .padding(.bottom, 12)
            SearchBarView()
            HStack(spacing: 12) {
                TopicCardView(title: "Hotel", imageName: "iconHotel") {
                    print("Hotel tapped")
                    // TODO: Add Navigation
                }
                TopicCardView(title: "Bandara", imageName: "iconAirport") {
                    print("Bandara tapped")
                    // TODO: Add Navigation
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassmorphismCard()
        
    }
}

#Preview {
    HomeView()
}
