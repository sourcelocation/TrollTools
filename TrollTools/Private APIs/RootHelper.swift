//
//  RootHelper.swift
//  TrollTools
//
//  Created by exerhythm on 23.10.2022.
//

import UIKit
import NSTaskBridge

class RootHelper {
    static let rootHelperPath = Bundle.main.url(forAuxiliaryExecutable: "trolltoolsroothelper")!.path
    
    static func move(from sourceURL: URL, to destURL: URL) throws {
        let code = spawnRoot(rootHelperPath, ["filemove", sourceURL.path, destURL.path], nil, nil)
        guard code == 0 else { throw "Helper.move: returned non-zero code \(code)" }
    }
    static func copy(from sourceURL: URL, to destURL: URL) throws {
        let code = spawnRoot(rootHelperPath, ["filecopy", sourceURL.path, destURL.path], nil, nil)
        guard code == 0 else { throw "Helper.move: returned non-zero code \(code)" }
    }
    static func createDirectory(at url: URL) throws {
        let code = spawnRoot(rootHelperPath,  ["makedirectory", url.path, ""], nil, nil)
        guard code == 0 else { throw "Helper.move: returned non-zero code \(code)" }
    }
    static func removeItem(at url: URL) throws  {
        let code = spawnRoot(rootHelperPath, ["removeitem", url.path, ""], nil, nil)
        guard code == 0 else { throw "Helper.move: returned non-zero code \(code)" }
    }
    static func permissionset(url: URL) throws {
        let code = spawnRoot(rootHelperPath, ["permissionset", url.path, ""], nil, nil)
        guard code == 0 else { throw "Helper.move: returned non-zero code \(code)" }
    }
}
