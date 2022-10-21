//
//  BadgeColorChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 16.10.2022.
//

import UIKit
import Dynamic

class BadgeChanger {
    static func change(to color: UIColor, with radius: CGFloat) throws {
        let radius = max(1, radius)
        let badge: UIImage = try UIImage.circle(radius: UIDevice.current.userInterfaceIdiom == .pad ? radius * 2 : radius, color: color)
        let badgeBitmapPath = "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
        try? FileManager.default.removeItem(atPath: badgeBitmapPath)
        
        badge.writeToCPBitmapFile(to: badgeBitmapPath as NSString)
    }
}

extension UIImage {
    func writeToCPBitmapFile(to path: NSString) {
        Dynamic(self).writeToCPBitmapFile(path, flags: 1)
    }
    
    static func circle(radius: CGFloat, color: UIColor) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius, height: radius), false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { throw "Unable to get context" }
        defer { UIGraphicsEndImageContext() }
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: radius, height: radius)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { throw "Unable to get image"}
        
        return img
    }
}

extension String: Error {}
