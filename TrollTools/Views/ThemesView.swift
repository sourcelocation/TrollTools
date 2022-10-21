//
//  ThemesView.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import SwiftUI

struct ThemesView: View {
    @State private var isImporting = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingAlert = false
    @State var wallpaper: UIImage?
    @State var defaultWallpaper = false
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    @State var themes: [Theme] = []
    @State var currentThemeIDs: [String] = []
    
    var body: some View {
        NavigationView {
            Group {
                if themes.count == 0 {
                    Text("No themes imported. \nImport them using the button in the top right corner (Themes have .theme extension).")
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .multilineTextAlignment(.center)
                        .cornerRadius(16)
                        .font(.footnote)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
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
                                            } catch { alert(error.localizedDescription) }
                                        } label: {
                                            Label("Remove theme", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(4)
                    }
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleTextColor(Color(uiColor: .label))
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
                        removeWebclips()
                    }) {
                        Image(systemName: "trash")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        removeThemes()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { alert("Couldn't get url of file. Did you select it?"); return }
            do {
                let theme = try ThemeManager.importTheme(from: url)
                themes.append(theme)
                saveThemes()
            } catch { alert(error.localizedDescription) }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }
    }
    
    func applyTheme(_ theme: Theme) {
        do {
            try ThemeManager.set(theme: theme)
            currentThemeIDs.append(theme.id.uuidString)
            UserDefaults.standard.set(currentThemeIDs, forKey: "currentThemeIDs")
            respring()
        } catch { alert(error.localizedDescription) }
    }
    
    func alert(_ message: String, title: String = "Error") {
        alertTitle = title
        alertMessage = message
        showingAlert.toggle()
    }
    func saveThemes() {
        guard let data = try? JSONEncoder().encode(themes) else { alert("Couldn't save themes"); return }
        UserDefaults.standard.set(data, forKey: "themes")
    }
    func removeWebclips() {
        do {
            try ThemeManager.removeWebclips()
            removeThemes()
        } catch { alert(error.localizedDescription) }
    }
    func removeThemes() {
        do {
            UserDefaults.standard.set([], forKey: "currentThemeIDs")
            try ThemeManager.removeCurrentThemes()
            respring()
        } catch { alert(error.localizedDescription) }
    }
}

struct ThemeView: View {
    @State var theme: Theme
    @State var isInUse: Bool
    var wallpaper: UIImage
    var defaultWallpaper: Bool = false
    var applyTheme: (Theme) -> ()
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: wallpaper)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 90)
                    .scaleEffect(defaultWallpaper ? 2 : 1)
                    .clipped()
                    .cornerRadius(8)
                    .allowsHitTesting(false)
                if let icons = try? ThemeManager.getIcons(forBundleIDs: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"], from: theme) {
                    VStack {
                        HStack {
                            ForEach(icons[0...3], id: \.self) {
                                Image(uiImage: $0)
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .cornerRadius(5)
                                    .padding(2)
                            }
                        }
                        HStack {
                            ForEach(icons[4...7], id: \.self) {
                                Image(uiImage: $0)
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .cornerRadius(5)
                                    .padding(2)
                            }
                        }
                    }
                }
            }
            HStack {
                Text(theme.name)
                    .font(.headline)
                Text("· \(theme.iconCount)")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            Button(action: {
                applyTheme(theme)
            }) {
                Text(isInUse ? "In use" : "Activate")
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .background(isInUse ? Color(red: 48 / 256, green: 209 / 256, blue: 88 / 256, opacity: 0.5) : Color(uiColor: UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .foregroundColor(.init(uiColor: .label))
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
