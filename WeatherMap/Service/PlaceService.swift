////
////  PlaceService.swift
////  WeatherMap
////
////  Created by Jonathan Aaron Wibawa on 10/07/24.
////
//
//import Foundation
//import SwiftData
//
//final class PlaceService {
//    private let modelContainer: ModelContainer
//    private let modelContext: ModelContext
//
//    @MainActor
//    static let shared = PlaceService()
//
//    @MainActor
//    private init() {
//        self.modelContainer = try! ModelContainer(for: Place.self)
//        self.modelContext = modelContainer.mainContext
//    }
//
//    func appendItem(place: Place) {
//        modelContext.insert(place)
//        do {
//            try modelContext.save()
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
//
//    func fetchItems() -> [Place] {
//        do {
//            return try modelContext.fetch(FetchDescriptor<Place>())
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
//
//    func removeItem(_ place: Place) {
//        modelContext.delete(place)
//    }
//}
