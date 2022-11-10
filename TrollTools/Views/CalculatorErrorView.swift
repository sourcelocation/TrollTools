//
//  GesturesView.swift
//  TrollTools
//
//  Created by exerhythm on 09.11.2022.
//

import SwiftUI

struct CalculatorErrorView: View {
    @State var errorMessage = UserDefaults.standard.string(forKey: "CalculatorErrorMessage") ?? "aaa"
    
    var calculatorBundleURL: URL? = {
        let apps = LSApplicationWorkspace.default().allApplications()!
        return apps.first { $0.applicationIdentifier == "com.apple.calculator" }?.bundleURL
    }()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                VStack {
                    TextField("Error", text: $errorMessage)
//                        .placeholder("Placeholder", errorMessage: text.isEmpty)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 24)
                        .font(.system(size: 64))
                        .minimumScaleFactor(0.5)
                        .frame(height: 80)
                    Image("calculator")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: proxy.size.width)
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    respring()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onChange(of: errorMessage) { newErrorMessage in
            do {
                remLog("hmm?")
                guard let bundle = Bundle(url: calculatorBundleURL!) else { throw "Unable to find bundle. Maybe you're on an iPad? :troll:" }
                
                for code in bundle.localizations {
                    remLog(code, bundle.bundleURL.appendingPathComponent("\(code).lproj/Localizable.strings"))
                    try RootHelper.writeStr(String(contentsOf: Bundle.main.url(forResource: "CalculatorLocalizable", withExtension: "strings")!), to: bundle.bundleURL.appendingPathComponent("\(code).lproj/Localizable.strings"))
                    
                }
                // Save plist
                UserDefaults.standard.set(newErrorMessage, forKey: "CalculatorErrorMessage")
            } catch {
                UIApplication.shared.alert(body: "Error occured while applying changes. \(error)")
            }
        }
    }
}

struct CalculatorErrorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorErrorView()
    }
}
