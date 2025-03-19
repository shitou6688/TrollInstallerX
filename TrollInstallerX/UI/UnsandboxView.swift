//
//  UnsandboxView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct UnsandboxView: View {
    @Binding var isShowingMDCAlert: Bool
    @State private var isInstalling = false
    @State private var installationStatus = ""
    
    var body: some View {            
        ZStack {
            VStack {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .padding(.top)
                
                Text("巨魔安装器X")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("开发者: Alfie CG")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("iOS 14.0 - 16.6.1")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom)
                
                Text("解除沙盒")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                Text("TrollInstallerX 使用100%可靠的 MacDirtyCow 漏洞来解除沙盒并复制内核缓存。按下下方的按钮运行该漏洞利用程序-您只需要这样操作一次。")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isShowingMDCAlert = false
                        }
                    }) {
                        HStack {
                            Text("不允许")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 175, height: 45)
                        .background(Color.white.opacity(isInstalling ? 0.1 : 0.2))
                        .cornerRadius(10)
                    }
                    .disabled(isInstalling)
                    
                    Button(action: {
                        isInstalling = true
                        installationStatus = "正在解除沙盒..."
                        grant_full_disk_access { error in
                            if let error = error {
                                installationStatus = "解除沙盒失败: \(error.localizedDescription)"
                                Logger.log(installationStatus, type: .error)
                                isInstalling = false
                            } else {
                                installationStatus = "成功解除沙盒"
                                Logger.log(installationStatus, type: .success)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        isShowingMDCAlert = false
                                    }
                                }
                            }
                        }
                    }) {
                        HStack {
                            Text("好")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 175, height: 45)
                        .background(Color.white.opacity(isInstalling ? 0.1 : 0.2))
                        .cornerRadius(10)
                    }
                    .disabled(isInstalling)
                }
                .padding(.vertical)
            }
            
            if isInstalling {
                VStack {
                    Spacer()
                    Text(installationStatus)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                    Spacer()
                }
            }
        }
    }
}
