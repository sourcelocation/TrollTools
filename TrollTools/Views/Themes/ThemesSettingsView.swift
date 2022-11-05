//
//  ThemeSettingsView.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import SwiftUI

//struct ThemesSettingsView: View {
//    @State var hidesLabels = UserDefaults.standard.bool(forKey: "hidesLabels")
//
//    @Environment(\.horizontalSizeClass) var sizeClass
//    
//
//    var body: some View {
//        List {
//            Toggle(isOn: $hidesLabels) {
//                Text("Hide WebClip Labels")
//            }
//            .onChange(of: hidesLabels, perform: { new in
//                UserDefaults.standard.set(new, forKey: "hidesLabels")
//                do {
//                    try WebclipsThemeManager.changeLabelVisibility(visible: !hidesLabels)
//                    respring()
//                } catch {
//                    UIApplication.shared.alert(body: error.localizedDescription)
//                }
//            })
////            Button("Change theming method") {
////                showsMethodChoosingPopover = true
////            }
////            .fullScreenCover(isPresented: $showsMethodChoosingPopover) {
////                ThemesMethodChoosingView()
////            }
//        }
//        .listStyle(PlainListStyle())
//        .frame(minWidth: 300, minHeight: 200)
//    }
//}
//
//struct ThemesSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemesSettingsView()
//    }
//}
