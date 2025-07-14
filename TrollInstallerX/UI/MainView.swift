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
    @State private var isShowingHelp = false
    
    @State private var installedSuccessfully = false
    @State private var installationFinished = false
    
    // Best way to show the alert midway through doInstall()
    @ObservedObject var helperView = HelperAlert.shared
    
    // 打开微信函数
    func openWeChat() {
        let wechatID = "jumo668888"
        
        // 显示微信号供用户复制
        let alert = UIAlertController(title: "微信联系", message: "微信号: \(wechatID)\n请复制微信号到微信中搜索添加", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "复制微信号", style: .default) { _ in
            UIPasteboard.general.string = wechatID
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 获取当前视图控制器来显示alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    // 从帮助弹窗打开微信函数
    func openWeChatFromHelp() {
        let wechatID = "jumo668888"
        
        // 显示微信号供用户复制
        let alert = UIAlertController(title: "微信联系", message: "微信号: \(wechatID)\n请复制微信号到微信中搜索添加", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "复制微信号", style: .default) { _ in
            UIPasteboard.general.string = wechatID
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 获取当前视图控制器来显示alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(colors: [Color(hex: 0x0482d1), Color(hex: 0x0566ed)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                // 主界面内容
                VStack {
                    Spacer()
                    
                    // 图标
                    Image("Icon")
                        .resizable()
                        .cornerRadius(22)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 10)
                    
                    // 标题和信息
                    Text("巨魔安装器")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Text("iOS 14.0 - 16.6.1")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
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
                                        .foregroundColor(.white.opacity(0.15))
                                        .shadow(radius: 10)
                                )
                            
                            if installationFinished && installedSuccessfully && device.supportsDirectInstall {
                                Text("巨魔已安装成功，返回桌面查找大头巨魔！")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.green)
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
                            HStack(spacing: 12) {
                                Image(systemName: device.isSupported ? "arrow.down.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.isSupported ? "开始安装" : "您的设备暂不支持！")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    if device.isSupported {
                                        Text("一键安装巨魔商店")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                        })
                        .disabled(!device.isSupported || isInstalling)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: device.isSupported ? 
                                            [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)] : 
                                            [Color.red.opacity(0.8), Color.red.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: device.isSupported ? Color(hex: 0xFF6B35).opacity(0.4) : Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .scaleEffect((!device.isSupported || isInstalling) ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: device.isSupported)
                        .padding(.horizontal)
                        
                        // 帮助说明按钮
                        Button(action: {
                            isShowingHelp = true
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                Text("帮助说明")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.8))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits || isShowingHelp || helperView.showAlert) ? 10 : 0)
                
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
                if isShowingHelp {
                    PopupView(isShowingAlert: $isShowingHelp, content: {
                        HelpView(onContactWeChat: openWeChatFromHelp)
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

struct HelpView: View {
    let onContactWeChat: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("帮助说明")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                // 联系客服按钮
                Button(action: {
                    onContactWeChat()
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        Text("联系客服微信: jumo668888")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.8))
                    )
                }
                // 安装巨魔流程
                Button(action: {
                    if let url = URL(string: "https://www.yuque.com/yuqueyonghuroiej0/mucqna/dw7pbxhuc234vzl9?singleDoc#") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("安装巨魔流程")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // 巨魔使用教程
                Button(action: {
                    if let url = URL(string: "https://www.yuque.com/yuqueyonghuroiej0/mucqna/wdnqeac20vyq2vq5?singleDoc#") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                        Text("巨魔使用教程")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // 游戏科技介绍
                Button(action: {
                    if let url = URL(string: "https://www.yuque.com/yuqueyonghuroiej0/mucqna/gpe6use6a4k5qw79?singleDoc#") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                        Text("游戏科技介绍")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: 350, maxHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 20)
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
