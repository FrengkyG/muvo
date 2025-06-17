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
            // TODO: Change to sun/moon image with logic 6AM, 6PM
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
        }
    }
}

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
            .padding(.bottom,24)
    }
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
            .padding(.bottom, 24)
        }
        
        
    }
}

struct CategoryView: View{
    
    var body: some View{
        VStack(alignment: .leading) {
            Text("Lagi pengen belajar apa hari ini?")
                .font(.custom("ApercuPro-Bold", size: 16))
                .padding(.bottom, 12)
            SearchBarView()
            HStack(spacing: 12) {
                TopikCardView(title: "Hotel", imageName: "iconHotel") {
                    print("Hotel tapped")
                    // TODO: Add Navigation
                }
                TopikCardView(title: "Bandara", imageName: "iconAirport") {
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

struct TopikCardView: View {
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
