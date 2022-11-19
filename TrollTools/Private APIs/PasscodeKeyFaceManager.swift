//
//  PasscodeKeyFaceChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 17.10.2022.
//

import UIKit

class PasscodeKeyFaceManager {

    static func setFace(_ image: UIImage, for n: Int, keySize: Int, customX: Int, customY: Int) throws {
        // this part could be cleaner
        var usesCustomSize = true
        var sizeToUse = 0
        if keySize == 0 {
            sizeToUse = 152
            usesCustomSize = false
        } else if keySize == 1 {
            sizeToUse = 225
            usesCustomSize = false
        }
        
        let size = usesCustomSize ? CGSize(width: customX, height: customY) : CGSize(width: sizeToUse, height: sizeToUse)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let url = try getURL(for: n)
        guard let png = newImage?.pngData() else { throw "No png data" }
        try png.write(to: url)
    }
    
    static func removeAllFaces() throws {
        let fm = FileManager.default
        
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(), includingPropertiesForKeys: nil) {
            let size = CGSize(width: 152, height: 152)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            UIImage().draw(in: CGRect(origin: .zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let png = newImage?.pngData() else { throw "No png data" }
            try png.write(to: imageURL)
        }
    }
    
    static func setFacesFromTheme(_ url: URL) throws {
        let fm = FileManager.default
        let teleURL = try telephonyUIURL()
        
        for imageURL in (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? [] {
            let img = UIImage(contentsOfFile: imageURL.path)
            let size = CGSize(width: img?.size.width ?? 152, height: img?.size.height ?? 152)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            img!.draw(in: CGRect(origin: .zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let png = newImage?.pngData() else { throw "No png data" }
            try png.write(to: teleURL.appendingPathComponent(imageURL.lastPathComponent))
        }
    }
    
    static func reset() throws {
        let fm = FileManager.default
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches/"), includingPropertiesForKeys: nil) {
            if url.lastPathComponent.contains("TelephonyUI") {
                try fm.removeItem(at: url)
            }
        }
    }
    
    static func getFaces() throws -> [UIImage?] {
        return try [0,1,2,3,4,5,6,7,8,9].map { try getFace(for: $0) }
    }
    
    static func getFace(for n: Int) throws -> UIImage? {
        return UIImage(data: try Data(contentsOf: getURL(for: n)))
    }
    
    static func getURL(for n: Int) throws -> URL { // O(n^2), but works
        let fm = FileManager.default
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(), includingPropertiesForKeys: nil) {
            if imageURL.path.contains("-\(n)-") {
                return imageURL
            }
        }
        throw "Passcode face #\(n) couldn't be found."
    }
    
    static func telephonyUIURL() throws -> URL {
        guard let url = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches/"), includingPropertiesForKeys: nil)
            .first(where: { url in url.lastPathComponent.contains("TelephonyUI") }) else { throw "TelephonyUI folder not found. Have the caches been generated? Reset faces in app and try again." }
                   return url
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
