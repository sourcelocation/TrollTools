//
//  TrollToolsApp.swift
//  TrollTools
//
//  Created by exerhythm on 21.10.2022.
//

import SwiftUI

@main
struct TrollToolsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? Double, let url = URL(string: "https://api.github.com/repos/sourcelocation/TrollTools/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if json["tag_name"] as? Double ?? 2.1 > version {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "A new TrollTools update is available, do you want to visit releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/sourcelocation/TrollTools/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                    try? RootHelper.loadMCM()
                }
                .onOpenURL(perform: { url in
                    // for opening passthm files
                    if url.pathExtension.lowercased() == "passthm" {
                        let defaultKeySize = PasscodeKeyFaceManager.getDefaultFaceSize()
                        do {
                            // try appying the themes
                            try PasscodeKeyFaceManager.setFacesFromTheme(url, keySize: CGFloat(defaultKeySize), customX: CGFloat(150), customY: CGFloat(150))
                            // show the passcode screen
                            //PasscodeEditorView()
                            ToolsView().activateView(viewName: "PasscodeEditorView", isActive: true)
                        } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                    }
                })
        }
    }
}

var currentUIAlertController: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }
    func alert(title: String = "Error", body: String, animated: Bool = true, withButton: Bool = true) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { currentUIAlertController?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: currentUIAlertController!)
        }
    }
    func confirmAlert(title: String = "Error", body: String, onOK: @escaping () -> (), noCancel: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel))
            }
            currentUIAlertController?.addAction(.init(title: "OK", style: noCancel ? .cancel : .default, handler: { _ in
                onOK()
            }))
            self.present(alert: currentUIAlertController!)
        }
    }
    func change(title: String = "Error", body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
            // topController should now be your topmost view controller
        }
    }
}
