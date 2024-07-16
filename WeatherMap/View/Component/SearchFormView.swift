//
//  SearchFormView.swift
//  WeatherMap
//
//  Created by Jonathan Aaron Wibawa on 15/07/24.
//

import SwiftUI
import MapKit

struct SearchFormView: View {
    @Binding var searchText: String
    @Binding var additionalSearchTexts: [String]
    @Binding var searchTextIndex: Int?
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedResult: [MKMapItem]
    @Binding var myLocation: MKMapItem?
//    var searchPlaces: (String) async -> Void
    
    @State private var showYourLocationSheet = false
    @State private var showAddDestinationSheet = false
    
    @State var title = ""
    
    @Binding var date: Date
    @Binding var transportType: TransportType
    
    @Binding var routeDisplaying: Bool
    @Binding var routes: [MKRoute]
    
    var fetchRoute: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.white)
                .frame(height: 200)
                .padding()
                .padding(.bottom, 16)
                .shadow(radius: 10)
            
            NavigationStack {
                
                VStack {
                    VStack {
                        VStack {
                            HStack {
                                Image(systemName: "location.north.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                Text(myLocation?.name ?? "Your Location")
                                Spacer()
                            }
                            .onTapGesture {
                                title = "Your Location"
                                showAddDestinationSheet.toggle()
                            }
                            Divider()
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                Text(selectedResult.first?.placemark.name ?? "Add Destination")
                                Spacer()
                            }
                            .onTapGesture {
                                title = "Add Destination"
                                showAddDestinationSheet.toggle()
                            }

                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            Button {
                                //ACTION
                            } label: {
                                Text("Add Stop")
                                    .padding(8)
                            }
                            .background(
                                Capsule()
                                    .fill(.white)
                            )
                            .padding()
                        }
                    )
                    .background(
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .fill(.lightGrayBackground)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .sheet(isPresented: $showAddDestinationSheet) {
                        DestinationSheet(title: $title, selectedResult: $selectedResult, fetchRoute: fetchRoute, myLocation: $myLocation)
                            .presentationDragIndicator(.visible)
                    }
                    CustomPicker(date: $date, transportType: $transportType, routeDisplaying: $routeDisplaying, routes: $routes, fetchRoute: fetchRoute)
                        .padding(.trailing, 15)
                        .padding(.top, -28)
                        .padding(.leading, -5)
                }
            }
                
        }
//        Form {
//            TextField("Current Location", text: $locationManager.locationName)
//                .font(.subheadline)
//                .background(Color.clear)
//            
//            TextField("Search for a location...", text: $searchText)
//                .font(.subheadline)
//                .background(Color.clear)
////                .onSubmit {
////                    Task { await searchPlaces(searchText) }
////                }
//            
//            ForEach(0..<additionalSearchTexts.count, id: \.self) { index in
//                TextField("Search for a location...", text: Binding(
//                    get: { additionalSearchTexts[index] },
//                    set: { newValue in
//                        additionalSearchTexts[index] = newValue
//                        searchTextIndex = index
//                    }
//                ))
//                .font(.subheadline)
//                .background(Color.clear)
//                .onSubmit {
//                    if let index = searchTextIndex {
//                        searchAndAddPlaces(index: index)
//                    }
//                }
//            }
//            Button(action: {
//                additionalSearchTexts.append("")
//            }) {
//                Text("Add Stop")
//                    .font(.subheadline)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .background(.white)
//        .cornerRadius(20)
//        .frame(height: 200)
//        .padding()
//        .shadow(radius: 10)
    }
    
    func searchAndAddPlaces(index: Int) {
        let searchText = additionalSearchTexts[index]
        Task {
//            await searchPlaces(searchText)
        }
    }
}

#Preview {
    SearchFormView(searchText: .constant("tes"), additionalSearchTexts: .constant(["tes"]), searchTextIndex: .constant(1), locationManager: LocationManager(), selectedResult: .constant([MKMapItem()]), myLocation: .constant(MKMapItem()), date: .constant(Date()), transportType: .constant(.automobile), routeDisplaying: .constant(false), routes: .constant([MKRoute]())) {
        print("tes")
    }
}
