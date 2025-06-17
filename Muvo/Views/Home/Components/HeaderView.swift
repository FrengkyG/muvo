//
//  HeaderView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct HeaderView: View {
    @ObservedObject var userViewModel: UserViewModel
    private var isDaytime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
    
    
    var body: some View {
        HStack {
            Group {
                if isDaytime {
                    Image(systemName: "sun.min.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "moon.stars.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.primColor)
                }
            }
            
            
            VStack(alignment: .leading) {
                if isDaytime {
                    Text("Selamat Pagi 👋🏻")
                        .font(.custom("ApercuPro", size: 14))
                } else {
                    Text("Selamat Malam 👋🏻")
                        .font(.custom("ApercuPro", size: 14))
                }
                Text(userViewModel.username)
                    .font(.custom("ApercuPro-Medium", size: 20))
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
