//
//  QuarterCircleView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 17/06/25.
//
import SwiftUI

struct QuarterCircleView: View {
    var body: some View {
        BottomLargeRadiusShape()
            .fill(Color.blue)
            .ignoresSafeArea(edges: .bottom)
    }
    
    struct BottomLargeRadiusShape: Shape {
        func path(in rect: CGRect) -> Path {
            let topLeftRadius: CGFloat = 500
            let topRightRadius: CGFloat = 0
            let bottomLeftRadius: CGFloat = 0
            let bottomRightRadius: CGFloat = 0

            var path = Path()
            let width = rect.size.width
            let height = rect.size.height

            path.move(to: CGPoint(x: 0, y: topLeftRadius))
            
            if topLeftRadius > 0 {
                path.addQuadCurve(to: CGPoint(x: topLeftRadius, y: 0),
                                  control: CGPoint(x: 0, y: 0))
            } else {
                path.addLine(to: CGPoint(x: 0, y: 0))
            }

            path.addLine(to: CGPoint(x: width - topRightRadius, y: 0))
            if topRightRadius > 0 {
                path.addQuadCurve(to: CGPoint(x: width, y: topRightRadius),
                                  control: CGPoint(x: width, y: 0))
            } else {
                path.addLine(to: CGPoint(x: width, y: 0))
            }

            path.addLine(to: CGPoint(x: width, y: height - bottomRightRadius))
            if bottomRightRadius > 0 {
                path.addQuadCurve(to: CGPoint(x: width - bottomRightRadius, y: height),
                                  control: CGPoint(x: width, y: height))
            } else {
                path.addLine(to: CGPoint(x: width, y: height))
            }

            path.addLine(to: CGPoint(x: bottomLeftRadius, y: height))
            if bottomLeftRadius > 0 {
                path.addQuadCurve(to: CGPoint(x: 0, y: height - bottomLeftRadius),
                                  control: CGPoint(x: 0, y: height))
            } else {
                path.addLine(to: CGPoint(x: 0, y: height))
            }

            path.closeSubpath()
            return path
        }
    }
}

#Preview {
    HomeView()
}
