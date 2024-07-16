//
//  CustomField.swift
//  WeatherMap
//
//  Created by hendra on 15/07/24.
//

import SwiftUI

struct CustomField: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "arrowtriangle.up.fill")
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .background(
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                )
                
            Text(text)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.title)
                .padding()
        }
        .frame(width: .infinity, height: 60)
        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(.lightGray))
        .padding(.horizontal, 8)
    }
}

#Preview {
    CustomField(text: .constant("Text"))
}
