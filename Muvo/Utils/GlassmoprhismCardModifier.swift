//
//  GlassmoprhismCardModifier.swift
//  Muvo
//
//  Created by Frengky Gunawan on 16/06/25.
//
import SwiftUI

struct GlassmorphismCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
    let shadowOpacity: Double
    
    init(
        cornerRadius: CGFloat = 24,
        shadowRadius: CGFloat = 20,
        shadowOffset: CGSize = CGSize(width: 0, height: 10),
        shadowOpacity: Double = 0.2
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.91)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height
            )
    }
}

extension View {
    func glassmorphismCard(
        cornerRadius: CGFloat = 24,
        shadowRadius: CGFloat = 20,
        shadowOffset: CGSize = CGSize(width: 0, height: 10),
        shadowOpacity: Double = 0.2
    ) -> some View {
        modifier(
            GlassmorphismCardModifier(
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius,
                shadowOffset: shadowOffset,
                shadowOpacity: shadowOpacity
            )
        )
    }
}
