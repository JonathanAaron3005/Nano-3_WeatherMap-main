//
//  DateTimePicker.swift
//  WeatherMap
//
//  Created by Natasha Radika on 16/07/24.
//

import SwiftUI

struct DateTimePicker: View {
    @Binding var isShowing: Bool
    @Binding var selectedDate: Date
    var onSave: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    DatePicker("", selection: $selectedDate)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                }
                .frame(width: geometry.size.width, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .offset(y: isShowing ? 0 : 300)
                .animation(.easeOut)
            }
            .background(Color.black.opacity(isShowing ? 0.4 : 0).edgesIgnoringSafeArea(.all))
                    .onTapGesture {
                        if isShowing {
                            isShowing = false
                            onSave()
                        }
                    }
        }
    }
}

#Preview {
    DateTimePicker(isShowing: .constant(true), selectedDate: .constant(Date()), onSave: {})
        .edgesIgnoringSafeArea(.all)
}
