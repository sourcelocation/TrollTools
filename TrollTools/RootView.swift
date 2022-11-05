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
            ThemesView()
                .tabItem {
                    Label("Themes", systemImage: "paintbrush")
                }
            BadgeChangerView()
                .tabItem {
                    Label("Badge Color", systemImage: "app.badge")
                }
            PasscodeEditorView()
                .tabItem {
                    Label("Pass Keys", systemImage: "ellipsis.rectangle")
                }
//            CardChangerView()
//                .tabItem {
//                    Label("Apple card", systemImage: "creditcard")
//                }
        }
        .environmentObject(themeManager)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

