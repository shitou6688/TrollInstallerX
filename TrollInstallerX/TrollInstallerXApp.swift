//
//  TrollInstallerXApp.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

@main
struct TrollInstallerXApp: App {
    @StateObject private var logger = Logger.sharedInstance()
    @StateObject private var defaults = Defaults.sharedInstance()
    @StateObject private var helperAlert = HelperAlert.sharedInstance()
    
    init() {
        // 确保所有单例在主线程初始化
        DispatchQueue.main.async {
            _ = Logger.sharedInstance()
            _ = Defaults.sharedInstance()
            _ = HelperAlert.sharedInstance()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(logger)
                .environmentObject(defaults)
                .environmentObject(helperAlert)
                // Force status bar to be white
                .preferredColorScheme(.dark)
        }
    }
}
