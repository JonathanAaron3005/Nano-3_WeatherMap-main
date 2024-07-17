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
    @Binding var myLocation: MKMapItem?
    @State private var itemNames: [String]
    @State private var draggedItem: String?
    var fetchRoute: () -> Void
    var onDismiss: () -> Void
    @State private var showAddDestinationSheet = false

    init(selectedResult: Binding<[MKMapItem]>, myLocation: Binding<MKMapItem?>, onDismiss: @escaping () -> Void, fetchRoute: @escaping () -> Void) {
        self._selectedResult = selectedResult
        self._myLocation = myLocation
        self._itemNames = State(initialValue: selectedResult.wrappedValue.map { $0.placemark.name ?? "Unknown" })
        self.onDismiss = onDismiss
        self.fetchRoute = fetchRoute
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack {
                destinationList
                addStopButton
                searchRouteButton
            }
            .padding()
            .background(.lightGrayBackground)
            .cornerRadius(8)
            .shadow(radius: 10)
            .padding()
        }
        .sheet(isPresented: $showAddDestinationSheet) {
            DestinationSheet(title: .constant("Add Destination"), selectedResult: $selectedResult, fetchRoute: fetchRoute, myLocation: $myLocation)
        }
        .onChange(of: selectedResult) { newValue in
            itemNames = newValue.map { $0.placemark.name ?? "Unknown" }
        }
    }

    private var destinationList: some View {
        VStack {
            ForEach(itemNames.indices, id: \.self) { index in
                let item = itemNames[index]
                CustomField(text: .constant(item)) {
                    removeSelectedResult(at: index)
                }
                .onDrag {
                    draggedItem = item
                    return NSItemProvider(object: item as NSString)
                }
                .onDrop(of: [.text], delegate: DropViewDelegate(item: item, itemNames: $itemNames, draggedItem: $draggedItem, selectedResult: $selectedResult))
            }
        }
    }

    private var addStopButton: some View {
        HStack {
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .background(
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                )
            Text("Add Stop")
                .foregroundStyle(.gray)
            Spacer()
        }
        .onTapGesture {
            showAddDestinationSheet.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: 60)
        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(.lightGray))
        .padding(.horizontal, 8)
    }

    private var searchRouteButton: some View {
        Button {
            onDismiss()
            fetchRoute()
        } label: {
            Text("Search Route")
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(.blue)
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }

    private func removeSelectedResult(at index: Int) {
        itemNames.remove(at: index)
        selectedResult.remove(at: index)
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    @Binding var itemNames: [String]
    @Binding var draggedItem: String?
    @Binding var selectedResult: [MKMapItem]

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              let fromIndex = itemNames.firstIndex(of: draggedItem),
              let toIndex = itemNames.firstIndex(of: item),
              fromIndex != toIndex else { return }

        withAnimation {
            itemNames.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? (toIndex + 1) : toIndex)

            let movedItem = selectedResult.remove(at: fromIndex)
            selectedResult.insert(movedItem, at: toIndex)
        }
    }
}
