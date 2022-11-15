//
//  CarrierNameManager.swift
//  TrollTools
//
//  Created by exerhythm on 13.11.2022.
//

import Foundation

class CarrierNameManager {
    static func change(to str: String) throws {
        let fm = FileManager.default
        
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Carrier Bundles/Overlay/"), includingPropertiesForKeys: nil) {
            remLog(url)
            let tempURL = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/\(url.lastPathComponent)")
            try? RootHelper.copy(from: url, to: tempURL)
            try? RootHelper.removeItem(at: url)
            
            guard let data = try? Data(contentsOf: tempURL) else { continue }
            guard var plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { continue }
            
            // Modify values
            if var images = plist["StatusBarImages"] as? [[String: Any]] {
                for var (i, image) in images.enumerated() {
                    image["StatusBarCarrierName"] = str
                    
                    images[i] = image
                }
                plist["StatusBarImages"] = images
            }
            
            // Save plist
            guard let plistData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) else { continue }
            try? plistData.write(to: tempURL)
            
            remLog("moving")
            try? RootHelper.move(from: tempURL, to: url)
        }
    }
}
