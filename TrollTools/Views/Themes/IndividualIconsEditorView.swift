//
//  IndividualIconsEditorView.swift
//  TrollTools
//
//  Created by exerhythm on 28.10.2022.
//

import SwiftUI
//import LaunchServicesBridge
import Dynamic

struct ThemeEditorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var gridItemLayout = [GridItem(.adaptive(minimum: 64, maximum: 64))]
    var editedApps: [IconEditorApp] = {
        (LSApplicationWorkspace.default().allApplications() ?? []).map { IconEditorApp(bundleID: $0.bundleIdentifier, icon: Dynamic(UIImage.self)._applicationIconImage(forBundleIdentifier: $0.bundleIdentifier, format: 1, scale: 4.0).asAnyObject as? UIImage ?? UIImage(named: "NotFound")!)}

    }()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 14) {
                ForEach(editedApps, id: \.bundleID) { app in
                    IconEditorAppView(app: app)
                        .padding(.horizontal, 3)
                }
            }
        }
        .navigationTitle("Custom icons")
    }
    
    struct IconEditorAppView: View {
        @State var app: IconEditorApp
        @State var edited = false
        @State var actionSheetPresented = false
        @State var showsAltSelectionSheet = false
        
        var body: some View {
            Button(action: {
                actionSheetPresented = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: app.icon ?? UIImage(named: "NotFound")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                    if edited {
                        Image(systemName: "pencil")
                            .foregroundColor(.init(uiColor14: .systemBackground))
                            .padding(5)
                            .background(Color.accentColor)
                            .cornerRadius(.infinity)
                            .font(.system(size: 13))
                            .offset(x: 7, y: -7)
                    }
                }
            }
            .actionSheet(isPresented: $actionSheetPresented) {
                ActionSheet(title: Text("Custom icon"), buttons: [
                    .cancel(),
                    .default(Text("Alternative icons"), action: {
                        showsAltSelectionSheet = true
                    }),
                    .default(Text("Choose from photos"))
                ])
            }
            .sheet(isPresented: $showsAltSelectionSheet) {
                AltIconSelectionView(bundleID: app.bundleID, onChoose: { id in
                    
                    
                })
            }
        }
    }
}

struct IndividualIconsEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeEditorView(editedApps: [
            .init(bundleID: "com.apple.smth", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smth1", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smth2", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smth3", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smth4", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smth5", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smth6", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smth7", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smth8", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smth9", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smtha", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smthb", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthc", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthd", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthe", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthf", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smthg", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthh", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smthi", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthj", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthk", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smthl", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smthm", icon: UIImage(named: "wallpaper")!),
            .init(bundleID: "com.apple.smthn", icon: UIImage(named: "64")!),
            .init(bundleID: "com.apple.smtho", icon: UIImage(named: "wallpaper")!),
        
        ])
    }
}

struct IconEditorApp {
    var bundleID: String
    var icon: UIImage?
}
