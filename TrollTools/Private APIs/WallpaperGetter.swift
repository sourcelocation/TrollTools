//
//  BitmapToImage.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import UIKit

fileprivate var frameworkPath: String = {
#if TARGET_OS_SIMULATOR
    "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks"
#else
    "/System/Library/PrivateFrameworks"
#endif
}()

class WallpaperGetter {
    static var isLightAppearance = UITraitCollection.current.userInterfaceStyle == .light
    static let cachePath = "/var/mobile/Library/SpringBoard/"
    static private func exists(_ path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
    static private func homescreenData() -> NSData? {
        return (isLightAppearance ? (NSData(contentsOfFile: cachePath + "HomeBackground.cpbitmap") ?? NSData(contentsOfFile: cachePath + "LockBackground.cpbitmap")): (NSData(contentsOfFile: cachePath + "HomeBackgrounddark.cpbitmap") ?? NSData(contentsOfFile: cachePath + "HomeBackground.cpbitmap") ?? NSData(contentsOfFile: cachePath + "LockBackgrounddark.cpbitmap") ?? NSData(contentsOfFile: cachePath + "LockBackground.cpbitmap"))) ?? NSData(contentsOfFile: cachePath + "HomeBackground.cpbitmap")
    }
    static private func lockscreenData() -> NSData? {
        return (isLightAppearance ? NSData(contentsOfFile: cachePath + "LockBackground.cpbitmap") : (NSData(contentsOfFile: cachePath + "LockBackgrounddark.cpbitmap") ?? NSData(contentsOfFile: cachePath + "LockBackground.cpbitmap"))) ?? homescreenData()
    }
    static func homescreen() -> UIImage? {
        guard let data = homescreenData() else { return nil }
        return bitmapToImage(data)
    }
    static func lockscreen() -> UIImage? {
        guard let data = lockscreenData() else { return nil }
        return bitmapToImage(data)
    }
}

// https://github.com/Skittyblock/WallpaperSetter/blob/6f96046776d9d06d589e741409d5f7b9ea95272b/WallpaperSetter/ContentView.swift#L175
func bitmapToImage(_ data: NSData) -> UIImage? {
    let appSupport = dlopen(frameworkPath + "/AppSupport.framework/AppSupport", RTLD_LAZY)
    defer {
        dlclose(appSupport)
    }
    guard let pointer = dlsym(appSupport, "CPBitmapCreateImagesFromData"),
          let CPBitmapCreateImagesFromData = unsafeBitCast(
            pointer,
            to: (@convention(c) (_: NSData, _: UnsafeMutableRawPointer?, _: Int, _: UnsafeMutableRawPointer?) -> Unmanaged<CFArray>)?.self
          ) else { return nil }
    
    
    func bitmapDataToImage(data: NSData) -> UIImage? {
        let imageArray: [AnyObject]? = CPBitmapCreateImagesFromData(data, nil, 1, nil).takeRetainedValue() as [AnyObject]
        guard
            let imageArray = imageArray,
            imageArray.count > 0
        else {
            return nil
        }
        return UIImage(cgImage: imageArray[0] as! CGImage)
    }
    return bitmapDataToImage(data: data)
}
