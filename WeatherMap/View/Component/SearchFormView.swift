//
//  SearchFormView.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 15/07/24.
//

import SwiftUI

struct SearchFormView: View {
    @Binding var searchText: String
    @Binding var additionalSearchTexts: [String]
    @Binding var searchTextIndex: Int?
    @ObservedObject var locationManager: LocationManager
    var searchPlaces: (String) async -> Void
    
    var body: some View {
        Form {
            TextField("Current Location", text: $locationManager.locationName)
                .font(.subheadline)
                .background(Color.clear)
            
            TextField("Search for a location...", text: $searchText)
                .font(.subheadline)
                .background(Color.clear)
                .onSubmit {
                    Task { await searchPlaces(searchText) }
                }
            
            ForEach(0..<additionalSearchTexts.count, id: \.self) { index in
                TextField("Search for a location...", text: Binding(
                    get: { additionalSearchTexts[index] },
                    set: { newValue in
                        additionalSearchTexts[index] = newValue
                        searchTextIndex = index
                    }
                ))
                .font(.subheadline)
                .background(Color.clear)
                .onSubmit {
                    if let index = searchTextIndex {
                        searchAndAddPlaces(index: index)
                    }
                }
            }
            Button(action: {
                additionalSearchTexts.append("")
            }) {
                Text("Add Stop")
                    .font(.subheadline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .background(.white)
        .cornerRadius(20)
        .frame(height: 200)
        .padding()
        .shadow(radius: 10)
    }
    
    func searchAndAddPlaces(index: Int) {
        let searchText = additionalSearchTexts[index]
        Task {
            await searchPlaces(searchText)
        }
    }
}

