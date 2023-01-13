//
//  GesturesView.swift
//  TrollTools
//
//  Created by exerhythm on 09.11.2022.
//

import SwiftUI

struct GesturesView: View {
    @State var enabled = UserDefaults.standard.bool(forKey: "GesturesEnabled")
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Text("Enabled")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    Toggle(isOn: $enabled) {
                        Text("Notched Device Gestures")
                    }
                    .labelsHidden()
                }
                .padding(.top, 20)
                Group {
                    if enabled {
                        Image("13minibezel")
                            .resizable()
                            .aspectRatio(contentMode:. fit)
                    } else {
                        Image("7bezel")
                            .resizable()
                            .aspectRatio(contentMode:. fit)
                    }
                }
                .frame(maxWidth: proxy.size.width * 0.9)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("iPhone X Gestures")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    respring()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onChange(of: enabled) { isEnabled in
            do {
                let url = URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
                let data = try Data(contentsOf: url)
                
                guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read com.apple.MobileGestalt.plist" }
                /*let origDeviceTypeURL = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ArtworkDeviceSubTypeBackup")
                var origDeviceType = 0
                
                if !FileManager.default.fileExists(atPath: origDeviceTypeURL.path) {
                    guard let currentType = ((plist["CacheExtra"] as? [String: Any] ?? [:])["oPeik/9e8lQWMszEjbPzng"] as? [String: Any] ?? [:])["ArtworkDeviceSubType"] as? Int else { throw "Couldn't get current device subtype" }
                    origDeviceType = currentType
                    remLog(origDeviceType)
                    guard let backupData = String(currentType).data(using: .utf8) else { throw "Unable to convert device type to data" }
                    try backupData.write(to: origDeviceTypeURL)
                } else {
                    guard let data = try? Data(contentsOf: origDeviceTypeURL), let deviceTypeStr = String(data: data, encoding: .utf8), let deviceType = Int(deviceTypeStr) else { throw "Couldn't retrieve original device type" }
                    origDeviceType = deviceType
                }*/
                let origDeviceType: Int = Int(UIScreen.main.nativeBounds.height)
                
                if var firstLevel = plist["CacheExtra"] as? [String : Any], var secondLevel = firstLevel["oPeik/9e8lQWMszEjbPzng"] as? [String: Any], var thirdLevel = secondLevel["ArtworkDeviceSubType"] as? Int {
                    thirdLevel = isEnabled ? 2436 : origDeviceType
                    secondLevel["ArtworkDeviceSubType"] = thirdLevel
                    firstLevel["oPeik/9e8lQWMszEjbPzng"] = secondLevel
                    plist["CacheExtra"] = firstLevel
                }
                
                // Save plist
                let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                try plistData.write(to: url)
                
                UserDefaults.standard.set(isEnabled, forKey: "GesturesEnabled")
            } catch {
                UIApplication.shared.alert(body: "Error occured while applying changes. \(error)")
            }
        }
    }
}

struct GesturesView_Previews: PreviewProvider {
    static var previews: some View {
        GesturesView()
    }
}
