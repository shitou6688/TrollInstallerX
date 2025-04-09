//
//  TrollInstallerXApp.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

@main
struct TrollInstallerXApp: App {
    init() {
        // 加载验证插件
        DylibLoader.loadVerificationDylib()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                // Force status bar to be white
                .preferredColorScheme(.dark)
        }
    }
}
