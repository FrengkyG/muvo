//
//  TopicCardView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct TopicCardView: View {
    let title: String
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center) {
                Text(title)
                    .font(.custom("ApercuPro-Bold", size: 36))
                    .foregroundColor(.primColor)
                    .padding(.top, 17)
                
                Spacer(minLength: 1)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white80)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    HomeView()
}
