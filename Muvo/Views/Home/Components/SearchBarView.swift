//
//  SearchBarView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.grayIcon)
            
            TextField("Tulis kata yang mau kamu pelajari...", text: $searchText)
                .font(.custom("ApercuPro", size: 14))
                .foregroundColor(.grayText)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 8)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.bottom, 12)
    }
}

#Preview {
    HomeView()
}
