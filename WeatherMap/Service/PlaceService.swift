//
//  PlaceService.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 10/07/24.
//

import Foundation
import SwiftData

final class PlaceService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = PlaceService()

    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: Place.self)
        self.modelContext = modelContainer.mainContext
    }

    func appendItem(place: Place, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.modelContext.insert(place)
            do {
                try self.modelContext.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func fetchItems(completion: @escaping (Result<[Place], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let places = try self.modelContext.fetch(FetchDescriptor<Place>())
                completion(.success(places))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func removeItem(_ place: Place, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.modelContext.delete(place)
            do {
                try self.modelContext.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
