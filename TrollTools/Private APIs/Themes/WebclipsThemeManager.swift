//
//  ThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import UIKit

class WebclipsThemeManager {
    static var templatePlistURL = Bundle.main.url(forResource: "WebClipTemplate", withExtension: "plist")
    static var fm = FileManager.default
    
    static func setTheme(theme: Theme, filenameEnding: String, apps: [LSApplicationProxy], progress: (String) -> ()) throws {
        // Itterate over all icons
        let appCount = apps.count
        for (i,app) in apps.enumerated() {
            guard let bundleID = app.bundleIdentifier else { throw "Bundle not found" }
            func sendProgress(_ str: String) {
                progress("System App #\(i)/\(appCount)\n\(bundleID)\n\n\(str)")
            }
            sendProgress("Getting icon")
            let themeIconURL = theme.url.appendingPathComponent("IconBundles").appendingPathComponent(bundleID + filenameEnding + ".png")
            guard fm.fileExists(atPath: themeIconURL.path) else { continue }
            
            let webClipURL = webClipURL(bundleID: bundleID)
            sendProgress("adding webclip \(webClipURL.path)")
            // Add webclip if not added
            if !fm.fileExists(atPath: webClipURL.path) {
                guard let displayName = app.localizedName() else { continue }
                try addWebClip(bundleID: bundleID, displayName: displayName)
            }
            
            // Copy icon to activeIconsDir
            sendProgress("Setting icon")
            let activeIconDir = webclipsActiveIconsDir.appendingPathComponent(bundleID + ".png")
            try? fm.removeItem(at: activeIconDir)
            sendProgress("changine active icon symlink")
            try fm.createSymbolicLink(at: activeIconDir, withDestinationURL: themeIconURL)
        }
    }
    
    static func removeCurrentThemes() throws {
        try fm.removeItem(at: webclipsActiveIconsDir)
    }
    
    static func removeWebclips() throws {
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
            guard url.lastPathComponent.contains(".DO-NOT-DELETE-TrollTools-") else { continue }
            try fm.removeItem(at: url)
        }
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
        
        // Save plist
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? fm.removeItem(at: webClipURL.appendingPathComponent("icon.png"))
        try FileManager.default.createSymbolicLink(at: webClipURL.appendingPathComponent("icon.png"), withDestinationURL: webclipsActiveIconsDir.appendingPathComponent(bundleID + ".png"))
        try plistData.write(to: webClipURL.appendingPathComponent("Info.plist"))
    }
    
    static func changeLabelVisibility(visible: Bool) throws {
        let installedAppNames = try ThemeManager.getInstalledApplicationsNames()
        
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
            guard url.lastPathComponent.contains(".DO-NOT-DELETE-TrollTools-") else { continue }
            
            let plistURL = url.appendingPathComponent("Info.plist")
            
            let data = try Data(contentsOf: plistURL)
            guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
            
            // Modify values
            guard let bundleID = plist["ApplicationBundleIdentifier"] as? String else { throw "Couldn't get bundle id of exisitng webclip. Webclip url \(url)" }
            plist["Title"] = visible ? installedAppNames[bundleID] : " "
            
            // Save plist
            let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            try plistData.write(to: plistURL)
        }
    }
}
