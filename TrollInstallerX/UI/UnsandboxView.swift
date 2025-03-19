//
//  UnsandboxView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct UnsandboxView: View {
    @Binding var isShowingMDCAlert: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("解除沙盒")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("TrollInstallerX 使用100%可靠的 MacDirtyCow 漏洞来解除沙盒并复制内核缓存。按下下方的按钮运行该漏洞利用程序-您只需要这样操作一次。")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                grant_full_disk_access({ error in
                    if let error = error {
                        Logger.log("利用 MacDirtyCow 漏洞失败")
                        NSLog("Failed to MacDirtyCow - \(error.localizedDescription)")
                    }
                    withAnimation {
                        isShowingMDCAlert = false
                    }
                })
            }) {
                Text("解除沙盒")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(hex: 0x0482d1)
                .edgesIgnoringSafeArea(.all)
        )
    }
}
