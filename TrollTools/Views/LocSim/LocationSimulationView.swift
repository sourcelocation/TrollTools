//
//  LocationSimulationView.swift
//  TrollTools
//
//  Created by exerhythm on 11.11.2022.
//

import SwiftUI
import MapKit

struct LocationSimulationView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .navigationTitle("Location Simulation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LocationSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSimulationView()
    }
}
