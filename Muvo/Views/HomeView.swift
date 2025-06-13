//
//  MainAppView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject var userViewModel = UserViewModel()
    @Environment(\.modelContext) private var context
    
    @Query var categories: [Category]
    @Query var questions: [Question]
    
    var body: some View {
        ZStack {
            VStack {
                HeaderView(userViewModel: userViewModel)
                Spacer()
                CardBannerView()
                Spacer()

            }
            .padding(.horizontal, 24)
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

struct HeaderView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 21, height: 21, alignment: .center)
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text("Selamat Pagi 👋🏻")
                    .font(.custom("ApercuPro", size: 14))
                Text(userViewModel.username)
                    .font(.custom("ApercuPro-Medium", size: 20))
            }
            Spacer()
            Rectangle()
                .frame(width: 36, height: 36, alignment: .center)
                .foregroundColor(.gray)
        }
    }
}

struct CardBannerView: View {
    var body: some View {
        Rectangle()
            .frame(width: .infinity, height: 110, alignment: .center)
            .foregroundColor(.gray)    }
}
