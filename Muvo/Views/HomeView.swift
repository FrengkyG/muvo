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
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                LargeRadiusShape(
                    topLeftRadius: 500,
                    topRightRadius: 0,
                    bottomLeftRadius: 0,
                    bottomRightRadius: 0
                )
                .fill(Color.blue)
                .ignoresSafeArea(edges: .bottom)
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

struct WarmUpview: View {
    let geometry: GeometryProxy
    
    var body: some View {
        HStack{
            Spacer()
            VStack (alignment: .leading) {
                Text("Belajar")
                    .font(.custom("ApercuPro", size: 14))
                Text("Pemanasan dulu sebelum lancar ngobrol!")
                    .font(.custom("ApercuPro-Bold", size:20))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 12)
                Text("Semakin sering jawab, semakin lancar ngomongnya.")
                    .font(.custom("ApercuPro", size:12))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
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
            .glassmorphismCard()
        }
        
        
    }
}

struct CategoryView: View{
    var body: some View{
        Rectangle()
            .frame(width: .infinity)
            .foregroundColor(.gray)
    }
}

struct LargeRadiusShape: Shape {
    var topLeftRadius: CGFloat
    var topRightRadius: CGFloat
    var bottomLeftRadius: CGFloat
    var bottomRightRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        // Start from top-left corner
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        
        // Top-left corner
        if topLeftRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: topLeftRadius, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
        } else {
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        // Top edge
        path.addLine(to: CGPoint(x: width - topRightRadius, y: 0))
        
        // Top-right corner
        if topRightRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: width, y: topRightRadius),
                control: CGPoint(x: width, y: 0)
            )
        } else {
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - bottomRightRadius))
        
        // Bottom-right corner
        if bottomRightRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: width - bottomRightRadius, y: height),
                control: CGPoint(x: width, y: height)
            )
        } else {
            path.addLine(to: CGPoint(x: width, y: height))
        }
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: height))
        
        // Bottom-left corner
        if bottomLeftRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: 0, y: height - bottomLeftRadius),
                control: CGPoint(x: 0, y: height)
            )
        } else {
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        
        // Close path
        path.closeSubpath()
        
        return path
    }
}
