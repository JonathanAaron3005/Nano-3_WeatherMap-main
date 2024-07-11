//
//  PlaceView.swift
//  WeatherMap
//
//  Created by hendra on 10/07/24.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    @StateObject private var viewModel = PlaceViewModel()
    
    @State private var showingAddPlaceView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.places) { place in
                    VStack(alignment: .leading) {
                        Text(place.title ?? "Unknown")
                            .font(.headline)
                        Text(place.subtitle ?? "No subtitle")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: viewModel.deletePlace)
            }
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPlaceView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlaceView) {
                AddPlaceView(viewModel: viewModel)
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView()
    }
}
