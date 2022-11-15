//
//  LocationSimulationView.swift
//  TrollTools
//
//  Created by exerhythm on 11.11.2022.
//

import Map
import MapKit
import SwiftUI

struct LocationSimulationView: View {
    struct Location: Identifiable {
        var coordinate: CLLocationCoordinate2D
        var id = UUID()
    }
    
    @State var locations: [Location] = []
    @State var directions: MKDirections.Response? = nil
    
    @State private var region = MKCoordinateRegion(.world)
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            informationVisibility: .default.union(.userLocation),
            interactionModes: [.all],
            annotationItems: locations,
            annotationContent: { location in
                ViewMapAnnotation(coordinate: location.coordinate) {
                    Color.red
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
            },
            overlays: directions?.routes.map { $0.polyline } ?? [],
            
            overlayContent: { overlay in
                RendererMapOverlay(overlay: overlay) { (mapView, overlay) in
                    guard let polyline = overlay as? MKPolyline else {
                        return MKOverlayRenderer(overlay: overlay)
                    }
                    let renderer = MKPolylineRenderer(polyline: polyline)
                    renderer.lineWidth = 4
                    renderer.strokeColor = .red
                    return renderer
                }
            }
        )
        .onAppear {
            CLLocationManager().requestAlwaysAuthorization()
            LocSimManager.startLocSim(location: .init(latitude: 51.507222, longitude: -0.1275))
            locations = [.init(coordinate: .init(latitude: 51.507222, longitude: -0.1275)),.init(coordinate: .init(latitude: 51.507222, longitude: -0.0975)),]
            calculateDirections()
        }
    }
    
    func calculateDirections() {
        guard locations.count >= 2 else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: locations[0].coordinate))
        request.destination = MKMapItem(placemark: .init(coordinate: locations[1].coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            self.directions = response
//            region = .init(response?.routes.first?.polyline.boundingMapRect)
        }
    }
}

struct LocationSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSimulationView()
    }
}
