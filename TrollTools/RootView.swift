//
//  RootView.swift
//  DebToIPA
//
//  Created by exerhythm on 13.10.2022.
//

import SwiftUI

struct RootView: View {
    @StateObject var themeManager = ThemeManager()
    
    var body: some View {
        TabView {
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
            ThemesView()
                .tabItem {
                    Label("Themes", systemImage: "paintbrush")
                }
//            LocationSimulationView()
//                .tabItem {
//                    Label("Location Spoof", systemImage: "location.fill.viewfinder")
//                }
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .environmentObject(themeManager)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

