//
//  ThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import UIKit
import Dynamic

fileprivate var themesDir: URL = {
#if targetEnvironment(simulator)
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
#else
    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
#endif
}()

fileprivate var activeIconsDir: URL = {
#if targetEnvironment(simulator)
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
#else
    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
#endif
}()

class ThemeManager {
    static var templatePlistURL = Bundle.main.url(forResource: "WebClipTemplate", withExtension: "plist")
    static var fm = FileManager.default
    
    static func set(theme: Theme) throws {
        let iconBundlesURL = theme.url.appendingPathComponent("IconBundles")
        if !fm.fileExists(atPath: activeIconsDir.path) {
            try fm.createDirectory(at: activeIconsDir, withIntermediateDirectories: true)
        }
        
        let filesInIconBundles = try fm.contentsOfDirectory(at: iconBundlesURL, includingPropertiesForKeys: nil)
        
        guard let firstIconFilename = filesInIconBundles.last?.lastPathComponent else { throw "Couldn't get last icon to get file ending" }
        let iconFilenameEnding = try getIconFileEnding(iconFilename: firstIconFilename)
        var installedAppsCount = 0
        guard let nsinstalledApps = Dynamic.LSApplicationWorkspace().allInstalledApplications().asArray else { throw "Couldn't get installed apps" }
        let installedAppNames = Array(nsinstalledApps).reduce(into: [String: String]()) {
            let applicationIdentifier = Dynamic($1).applicationIdentifier().asString!
            let displayName = Dynamic($1).localizedName().asString
            $0[applicationIdentifier] = displayName
        }
        
        // Itterate over all icons
        for fileURL in filesInIconBundles {
            guard fileURL.lastPathComponent.contains(".png") else { continue }
            // Check if application is installed
            let bundleID = fileURL.deletingPathExtension().lastPathComponent.replacingOccurrences(of: iconFilenameEnding, with: "")
            let webClipURL = webClipURL(bundleID: bundleID)
            
            // Add webclip if not added
            if !fm.fileExists(atPath: webClipURL.path) {
                guard let displayName = installedAppNames[bundleID] else { continue }
                try addWebClip(bundleID: bundleID, displayName: displayName)
            }
            
            // Copy icon to activeIconsDir
            let activeIconDir = activeIconsDir.appendingPathComponent(bundleID + ".png")
            try? fm.removeItem(at: activeIconDir)
            try fm.createSymbolicLink(at: activeIconDir, withDestinationURL: fileURL)
            
            installedAppsCount += 1
            print(webClipURL)
        }
    }
    
    static func removeCurrentThemes() throws {
        try fm.removeItem(at: activeIconsDir)
    }
    
    static func removeWebclips() throws {
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
            guard url.lastPathComponent.contains(".DO-NOT-DELETE-TrollTools-") else { continue }
            try fm.removeItem(at: url)
        }
    }
    
    static func getIconFileEnding(iconFilename: String) throws -> String {
        if iconFilename.contains("-large.png") {
            return "-large"
        } else if iconFilename.contains("@2x.png") {
            return"@2x"
        } else if iconFilename.contains("@23.png") {
            return "@3x"
        } else {
            throw "Unknown icon filename ending. Couldn't get bundle ids. Please create an issue on github with the name of the theme you used. Thanks"
        }
    }
    
    static func getIcons(forBundleIDs bundleIDs: [String], from theme: Theme) throws -> [UIImage] {
        try bundleIDs.map { try getIcon(forBundleID: $0, from: theme) }
    }
    
    static private func getIcon(forBundleID bundleID: String, from theme: Theme) throws -> UIImage {
        let iconBundlesURL = theme.url.appendingPathComponent("IconBundles")
        let filesInIconBundles = try fm.contentsOfDirectory(at: iconBundlesURL, includingPropertiesForKeys: nil)
        guard let firstIconFilename = filesInIconBundles.last?.lastPathComponent else { throw "No icons" }
        let iconFilenameEnding = try getIconFileEnding(iconFilename: firstIconFilename)
        guard let image = UIImage(contentsOfFile: iconBundlesURL.appendingPathComponent(bundleID + iconFilenameEnding).path) else { throw "Couldn't open image" }
        return image
    }
    
    static func importTheme(from importURL: URL) throws -> Theme {
        let rawIcons = !fm.fileExists(atPath: importURL.appendingPathExtension("IconBundles").path)
        let name = importURL.deletingPathExtension().lastPathComponent
        if rawIcons {
            let themeURL = themesDir.appendingPathComponent(name)
            try fm.createDirectory(at: themeURL, withIntermediateDirectories: true)
            try fm.copyItem(at: importURL, to: themeURL.appendingPathComponent("IconBundles"))
        } else {
            if !fm.fileExists(atPath: themesDir.path) {
                try fm.createDirectory(at: themesDir, withIntermediateDirectories: true)
            }
            
            try fm.copyItem(at: importURL, to: themesDir.appendingPathComponent(name))
        }
        
        let targetURL = themesDir.appendingPathComponent(name)
        return Theme(name: targetURL.deletingPathExtension().lastPathComponent, iconCount: try fm.contentsOfDirectory(at: targetURL.appendingPathComponent("IconBundles"), includingPropertiesForKeys: nil).count)
    }
    
    static func removeImportedTheme(theme: Theme) throws {
        try fm.removeItem(at: theme.url)
    }
    
    static private func webClipURL(bundleID: String) -> URL {
#if targetEnvironment(simulator)
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WebClips/.DO-NOT-DELETE-TrollTools-\(bundleID).webclip")
#else
        URL(fileURLWithPath: "/var/mobile/Library/WebClips/.DO-NOT-DELETE-TrollTools-\(bundleID).webclip")
#endif
        //        return
    }
    static func addWebClip(bundleID: String, displayName: String) throws {
        let webClipURL = webClipURL(bundleID: bundleID)
        try fm.createDirectory(at: webClipURL, withIntermediateDirectories: true)
        
        // Load plist
        let data = try Data(contentsOf: templatePlistURL!)
        guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
        
        // Modify values
        plist["ApplicationBundleIdentifier"] = bundleID
        plist["Title"] = displayName
        plist["RemovalDisallowed"] = false
        plist["RemovalDisallowed"] = false
        
        // Save plist
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? fm.removeItem(at: webClipURL.appendingPathComponent("icon.png"))
        try FileManager.default.createSymbolicLink(at: webClipURL.appendingPathComponent("icon.png"), withDestinationURL: activeIconsDir.appendingPathComponent(bundleID + ".png"))
        try plistData.write(to: webClipURL.appendingPathComponent("Info.plist"))
    }
}

struct Theme: Codable, Identifiable {
    var id = UUID()
    
    var name: String
    var iconCount: Int
    var url: URL { // Documents/ImportedThemes/Theme.theme
        return themesDir.appendingPathComponent(name /*+ ".theme"*/)
    }
}
