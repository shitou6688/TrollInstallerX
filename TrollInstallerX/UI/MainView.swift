//
//  LaunchView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct MainView: View {
    
    @State private var isInstalling = false
    
    @State private var device: Device = Device()
    
    @State private var isShowingMDCAlert = false
    @State private var isShowingOTAAlert = false
    @State private var isShowingHelperAlert = false
    
    @State private var isShowingSettings = false
    @State private var isShowingCredits = false
    
    @State private var installedSuccessfully = false
    @State private var installationFinished = false
    
    // Best way to show the alert midway through doInstall()
    @ObservedObject var helperView = HelperAlert.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(colors: [
                    Color(hex: 0xE8F5E9),  // 浅绿色
                    Color(hex: 0xC8E6C9),  // 薄荷绿
                    Color(hex: 0xA5D6A7)   // 春绿色
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                // 背景装饰
                Circle()
                    .fill(Color(hex: 0x81C784).opacity(0.2))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -200)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: 0x66BB6A).opacity(0.2))
                    .frame(width: 300, height: 300)
                    .offset(x: 100, y: 200)
                    .blur(radius: 50)
                
                // 主界面内容
                VStack {
                    Spacer()
                    
                    // 图标
                    Image("Icon")
                        .resizable()
                        .cornerRadius(22)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // 标题和信息
                    Text("巨魔安装器")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: 0x2E7D32))
                        .padding(.top, 10)
                    
                    Text("iOS 14.0 - 16.6.1")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: 0x2E7D32).opacity(0.7))
                        .padding(.top, 1)
                    
                    Spacer()
                    
                    // 安装状态或按钮
                    if isInstalling {
                        VStack {
                            LogView(installationFinished: $installationFinished)
                                .padding()
                                .frame(maxWidth: geometry.size.width / 1.2)
                                .frame(maxHeight: geometry.size.height / 1.75)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                            
                            if installationFinished && installedSuccessfully && device.supportsDirectInstall {
                                Text("巨魔已安装成功，返回桌面查找大头巨魔！")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: 0x2E7D32))
                                    .padding(.top, 10)
                            }
                        }
                    } else {
                        Button(action: {
                            if !isShowingCredits && !isShowingSettings && !isShowingMDCAlert && !isShowingOTAAlert {
                                UIImpactFeedbackGenerator().impactOccurred()
                                withAnimation {
                                    isInstalling.toggle()
                                }
                            }
                        }, label: {
                            Text(device.isSupported ? "开始安装" : "您的设备暂不支持！")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        })
                        .disabled(!device.isSupported || isInstalling)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(device.isSupported ? Color(hex: 0x43A047) : Color(hex: 0xE53935))
                                .opacity((!device.isSupported || isInstalling) ? 0.5 : 1)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits || helperView.showAlert) ? 10 : 0)
                
                // 弹窗
                if isShowingOTAAlert {
                    PopupView(isShowingAlert: $isShowingOTAAlert, content: {
                        TrollHelperOTAView(arm64eVersion: .constant(false))
                    })
                }
                if isShowingMDCAlert {
                    PopupView(isShowingAlert: $isShowingMDCAlert, shouldAllowDismiss: false, content: {
                        UnsandboxView(isShowingMDCAlert: $isShowingMDCAlert)
                    })
                }
                if isShowingSettings {
                    PopupView(isShowingAlert: $isShowingSettings, content: {
                        SettingsView(device: device)
                    })
                }
                if isShowingCredits {
                    PopupView(isShowingAlert: $isShowingCredits, content: {
                        CreditsView()
                    })
                }
                if helperView.showAlert {
                    PopupView(isShowingAlert: $isShowingHelperAlert, shouldAllowDismiss: false, content: {
                        PersistenceHelperView(isShowingHelperAlert: $isShowingHelperAlert, allowNoPersistenceHelper: device.supportsDirectInstall)
                    })
                }
            }
            // Hacky, but it works (can't pass helperView.showAlert as a binding variable)
            .onChange(of: helperView.showAlert) { new in
                if new {
                    withAnimation {
                        isShowingHelperAlert = true
                    }
                }
            }
            .onChange(of: isShowingHelperAlert) { new in
                if !new {
                    helperView.showAlert = false
                }
            }
            .onChange(of: isInstalling) { _ in
                Task {
                    if device.isSupported {
                        if device.supportsDirectInstall {
                            installedSuccessfully = await doDirectInstall(device)
                        } else {
                            installedSuccessfully = await doIndirectInstall(device)
                        }
                        installationFinished = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(installedSuccessfully ? .success : .error)
                }
            }
            .onChange(of: isShowingOTAAlert) { new in
                if !new {
                    withAnimation {
                        isShowingMDCAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device)
                    }
                }
            }
            .onAppear {
                if device.isSupported {
                    withAnimation {
                        isShowingOTAAlert = device.supportsOTA
                        if !isShowingOTAAlert { isShowingMDCAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device) }
                    }
                }
                Task {
                    await getUpdatedTrollStore()
                }
            }
            .onChange(of: isShowingOTAAlert) { _ in
                if !checkForMDCUnsandbox() && MacDirtyCow.supports(device) && !isShowingOTAAlert && device.supportsOTA { // User has just dismissed alert
                    withAnimation {
                        isShowingMDCAlert = true
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
