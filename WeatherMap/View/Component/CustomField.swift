//
//  CustomField.swift
//  WeatherMap
//
//  Created by hendra on 15/07/24.
//

import SwiftUI

struct CustomField: View {
    @Binding var text: String
    var onRemove: () -> Void
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "mappin.circle.fill")
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
            }
            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(.lightGray))
            Image(systemName: "trash.fill")
                .font(.title2)
                .padding(8)
                .onTapGesture {
                    onRemove()
                }
        }
        .frame(height: 60)
        .padding(.horizontal, 8)
    }
}
