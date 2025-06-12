//
//  OnboardingView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var navigateToHome = false
    
    @State private var showExample = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    Color(.systemGray6).ignoresSafeArea()
                    
                    ZStack(alignment: .top) {
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.markOnboardingAsCompleted()
                                    navigateToHome = true
                                }) {
                                    Text("Skip")
                                        .font(.custom("Apercu-Bold", size: 16))
                                        .foregroundColor(.disabledText)
                                        .underline()
                                }
                                .padding(.trailing, 30)
                                .navigationDestination(isPresented: $navigateToHome) {
                                    HomeView()
                                }
                            }
                            Spacer()
                            
                            
                            BottomBlueCardSection(geometry: geometry, navigateToHome: $navigateToHome)
                        }
                        Image("greenMascot")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.5)
                            .padding(.top, 100)
                        
                    }
                }
            }
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    OnboardingView()
}

struct BottomBlueCardSection: View {
    let geometry: GeometryProxy
    @Binding var navigateToHome: Bool
    @State private var navigateToSignup = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 40)
                .fill(Color.primColor ?? Color.blue)
                .ignoresSafeArea(edges: .bottom)
                .frame(height: geometry.size.height * 0.5)
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Latihan ")
                        .font(.custom("ApercuPro-Bold", size: 32))
                        .foregroundColor(.white)
                    +
                    Text("Pronunciation")
                        .font(.custom("ApercuPro-BoldItalic", size: 32))
                        .foregroundColor(.white)
                    +
                    Text("\nUntuk Liburanmu")
                        .font(.custom("ApercuPro-Bold", size: 32))
                        .bold()
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.leading)
                
                Text("Asah pronunciation lewat latihan seru. Teman liburan yang bikin skill makin jago!")
                    .foregroundColor(.white)
                    .font(.custom("ApercuPro", size: 20))
                    .padding(.top, 4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                ZStack {
                    HStack(spacing: 8) {
                        Circle().fill(Color.white.opacity(0.5)).frame(width: 10, height: 10)
                        Circle().fill(Color.white).frame(width: 10, height: 10)
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            // TODO: Just an example, implement true action
                            // showExample = true
                            navigateToSignup = true
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        //                        .sheet(isPresented: $showExample) {
                        //                            ExampleView()
                        //                        }
                        .navigationDestination(isPresented: $navigateToSignup) {
                            SignUpView()
                        }
                    }
                }            }
            .padding(.horizontal, 24)
        }
        .frame(height: 400)
    }
}
