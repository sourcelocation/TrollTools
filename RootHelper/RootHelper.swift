//
//  RootHelper.swift
//  RootHelper
//
//  Created by exerhythm on 24.10.2022.
//

// import Foundation

// struct StringError: Error, LocalizedError, CustomStringConvertible {
//     let description: String

//     init(_ description: String) {
//         self.description = description
//     }

//     var errorDescription: String? {
//         self.description
//     }
// }


// @main
// struct RootHelper {
//     static func main() throws {
//         print("Hello!")
//         try getRoot()
//         let mcmBundle = Bundle(path: "/System/Library/PrivateFrameworks/MobileContainerManager.framework")
//         mcmBundle?.load()
        
//         try FileManager.default.moveItem(at: URL(fileURLWithPath: "/var/mobile/test0"), to: URL(fileURLWithPath: "/var/mobile/test1"))
//     }
    
//     static func getRoot() throws {
//         setuid(0)
//         setgid(0)

//         guard getuid() == 0 else {
//             throw StringError("ROOT HELPER ERROR: Unable to get root.")
//         }
//     }
// }
