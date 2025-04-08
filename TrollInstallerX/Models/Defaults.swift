//
//  Defaults.swift
//  TrollInstallerX
//
//  Created by Alfie on 31/03/2024.
//

import Foundation
import SwiftUI

public class Defaults: ObservableObject {
    private static var shared: Defaults?
    private static let lock = NSLock()
    
    @Published var verbose: Bool = false
    
    private init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            "verbose": false,
        ])
        self.verbose = defaults.bool(forKey: "verbose")
    }
    
    public static func sharedInstance() -> Defaults {
        lock.lock()
        defer { lock.unlock() }
        
        if shared == nil {
            shared = Defaults()
        }
        return shared!
    }
    
    func setVerbose(_ value: Bool) {
        verbose = value
        UserDefaults.standard.set(value, forKey: "verbose")
    }
}
