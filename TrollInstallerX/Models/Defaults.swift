//
//  Defaults.swift
//  TrollInstallerX
//
//  Created by Alfie on 31/03/2024.
//

import Foundation

var tixUserDefaults: UserDefaults? = nil
public func TIXDefaults() -> UserDefaults {
    if tixUserDefaults == nil {
        tixUserDefaults = UserDefaults.standard
        tixUserDefaults!.register(defaults: [
            "verbose": false,
        ])
    }
    return tixUserDefaults!
}
