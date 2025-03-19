//
//  TrollInstallerXApp.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI
import UIKit

@main
struct TrollInstallerXApp: App {
    init() {
        // 配置应用界面
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            // 隐藏状态栏
            windowScene.windows.first?.windowLevel = .statusBar
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .ignoresSafeArea()
                .statusBar(hidden: true)
        }
    }
}
