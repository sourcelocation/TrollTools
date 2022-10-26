//
//  CatalogThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import Foundation
import UIKit
import AssetCatalogWrapper

class CatalogThemeManager {
    
    static var fm = FileManager.default
    
    static func setTheme(theme: Theme, filenameEnding: String, apps: [LSApplicationProxy], progress: (String) -> ()) throws {
        // Itterate over all icons
        var systemApps: [LSApplicationProxy] = []
        
        let appCount = apps.count
        for (i,app) in apps.enumerated() {
            guard let bundleID = app.bundleIdentifier else { throw "Bundle not found" }
            func sendProgress(_ str: String) {
                progress("App #\(i)/\(appCount)\n\(bundleID)\n\n\(str)")
            }
            
            sendProgress("Starting")
            guard let appURL = app.bundleURL else { continue }
            
            // check if it's in /var
            sendProgress("Checking if app is in /var")
            guard appURL.pathComponents.count >= 1 && (appURL.pathComponents[1] == "var" || appURL.pathComponents[1] == "private") else {
                systemApps.append(app)
                continue
            }
            
            // Icon url
            sendProgress("Getting url of icon in theme")
            let themeIconURL = theme.url.appendingPathComponent("IconBundles").appendingPathComponent(bundleID + filenameEnding + ".png")
            guard fm.fileExists(atPath: themeIconURL.path) else { continue }
            
            // Backup assets
            let catalogURL = appURL.appendingPathComponent("Assets.car")
            let backupURL = try backupAssetsURL(appURL: appURL)
            
            // Restore broken apps from backup
            sendProgress("Checking if assets.car exists")
            if !fm.fileExists(atPath: catalogURL.path) {
                sendProgress("Catalog not found - \(catalogURL.path).\nChecking if backup exists")
                if fm.fileExists(atPath: backupURL.path) {
                    sendProgress("Restoring from backup")
                    try RootHelper.copy(from: backupURL, to: catalogURL)
                } else { continue }
            }
            
            // Create backup if not made
            sendProgress("Checking if backup exists")
            if !fm.fileExists(atPath: backupURL.path) {
                try RootHelper.copy(from: catalogURL, to: backupURL)
            }
            
            // Get CGImage from icon
            sendProgress("Creating icon CGImage from theme")
            let imgData = try Data(contentsOf: themeIconURL)
            guard let image = UIImage(data: imgData) else { continue }
            guard let cgImage = image.cgImage else { continue }
            
            // Apply new icon
            sendProgress("Start modifying")
            try? modifyIconInCatalog(url: catalogURL, to: cgImage, sendProgress: sendProgress(_:))
            sendProgress("Completed")
        }
        
        try WebclipsThemeManager.setTheme(theme: theme, filenameEnding: filenameEnding, apps: systemApps, progress: progress)
        
        progress("Completed.")
    }
    
    static func restoreCatalogs(progress: (String) -> ()) throws {
        guard let apps = LSApplicationWorkspace.default().allApplications() else { throw "Couldn't get apps" }
        let appCount = apps.count
        for (i, app) in apps.enumerated() {
            progress("Restoring app #\(i)/\(appCount)")
            guard let appURL = app.bundleURL else { continue }
            let catalogURL = appURL.appendingPathComponent("Assets.car")
            
            // check if it's in /var
            guard appURL.pathComponents.count >= 1 && (appURL.pathComponents[1] == "var" || appURL.pathComponents[1] == "private") else { continue }
            
            guard fm.fileExists(atPath: catalogURL.path) else { continue }
            let backupURL = try backupAssetsURL(appURL: appURL)
            guard fm.fileExists(atPath: backupURL.path) else { continue }
            try RootHelper.removeItem(at: catalogURL)
            try RootHelper.move(from: backupURL, to: catalogURL)
        }
    }
    
    static func modifyIconInCatalog(url: URL, to icon: CGImage, sendProgress: (String) -> ()) throws { // icon: CGImage
        let tempAssetDir = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/temp-assets-\(UUID()).car")
        sendProgress("Moving assets to temp dir")
        try RootHelper.move(from: url, to: tempAssetDir)

        sendProgress("Setting permission")
        try RootHelper.permissionset(url: tempAssetDir)

        sendProgress("Getting renditions")
        guard let (catalog, renditionsRoot) = try? AssetCatalogWrapper.shared.renditions(forCarArchive: tempAssetDir) else { throw "Error getting renditions"}
        for rendition in renditionsRoot {
            let type = rendition.type
            guard type == .icon else { continue }
            let renditions = rendition.renditions
            for rend in renditions {
                sendProgress("Editing icon asset")
                try? catalog.editItem(rend, fileURL: tempAssetDir, to: .image(icon))
            }
        }
        sendProgress("Moving assets.car back into app's bundle")
        try RootHelper.move(from: tempAssetDir, to: url)
    }
    
    static private func backupAssetsURL(appURL: URL) throws -> URL {
        // Get version of app, so when app updates and user restores assets.car, old
        guard let infoPlistData = try? Data(contentsOf: appURL.appendingPathComponent("Info.plist")), let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
        guard let appShortVersion = (plist["CFBundleShortVersionString"] as? String) ?? plist["CFBundleVersion"] as? String else { throw "CFBundleShortVersionString missing for \(appURL.path)" }
        return appURL.appendingPathComponent("TrollToolsAssetsBackup-\(appShortVersion).car")
    }
}
