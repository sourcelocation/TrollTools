//
//  PasscodeKeyFaceChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 17.10.2022.
//

import UIKit

class PasscodeKeyFaceManager {

    static func setFace(_ image: UIImage, for n: Int, isBig: Bool) throws {
        let size = isBig ? CGSize(width: 225, height: 225) : CGSize(width: 152, height: 152)
        let newImage = image.resized(to: size)
        
        let url = try getURL(for: n)
        guard let png = newImage.pngData() else { throw "No png data" }
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
    
    static func reset() throws {
        let fm = FileManager.default
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(), includingPropertiesForKeys: nil) {
            try fm.removeItem(at: imageURL)
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
