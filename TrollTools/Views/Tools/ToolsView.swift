//
//  ToolsView.swift
//  TrollTools
//
//  Created by exerhythm on 08.11.2022.
//

import SwiftUI

struct ToolsView: View {
    struct SpringboardOption: Identifiable {
        var value: Bool
        var id = UUID()
        var key: String
        var title: String
        var imageName: String
    }
    
    
    @State var springboardOptions: [SpringboardOption] = [
        .init(value: false, key: "SBShowRSSI", title: "Numeric Wi-Fi Strength", imageName: "wifi"),
        .init(value: false, key: "SBShowGSMRSSI", title: "Numeric Cellular Strength", imageName: "antenna.radiowaves.left.and.right"),
        .init(value: false, key: "SBDontDimOrLockOnAC", title: "Don't dim when charging", imageName: "battery.100.bolt"),
        .init(value: false, key: "SBHideLowPowerAlerts", title: "No Low Battery alerts", imageName: "battery.25"),
        .init(value: false, key: "SBDisableHomeButton", title: "Disable Home Button", imageName: "iphone.homebutton"),
        .init(value: false, key: "SBDontLockEver", title: "Disable Lock Button", imageName: "lock.square"),
        .init(value: false, key: "SBDisableNotificationCenterBlur", title: "Disable Notif Center Blur", imageName: "app.badge"),
        .init(value: false, key: "SBControlCenterEnabledInLockScreen", title: "Lock Screen CC", imageName: "square.grid.2x2"),
        .init(value: false, key: "SBControlCenterDemo", title: "CC AirPlay Radar", imageName: "wifi.circle"),
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: GesturesView()) {
                        HStack {
                            Image(systemName: "iphone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("iPhone X Gestures")
                                .padding(.horizontal, 10)
                        }
                    }
                    NavigationLink(destination: BadgeChangerView()) {
                        HStack {
                            Image(systemName: "app.badge")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Custom Badges")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: PasscodeEditorView()) {
                        HStack {
                            Image(systemName: "ellipsis.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Passcode faces")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: CarrierNameChangerView()) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Custom Carrier Name")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: LockscreenRespringView()) {
                        HStack {
                            Image(systemName: "lock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Locking after Respring")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: CalculatorErrorView()) {
                        HStack {
                            Image(systemName: "function")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Calculator Error Message")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: LSFootnoteChangerView()) {
                        HStack {
                            Image(systemName: "platter.filled.bottom.and.arrow.down.iphone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Lock Screen Footnote")
                                .padding(.horizontal, 8)
                        }
                    }
                } header: {
                    Text("General")
                }
                
                
                Section {
                    ForEach($springboardOptions) { option in
                        HStack {
                            Image(systemName: option.imageName.wrappedValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            
                            Toggle(isOn: option.value) {
                                Text(option.title.wrappedValue)
                                    .minimumScaleFactor(0.5)
                            }.onChange(of: option.value.wrappedValue) { new in
                                do {
                                    try toggleSpringboardOption(key: option.key.wrappedValue, value: new)
                                } catch {
                                    UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                } header: {
                    Text("Experimental")
                } footer: {
                    Text("Last 5 options are not guaranteed to work")
                }
            }
            .navigationTitle("Tools")
            .onAppear {
                for (i, option) in springboardOptions.enumerated() {
//                    springboardOptions[i].value = getSpringboardOption(key: option.key) as? Bool ?? false
                }
            }
        }
    }
    
    func getSpringboardOption(key: String) -> Any? {
        let url = URL(fileURLWithPath: "/var/preferences/com.apple.springboard.plist")
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any]
        
        return plist?["SBDontLockAfterCrash"]
    }
    
    func toggleSpringboardOption(key: String, value: Any) throws {
        let url = URL(fileURLWithPath: "/var/preferences/com.apple.springboard.plist")
        
        var plistData: Data
        if !FileManager.default.fileExists(atPath: url.path) {
            plistData = try PropertyListSerialization.data(fromPropertyList: [key: value], format: .xml, options: 0)
        } else {
            guard let data = try? Data(contentsOf: url), var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read com.apple.springboard.plist" }
            plist[key] = value
            
            // Save plist
            plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        }
        
        // write to file
        try RootHelper.writeStr(String(decoding: plistData, as: UTF8.self), to: url)
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
