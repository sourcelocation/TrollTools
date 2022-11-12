//
//  GesturesView.swift
//  TrollTools
//
//  Created by exerhythm on 09.11.2022.
//

import SwiftUI

struct CalculatorErrorView: View {
    @State var errorMessage = ""
    
    var calculatorBundleURL: URL? = {
        let apps = LSApplicationWorkspace.default().allApplications()!
        return apps.first { $0.applicationIdentifier == "com.apple.calculator" }?.bundleURL
    }()
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            VStack {
                Spacer()
                TextField("Error", text: $errorMessage)
                //                        .placeholder("Placeholder", errorMessage: text.isEmpty)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 24)
                    .font(.system(size: 64))
                    .minimumScaleFactor(0.5)
                    .frame(height: 80)
                    .textFieldStyle(PlainTextFieldStyle())
                Image("calculator")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    do {
                        remLog("hmm?")
                        guard let calculatorBundleURL = calculatorBundleURL, let bundle = Bundle(url: calculatorBundleURL) else { throw "Unable to find calculator app. Maybe you're on an iPad? :troll:" }
                        
                        for code in bundle.localizations {
                            remLog(code, bundle.bundleURL.appendingPathComponent("\(code).lproj/Localizable.strings"))
                            try RootHelper.writeStr("""
                            "COPY_LAST_RESULT_SHORTCUT_ITEM_TITLE"="Copy Last Result";
                            "Error"="\(errorMessage)";
                            """, to: bundle.bundleURL.appendingPathComponent("\(code).lproj/Localizable.strings"))
                            
                        }
                        // Save plist
                        UserDefaults.standard.set(errorMessage, forKey: "CalculatorErrorMessage")
                    } catch {
                        UIApplication.shared.alert(body: "\(error)")
                    }
                    killall("Calculator")
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .onAppear {
            errorMessage = UserDefaults.standard.string(forKey: "CalculatorErrorMessage") ?? ""
        }
    }
}

struct CalculatorErrorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorErrorView()
    }
}
