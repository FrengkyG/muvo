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
                    Button("Skip") {
                        // TODO: Action Skip (maybe use UserDefaults)
                    }
                    .padding(.trailing, 30)
                }
                
                Spacer()
                
                // TODO: Change Rectangle to Image after HiFi Ready
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                // MARK: Blue Card Bottom Section
                ZStack(alignment: .bottomTrailing) {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 40)
                        .fill(Color.blue)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Latihan ")
                                .font(.title).bold()
                                .foregroundColor(.white) +
                            Text("Pronunciation")
                                .font(.title).italic().bold()
                                .foregroundColor(.white) +
                            Text("\nUntuk Liburanmu")
                                .font(.title).bold()
                                .foregroundColor(.white)
                        }
                        
                        Text("Asah pronunciation lewat latihan seru. Teman liburan yang bikin skill makin jago!")
                            .foregroundColor(.white)
                            .font(.body)
                            .padding(.top, 4)
                        
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
