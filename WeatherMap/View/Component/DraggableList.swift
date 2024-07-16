//
//  DraggableList.swift
//  WeatherMap
//
//  Created by hendra on 15/07/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct DraggableList: View {
    @State private var items: [String] = ["Item 1", "Item 2", "Item 3", "Item 4"]
    @State private var draggedItem: String?

    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                CustomField(text: .constant(item))
                    .onDrag {
                        self.draggedItem = item
                        return NSItemProvider(object: item as NSString)
                    }
                    .onDrop(of: [.text], delegate: DropViewDelegate(item: item, items: $items, draggedItem: $draggedItem))
            }
        }
        .navigationTitle("Draggable List")
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    @Binding var items: [String]
    @Binding var draggedItem: String?

    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem = draggedItem {
            let fromIndex = items.firstIndex(of: draggedItem)
            if let fromIndex = fromIndex {
                let toIndex = items.firstIndex(of: item)
                if let toIndex = toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}

#Preview {
    DraggableList()
}

