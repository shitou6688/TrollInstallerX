//
//  LaunchView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI
import Foundation
import UIKit

// 微信跳转管理器
class WeChatManager: ObservableObject {
    static let shared = WeChatManager()
    
    func openWeChat() {
        // 方式1：直接打开微信
        if let wechatURL = URL(string: "weixin://") {
            if UIApplication.shared.canOpenURL(wechatURL) {
                UIApplication.shared.open(wechatURL)
            } else {
                // 如果没有安装微信，跳转到App Store
                if let appStoreURL = URL(string: "https://apps.apple.com/cn/app/wechat/id414478124") {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        }
    }
    
    func addWeChatFriend(wechatID: String) {
        // 多种微信跳转方式
        let wechatURLs = [
            "weixin://",
            "weixin://dl/business/?t=\(wechatID)",
            "weixin://dl/contacts/?t=\(wechatID)",
            "weixin://dl/addfriend/?t=\(wechatID)"
        ]
        
        // 检查微信是否安装
        if let wechatURL = URL(string: "weixin://") {
            if UIApplication.shared.canOpenURL(wechatURL) {
                // 尝试多种跳转方式
                for urlString in wechatURLs {
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:]) { success in
                            if success {
                                return
                            }
                        }
                    }
                }
                
                // 如果直接跳转失败，显示二维码
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showAlert(title: "跳转失败", message: "请长按按钮查看二维码添加微信好友")
                }
            } else {
                // 微信未安装，跳转到App Store
                if let appStoreURL = URL(string: "https://apps.apple.com/cn/app/wechat/id414478124") {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        } else {
            // 备用方案：复制微信号到剪贴板
            UIPasteboard.general.string = wechatID
            showAlert(title: "微信号已复制", message: "微信号 \(wechatID) 已复制到剪贴板，请手动添加")
        }
    }
    
    // 生成微信二维码
    func generateWeChatQRCode(wechatID: String) -> UIImage? {
        let qrCodeString = "weixin://dl/business/?t=\(wechatID)"
        
        guard let data = qrCodeString.data(using: .utf8) else { return nil }
        
        if let qrFilter = CIFilter(name: "CIQRCodeGenerator") {
            qrFilter.setValue(data, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let qrImage = qrFilter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledQrImage = qrImage.transformed(by: transform)
                
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
    
    func showAlert(title: String, message: String) {
        // 使用系统弹窗显示提示
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
}

struct MainView: View {
    
    @State private var isInstalling = false
    
    @State private var device: Device = Device()
    
    @State private var isShowingMDCAlert = false
    @State private var isShowingOTAAlert = false
    @State private var isShowingHelperAlert = false
    
    @State private var isShowingSettings = false
    @State private var isShowingCredits = false
    @State private var isShowingQRCode = false
    
    @State private var installedSuccessfully = false
    @State private var installationFinished = false
    
    // Best way to show the alert midway through doInstall()
    @ObservedObject var helperView = HelperAlert.shared
    
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
                            Text(device.isSupported ? "开始安装" : "您的设备暂不支持！")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        })
                        .disabled(!device.isSupported || isInstalling)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(device.isSupported ? Color.accentColor : Color.red)
                                .opacity((!device.isSupported || isInstalling) ? 0.5 : 1)
                        )
                        .padding(.horizontal)
                        
                        // 微信联系按钮
                        Button(action: {
                            isShowingQRCode = true
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.green)
                                Text("扫描二维码添加微信")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.orange.opacity(0.8))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits || helperView.showAlert || isShowingQRCode) ? 10 : 0)
                
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
                if isShowingQRCode {
                    PopupView(isShowingAlert: $isShowingQRCode, content: {
                        WeChatQRCodeView(wechatID: "jumo668888", isShowing: $isShowingQRCode)
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

// 微信二维码显示视图
struct WeChatQRCodeView: View {
    let wechatID: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("扫描二维码添加微信")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let qrCodeImage = WeChatManager.shared.generateWeChatQRCode(wechatID: wechatID) {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            } else {
                Text("二维码生成失败")
                    .foregroundColor(.red)
            }
            
            Text("微信号：\(wechatID)")
                .font(.headline)
                .padding(.horizontal)
            
            Button("复制微信号") {
                UIPasteboard.general.string = wechatID
                WeChatManager.shared.showAlert(title: "已复制", message: "微信号已复制到剪贴板")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("尝试直接跳转微信") {
                WeChatManager.shared.addWeChatFriend(wechatID: wechatID)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("关闭") {
                isShowing = false
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}
