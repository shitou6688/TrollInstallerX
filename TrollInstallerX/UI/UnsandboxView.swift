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
        VStack {
            Text("解除沙盒")
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            Text("TrollInstallerX 使用100%可靠的 MacDirtyCow 漏洞来解除沙盒并复制内核缓存。按下下方的按钮运行该漏洞利用程序-您只需要这样操作一次。")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                
                // 使用新的权限请求方式
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:]) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // 延迟执行 MacDirtyCow 操作，给用户时间进行授权
                            grant_full_disk_access({ error in
                                if let error = error {
                                    Logger.log("利用 MacDirtyCow 漏洞失败，请重试")
                                    Logger.log("错误信息：\(error.localizedDescription)", type: .error)
                                } else {
                                    Logger.log("成功获取权限", type: .success)
                                    withAnimation {
                                        isShowingMDCAlert = false
                                    }
                                }
                            })
                        }
                    }
                } else {
                    Logger.log("无法打开系统设置", type: .error)
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 175, height: 45)
                        .foregroundColor(.white.opacity(0.2))
                        .shadow(radius: 10)
                    Text("解除沙盒")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                }
            })
            .padding(.vertical)
        }
    }
}
