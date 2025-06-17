//
//  MainAppView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI
import SwiftData

struct Home2View: View {
    @StateObject var userViewModel = UserViewModel()
    @Environment(\.modelContext) private var context
    
    @Query var categories: [Category]
    @Query var questions: [Question]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
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
    }
    
    func progressCard(category: Category) -> some View {
        VStack(alignment: .leading) {
            Text(category.name)
                .font(.headline)
            ProgressView(value: category.completion) {
                Text("\(Int(category.completion * 100))% Done")
                    .font(.subheadline)
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
}
