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
    // 我们不再使用这个变量，因为现在自动选择持久性助手
    @State private var isShowingHelperAlert = false
    
    @State private var isShowingSettings = false
    @State private var isShowingCredits = false
    
    @State private var installedSuccessfully = false
    @State private var installationFinished = false
    
    // 新的颜色主题
    let gradientColors = [
        Color(hex: 0x3A7CA5),   // 深蓝灰
        Color(hex: 0x5C9EAD),   // 青色
        Color(hex: 0x84B4C4)    // 浅蓝灰
    ]
    
    // 星星动画
    @State private var stars: [Star] = []
    
    // 星星结构体
    struct Star: Identifiable {
        let id = UUID()
        var position: CGPoint
        var opacity: Double
        var scale: CGFloat
        var animationDuration: Double
    }
    
    // 生成星星
    func generateStars(in geometry: GeometryProxy) -> [Star] {
        return (0..<30).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: 0...geometry.size.height / 3)
                ),
                opacity: Double.random(in: 0.2...0.6),
                scale: CGFloat.random(in: 0.6...1.2),
                animationDuration: Double.random(in: 1.5...3.5)
            )
        }
    }
    
    // 我们不再需要显示助手选择对话框，但保留这个变量以避免改动太多代码
    @ObservedObject var helperView = HelperAlert.shared
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let colors = [
        Color(hex: 0x87CEEB).opacity(0.8),   // 顶部浅蓝
        Color(hex: 0x4169E1).opacity(0.7)    // 底部深蓝
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 星星动画
                ForEach(stars.isEmpty ? generateStars(in: geometry) : stars) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .position(star.position)
                        .opacity(star.opacity)
                        .scaleEffect(star.scale)
                        .animation(
                            Animation.easeInOut(duration: star.animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: star.opacity
                        )
                }
                
                VStack(spacing: 20) {
                    // 顶部应用信息
                    VStack(alignment: .center, spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                        
                        Text("巨魔安装器X")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("开发者：Alfie CG")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("iOS 14.0 - 16.6.1")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // 安装日志
                    if isInstalling {
                        LogView(installationFinished: $installationFinished)
                            .frame(maxWidth: geometry.size.width - 40)
                            .frame(height: geometry.size.height / 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    }
                    
                    Spacer()
                    
                    // 安装按钮
                    Button(action: {
                        if !device.isSupported {
                            Logger.log("您的设备版本不支持！", type: .error)
                            return
                        }
                        
                        if !isShowingCredits && !isShowingSettings && !isShowingMDCAlert && !isShowingOTAAlert && !isInstalling {
                            UIImpactFeedbackGenerator().impactOccurred()
                            withAnimation(.spring()) {
                                isInstalling.toggle()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                            Text(device.isSupported ? "执行自动化安装程序" : "您的设备版本不支持")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: geometry.size.width - 40)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(!device.isSupported || isInstalling)
                    .opacity(isInstalling ? 0.5 : 1)
                    .padding(.bottom, 50)
                }
                .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits) ? 10 : 0)
                
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
                        // 不再显示 OTA 弹窗
                        isShowingOTAAlert = false
                        isShowingMDCAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device)
                    }
                }
                Task {
                    await getUpdatedTrollStore()
                }
                stars = generateStars(in: geometry)
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
