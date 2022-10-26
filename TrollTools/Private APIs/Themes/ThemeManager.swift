//
//  ThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import UIKit

var themesDir: URL = {
#if targetEnvironment(simulator)
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
#else
    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
#endif
}()

var webclipsActiveIconsDir: URL = {
#if targetEnvironment(simulator)
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
#else
    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
#endif
}()

class ThemeManager {
    static var fm = FileManager.default
    
    
    static func set(theme: Theme, progress: (String) -> ()) throws {
        let iconBundlesURL = theme.url.appendingPathComponent("IconBundles")
        try? fm.createDirectory(at: webclipsActiveIconsDir, withIntermediateDirectories: true)
        
        // Get theme icon ending like -large or @2x
        guard let firstIconFilename = (try fm.contentsOfDirectory(at: iconBundlesURL, includingPropertiesForKeys: nil)).last?.lastPathComponent else { throw "Couldn't get last icon to get file ending" }
        let filenameEnding = try getIconFileEnding(iconFilename: firstIconFilename)
        
        // Setting theme
        guard let apps = LSApplicationWorkspace.default().allApplications() else { throw "Couldn't get apps" }
        try CatalogThemeManager.setTheme(theme: theme, filenameEnding: filenameEnding, apps: apps, progress: progress)
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
    
    static func getIcons(forBundleIDs bundleIDs: [String], from theme: Theme) throws -> [UIImage?] {
        bundleIDs.map { try? getIcon(forBundleID: $0, from: theme) }
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
        let name = importURL.deletingPathExtension().lastPathComponent
        try? fm.createDirectory(at: themesDir, withIntermediateDirectories: true)
        let themeURL = themesDir.appendingPathComponent(name)
        
        try? fm.removeItem(at: themeURL)
        try fm.createDirectory(at: themeURL, withIntermediateDirectories: true)
        try fm.copyItem(at: importURL, to: themeURL.appendingPathComponent("IconBundles"))
        
        return Theme(name: themeURL.deletingPathExtension().lastPathComponent, iconCount: try fm.contentsOfDirectory(at: themeURL.appendingPathComponent("IconBundles"), includingPropertiesForKeys: nil).count)
    }
    
    static func removeImportedTheme(theme: Theme) throws {
        try fm.removeItem(at: theme.url)
    }
    static func getInstalledApplicationsNames() throws -> [String: String] {
        guard let apps = LSApplicationWorkspace.default().allApplications() else { throw "Couldn't get apps" }
        return apps.reduce(into: [String: String]()) {
            let applicationIdentifier = $1.applicationIdentifier
            let displayName = $1.localizedName()
            $0[applicationIdentifier ?? ""] = displayName
        }
    }
    static func removeCurrentThemes(progress: (String) -> ()) throws {
        try CatalogThemeManager.restoreCatalogs(progress: progress)
        try WebclipsThemeManager.removeCurrentThemes()
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

enum IconThemingMethod: String {
    case webclips, appIcons
}
