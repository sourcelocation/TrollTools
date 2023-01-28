//
//  Respring.swift
//  TrollTools
//
//  Created by sourcelocation on 28/01/2023.
//

import UIKit

func respring() {
    #if targetEnvironment(simulator)
    #else
    guard let window = UIApplication.shared.windows.first else { return }
    while true {
        window.snapshotView(afterScreenUpdates: false)
    }
    
    #endif
}
