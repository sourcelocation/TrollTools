//
//  ThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import UIKit

class WebclipsThemeManager {
    var templatePlistURL = Bundle.main.url(forResource: "WebClipTemplate", withExtension: "plist")
    var fm = FileManager.default
    
    func applyChanges(_ changes: [ThemeManager.SystemAppIconChange], progress: (Double) -> ()) throws {
        let changesCount = Double(changes.count)
        guard changesCount > 0 else { throw "No changes" }
        for (i,change) in changes.enumerated() {
            try? applyChange(change)
            progress(Double(i) / changesCount)
        }
    }
    
    private func applyChange(_ change: ThemeManager.SystemAppIconChange) throws {
        try? fm.createDirectory(at: webclipsActiveIconsDir, withIntermediateDirectories: true)
        
        let appID = change.appID

        if let iconURL = change.themeIconURL {
            guard fm.fileExists(atPath: iconURL.path) else { return }
            
            let webClipURL = webClipURL(appID: appID)
            
            // Add webclip if not added
            if !fm.fileExists(atPath: webClipURL.path) {
                try addWebClip(bundleID: appID, displayName: change.localizedName)
            }
            
            // Copy icon to activeIconsDir
            let activeIconDir = webclipsActiveIconsDir.appendingPathComponent(appID + ".png")
            try? fm.removeItem(at: activeIconDir)
            try fm.createSymbolicLink(at: activeIconDir, withDestinationURL: iconURL)
        } else {
            try? fm.removeItem(at: webclipsActiveIconsDir.appendingPathComponent(appID + ".png"))
        }
    }
    
//    func setTheme(theme: Theme, apps: [LSApplicationProxy], progress: (String) -> ()) throws {
//        // Itterate over all icons
//        let appCount = apps.count
//        for (i,app) in apps.enumerated() {
//
//        }
//    }
    
    func removeCurrentThemes() throws {
        try fm.removeItem(at: webclipsActiveIconsDir)
    }
    
    func removeWebclips() throws {
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
            guard url.lastPathComponent.contains(".DO-NOT-DELETE-TrollTools-") else { continue }
            try fm.removeItem(at: url)
        }
    }
    
    
    private func webClipURL(appID: String) -> URL {
#if targetEnvironment(simulator)
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WebClips/.DO-NOT-DELETE-TrollTools-\(appID).webclip")
#else
        URL(fileURLWithPath: "/var/mobile/Library/WebClips/.DO-NOT-DELETE-TrollTools-\(appID).webclip")
#endif
        //        return
    }
    func addWebClip(bundleID: String, displayName: String) throws {
        let webClipURL = webClipURL(appID: bundleID)
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
    
//    func changeLabelVisibility(visible: Bool) throws {
//        let installedAppNames = try ThemeManager.getInstalledApplicationsNames()
//
//        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
//            guard url.lastPathComponent.contains(".DO-NOT-DELETE-TrollTools-") else { continue }
//
//            let plistURL = url.appendingPathComponent("Info.plist")
//            
//            let data = try Data(contentsOf: plistURL)
//            guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
//
//            // Modify values
//            guard let bundleID = plist["ApplicationBundleIdentifier"] as? String else { throw "Couldn't get bundle id of exisitng webclip. Webclip url \(url)" }
//            plist["Title"] = visible ? installedAppNames[bundleID] : " "
//
//            // Save plist
//            let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
//            try plistData.write(to: plistURL)
//        }
//    }
}
