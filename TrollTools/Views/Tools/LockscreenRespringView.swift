//
//  GesturesView.swift
//  TrollTools
//
//  Created by exerhythm on 09.11.2022.
//

import SwiftUI

struct LockscreenRespringView: View {
    @State var enabled = UserDefaults.standard.bool(forKey: "RespringAfterRespringEnabled")
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Text("Disable locking")
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
                        Image("homescreen")
                            .resizable()
                            .aspectRatio(contentMode:. fit)
                    } else {
                        Image("lockscreen")
                            .resizable()
                            .aspectRatio(contentMode:. fit)
                    }
                }
                .frame(maxWidth: proxy.size.width * 0.9)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Respring Locking")
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
                let url = URL(fileURLWithPath: "/var/Managed Preferences/mobile/com.apple.springboard.plist")
                if !FileManager.default.fileExists(atPath: url.path) {
                    let templatePlistURL = Bundle.main.url(forResource: "NoRespring", withExtension: "plist")!
                    try FileManager.default.copyItem(at: templatePlistURL, to: url)
                }
                guard let data = try? Data(contentsOf: url), var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read com.apple.springboard.plist" }
                plist["SBDontLockAfterCrash"] = isEnabled
                
                // Save plist
                let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                try plistData.write(to: url)
                
                UserDefaults.standard.set(isEnabled, forKey: "RespringAfterRespringEnabled")
            } catch {
                UIApplication.shared.alert(body: "Error occured while applying changes. \(error)")
            }
        }
    }
}

struct LockscreenRespringView_Previews: PreviewProvider {
    static var previews: some View {
        LockscreenRespringView()
    }
}
