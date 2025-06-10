//
//  OnboardingView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 10/06/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: Action Skip (maybe use UserDefaults)
                    }) {
                        Text("Skip")
                            .font(.custom("Apercu-Bold", size: 16))
                            .foregroundColor(.disabledText)
                            .underline()
                    }
                    .padding(.trailing, 30)
                }
                
                Spacer()
                
                // TODO: Change Rectangle to Image after HiFi Ready
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(width: 286, height: 286)
                
                Spacer()
                
                // MARK: Blue Card Bottom Section
                ZStack(alignment: .bottomTrailing) {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 40)
                        .fill(Color.blue)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            (
                                Text("Latihan ")
                                    .font(.custom("ApercuPro-Bold", size: 32))
                                    .foregroundColor(.white)
                                +
                                Text("Pronunciation")
                                    .font(.custom("ApercuPro-BoldItalic",size: 32))
                                    .foregroundColor(.white)
                                
                                +
                                Text("\nUntuk Liburanmu")
                                    .font(.custom("ApercuPro-Bold", size: 32)).bold()
                                    .foregroundColor(.white)
                            )
                        }
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Asah pronunciation lewat latihan seru. Teman liburan yang bikin skill makin jago!")
                            .foregroundColor(.white)
                            .font(.custom("ApercuPro", size: 20))
                            .padding(.top, 4)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        ZStack {
                            HStack(spacing: 8) {
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 10, height: 10)
                                Circle().fill(Color.white).frame(width: 10, height: 10)
                            }
                            
                            HStack {
                                Spacer()
                                Button {
                                    // TODO: Add Action
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.blue)
                                        .frame(width: 56, height: 56)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                .frame(height: 300)
                .onAppear() {
                    for family in UIFont.familyNames {
                        print("Family: \(family)")
                        for name in UIFont.fontNames(forFamilyName: family) {
                            print("  Font: \(name)")
                        }
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
