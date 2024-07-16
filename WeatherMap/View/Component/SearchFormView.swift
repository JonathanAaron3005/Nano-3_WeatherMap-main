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
    //    var searchPlaces: (String) async -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 45, height: 45))
                .fill(.clear)
                .background(.gray.opacity(0.25))
                .cornerRadius(20)
                .padding()
            RoundedRectangle(cornerSize: CGSize(width: 45, height: 45))
                .fill(.clear)
                .frame(width: 320, height: 100)
                .background(.gray.opacity(0.25))
                .cornerRadius(20)
                .padding()
            VStack {
                Form {
                    TextField("Current Location", text: $locationManager.locationName)
                        .font(.subheadline)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                    
                    TextField("Search for a location...", text: $searchText)
                        .font(.subheadline)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .onSubmit {
                            //Task { await searchPlaces(searchText) }
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
                }
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .padding()
                
                Button(action: {
                    additionalSearchTexts.append("")
                }) {
                    Text("Add Stop")
                        .font(.subheadline)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .offset(x: 100, y: -10)
            }
        }
        .frame(height: 200)
    }
    
    func searchAndAddPlaces(index: Int) {
        let searchText = additionalSearchTexts[index]
        //        Task {
        //            await searchPlaces(searchText)
        //        }
    }
}

#Preview {
    SearchFormView(searchText: .constant("tes"), additionalSearchTexts: .constant([]), searchTextIndex: .constant(1), locationManager: LocationManager())
}

