//
//  ThemesView.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import SwiftUI

struct ThemesView: View {
    @State private var isImporting = false
    @State var wallpaper: UIImage?
    @State var defaultWallpaper = false
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    @State var themes: [Theme] = []
    @State var currentThemeIDs: [String] = []
    @State var showsSettings = false
    
    var body: some View {
        NavigationView {
            Group {
                if themes.count == 0 {
                    Text("No themes imported. \nImport them using the button in the top right corner (Themes have to contain icons in the format of <id>.png).")
                        .padding()
                        .background(Color(uiColor14: .secondarySystemBackground))
                        .multilineTextAlignment(.center)
                        .cornerRadius(16)
                        .font(.footnote)
                        .foregroundColor(Color(uiColor14: .secondaryLabel))
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridItemLayout, spacing: 20) {
                            ForEach(themes, id: \.url) { theme in
                                ThemeView(theme: theme, isInUse: currentThemeIDs.contains(theme.id.uuidString), wallpaper: wallpaper!, defaultWallpaper: defaultWallpaper, applyTheme: applyTheme)
                                    .contextMenu {
                                        Button {
                                            themes.removeAll { theme1 in theme1.id == theme.id }
                                            saveThemes()
                                            do {
                                                try ThemeManager.removeImportedTheme(theme: theme)
                                            } catch {
                                                UIApplication.shared.alert(body: error.localizedDescription)
                                            }
                                        } label: {
                                            Label("Remove theme", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(4)
                        
                        Text("TrollTools \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") by @sourcelocation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                            .padding()
                    }
                    .padding(.horizontal, 6)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleTextColor(Color(uiColor14: .label))
            .onAppear {
                wallpaper = WallpaperGetter.homescreen()
                if wallpaper == nil {
                    wallpaper = UIImage(named: "wallpaper")!
                    defaultWallpaper = true
                }
                
                if let data = UserDefaults.standard.data(forKey: "themes") {
                    themes = (try? JSONDecoder().decode([Theme].self, from: data)) ?? []
                }
                
                currentThemeIDs = UserDefaults.standard.array(forKey: "currentThemeIDs") as? [String] ?? []
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isImporting = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        UIApplication.shared.confirmAlert(title: "Remove custom icons", body: "All app icons will be reverted to their original appearance, but system app WebClips will remain. Are you sure you want to continue?", onOK: {
                            removeThemes()
                        }, noCancel: false)
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            if themes.contains(where: { t in
                t.name == url.deletingPathExtension().lastPathComponent
            }) {
                UIApplication.shared.alert(body: "Theme with the name \(url.deletingPathExtension().lastPathComponent) already exists. Please rename the folder.")
                return
            }
            do {
                let theme = try ThemeManager.importTheme(from: url)
                themes.append(theme)
                saveThemes()
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }
    }
    
    func applyTheme(_ theme: Theme) {
        func apply() {
            let timeStart = Date()
            DispatchQueue.global(qos: .userInitiated).async {
                UIApplication.shared.alert(title: "Starting", body: "Please wait", animated: false, withButton: false)
                do {
                    try ThemeManager.set(theme: theme, progress: { str in
                        UIApplication.shared.change(title: "In progress", body: str)
                    })
                    DispatchQueue.main.async {
                        currentThemeIDs.append(theme.id.uuidString)
                        UserDefaults.standard.set(currentThemeIDs, forKey: "currentThemeIDs")
                        UIApplication.shared.change(title: "Success", body: "Theme set successfully. Please rebuild caches inside TrollStore for changes to apply.\n\nElapsed time: \(Double(Int(-timeStart.timeIntervalSinceNow * 100.0)) / 100.0)")
                    }
                } catch { UIApplication.shared.alert(body: error.localizedDescription) }
            }
        }
        var found = false
        for app in LSApplicationWorkspace.default().allApplications() ?? [] {
            if FileManager.default.fileExists(atPath: app.bundleURL.appendingPathComponent("bak.car").path) {
                found = true
                UIApplication.shared.confirmAlert(title: "Mugunghwa installed - PLEASE READ.", body: "It seems you've used other theming engines on this device. It is highly recommended resetting all their options to default values and removing the app.", onOK: { apply() }, noCancel: false)
                break
            }
        }
        if !found { apply() }
    }
    func saveThemes() {
        guard let data = try? JSONEncoder().encode(themes) else { UIApplication.shared.alert(body: "Couldn't save themes"); return }
        UserDefaults.standard.set(data, forKey: "themes")
    }
    func removeThemes() {
        DispatchQueue.global(qos: .userInitiated).async {
            UIApplication.shared.alert(title: "Starting", body: "Please wait", animated: false, withButton: false)
            try? ThemeManager.removeCurrentThemes(progress: { str in
                UIApplication.shared.change(title: "In progress", body: str)
            })
            DispatchQueue.main.async {
                currentThemeIDs = []
                UserDefaults.standard.set([], forKey: "currentThemeIDs")
                UIApplication.shared.change(title: "Success", body: "Restore successful. Please rebuild caches inside TrollStore for changes to apply.")
            }
        }
    }
}


struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
