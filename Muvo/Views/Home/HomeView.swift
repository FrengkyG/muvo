//
//  MainAppView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                QuarterCircleView()
                    .frame(height: geometry.size.height * 0.5)
                
                ZStack(alignment: .center) {
                    Image("greenMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geometry.size.width * 0.75)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .rotationEffect(.degrees(315))
                        .offset(x: -50)
                    
                    VStack {
                        HeaderView(userViewModel: userViewModel)
                        CardBannerView()
                        WarmUpview(geometry: geometry)
                        CategoryView()
                    }.padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}



