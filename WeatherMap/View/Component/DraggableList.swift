//
//  DraggableList.swift
//  WeatherMap
//
//  Created by hendra on 15/07/24.
//

import SwiftUI
import MapKit
import UniformTypeIdentifiers

struct DraggableList: View {
    @Binding var selectedResult: [MKMapItem]
    @State private var itemNames: [String]
    @State private var draggedItem: String?
    var onDismiss: () -> Void

    init(selectedResult: Binding<[MKMapItem]>, onDismiss: @escaping () -> Void) {
        self._selectedResult = selectedResult
        self._itemNames = State(initialValue: selectedResult.wrappedValue.dropFirst().map { $0.placemark.name ?? "Unknown" })
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            
            VStack {
                VStack {
                    ForEach(itemNames, id: \.self) { item in
                        CustomField(text: .constant(item))
                            .onDrag {
                                self.draggedItem = item
                                return NSItemProvider(object: item as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: item, itemNames: $itemNames, draggedItem: $draggedItem, selectedResult: $selectedResult))
                        Button {
                            onDismiss()
                        } label: {
                            Text("Search Route")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 8)
                        
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 10)
                .padding()

            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    @Binding var itemNames: [String]
    @Binding var draggedItem: String?
    @Binding var selectedResult: [MKMapItem]

    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        if let draggedItem = draggedItem {
            let fromIndex = itemNames.firstIndex(of: draggedItem)
            let toIndex = itemNames.firstIndex(of: item)
            if let fromIndex = fromIndex, let toIndex = toIndex, fromIndex != toIndex {
                withAnimation {
                    // Swap items in itemNames
                    itemNames.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? (toIndex + 1) : toIndex)

                    // Adjust the indices for selectedResult
                    let actualFromIndex = fromIndex + 1
                    let actualToIndex = toIndex + 1

                    let movedItem = selectedResult.remove(at: actualFromIndex)
                    selectedResult.insert(movedItem, at: actualToIndex)
                }
            }
        }
    }
}

#Preview {
    DraggableList(selectedResult: .constant([
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), addressDictionary: ["name": "San Francisco"])),
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), addressDictionary: ["name": "Los Angeles"])),
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), addressDictionary: ["name": "New York"])),
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278), addressDictionary: ["name": "London"])),
        MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), addressDictionary: ["name": "Paris"]))
    ]))
    {
            print("tes")
        }
}
