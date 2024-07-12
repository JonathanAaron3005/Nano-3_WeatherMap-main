//
//  MapView.swift
//  WeatherMap
//
//  Created by hendra on 09/07/24.
//

import SwiftUI
import MapKit

struct WeatherOverlay: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var routes: [MKRoute]
    @Binding var weatherOverlays: [WeatherOverlay]

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let route = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: route)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            } else if let polygon = overlay as? MKPolygon, let subtitle = polygon.subtitle, let color = UIColor(colorString: subtitle) {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = color.withAlphaComponent(0.5)
                renderer.strokeColor = .clear
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        mapView.removeOverlays(mapView.overlays)
        for route in routes {
            mapView.addOverlay(route.polyline)
        }
        for overlay in weatherOverlays {
            let circle = MKPolygon(coordinates: [overlay.coordinate], count: 1)
            circle.subtitle = overlay.color.colorStringRepresentation
            mapView.addOverlay(circle)
        }
    }
}

extension UIColor {
    var colorStringRepresentation: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red),\(green),\(blue),\(alpha)"
    }
    
    convenience init?(colorString: String) {
        let components = colorString.split(separator: ",").compactMap { Double($0) }
        guard components.count == 4 else { return nil }
        self.init(red: CGFloat(components[0]), green: CGFloat(components[1]), blue: CGFloat(components[2]), alpha: CGFloat(components[3]))
    }
}
