//
//  WeatherBadge.swift
//  WeatherMap
//
//  Created by hendra on 16/07/24.
//

import SwiftUI

//struct Triangle: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.closeSubpath()
//        return path
//    }
//}

struct WeatherBadge: View {
    @Binding var time: String
    @Binding var icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.subheadline)
            Image(systemName: icon)
                .font(.title)
                .symbolRenderingMode(.monochrome)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(radius: 8)
        Triangle()
            .fill(.gray)
            .frame(width: 20, height: 10)
            .offset(y: -8)
            .overlay(
                Triangle()
                    .stroke(Color.black, lineWidth: 1)
                    .frame(width: 20, height: 10)
                    .offset(y: -8)
            )
    }
}

#Preview {
    WeatherBadge(time: .constant("16.00"), icon: .constant("cloud.drizzle.fill"))
}
