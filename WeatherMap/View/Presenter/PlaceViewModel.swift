//
//  PlaceViewModel.swift
//  WeatherMap
//
//  Created by hendra on 10/07/24.
//

import Foundation
import Combine
import MapKit

struct IdentifiableError: Identifiable {
    var id = UUID()
    var message: String
}

class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var error: IdentifiableError?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        Task {
            await fetchPlaces()
        }
    }
    
    @MainActor 
    func fetchPlaces() {
        PlaceService.shared.fetchItems { [weak self] result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    self?.places = places
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.error = IdentifiableError(message: error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor 
    func addPlace(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        let newPlace = Place(startCoordinate: startCoordinate, destinationCoordinate: destinationCoordinate, title: title, subtitle: subtitle)
        PlaceService.shared.appendItem(place: newPlace) { [weak self] result in
            switch result {
            case .success:
                self?.fetchPlaces()
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.error = IdentifiableError(message: error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor 
    func deletePlace(at indexSet: IndexSet) {
        for index in indexSet {
            let place = places[index]
            PlaceService.shared.removeItem(place) { [weak self] result in
                switch result {
                    case .success:
                        self?.fetchPlaces()
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.error = IdentifiableError(message: error.localizedDescription)
                        }
                    }
            }
        }
    }
}
