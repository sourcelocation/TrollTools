//
//  ThemeView.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import SwiftUI


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
                                if $0 != nil {
                                    Image(uiImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                        HStack {
                            ForEach(icons[4...7], id: \.self) {
                                if $0 != nil {
                                    Image(uiImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                    }
                }
            }
            HStack {
                Text(theme.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("· \(theme.iconCount)")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            Button(action: {
                if !isInUse {
                    applyTheme(theme)
                } else {
                    UIApplication.shared.alert(title: "Use \"Clear current themes\"", body: "You can only turn off *all* themes.")
                }
            }) {
                Text(isInUse ? "In use" : "Activate")
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .background(isInUse ? Color(red: 48 / 256, green: 209 / 256, blue: 88 / 256, opacity: 0.5) : Color(uiColor14: UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .foregroundColor(.init(uiColor14: .label))
        }
        .padding(10)
        .background(Color(uiColor14: .secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView(theme: Theme(name: "Theme", iconCount: 23), isInUse: true, wallpaper: UIImage(named: "wallpaper")!, applyTheme: { _ in})
            .frame(width: 190)
    }
}
