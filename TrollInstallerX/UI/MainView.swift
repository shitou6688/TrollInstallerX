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
    
    // 星星动画状态
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
        return (0..<20).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: 0...geometry.size.height / 2)
                ),
                opacity: Double.random(in: 0.1...0.5),
                scale: CGFloat.random(in: 0.5...1.5),
                animationDuration: Double.random(in: 1...3)
            )
        }
    }
    
    // 我们不再需要显示助手选择对话框，但保留这个变量以避免改动太多代码
    @ObservedObject var helperView = HelperAlert.shared
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let colors = [Color(hex: 0x0482d1), Color(hex: 0x0566ed), Color(hex: 0x0450d1)]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 静态背景渐变
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 星星动画层
                ForEach(stars.isEmpty ? generateStars(in: geometry) : stars) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
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
                
                VStack {
                    // 顶部图标和标题固定显示
                    VStack {
                        Image("Icon")
                            .resizable()
                            .cornerRadius(22)
                            .frame(maxWidth: 100, maxHeight: 100)
                            .shadow(radius: 10)
                        Text("巨魔安装器X")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text("开发者：Alfie CG")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        Text("iOS 14.0 - 16.6.1")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // 安装状态显示（如果正在安装）
                    if isInstalling {
                        LogView(installationFinished: $installationFinished)
                            .frame(maxWidth: geometry.size.width - 40)
                            .frame(maxHeight: geometry.size.height / 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    // 底部按钮始终显示
                    Button(action: {
                        if !device.isSupported {
                            Logger.log("您的设备版本不支持！", type: .error)
                            return
                        }
                        
                        if !isShowingCredits && !isShowingSettings && !isShowingMDCAlert && !isShowingOTAAlert && !isInstalling {
                            UIImpactFeedbackGenerator().impactOccurred()
                            withAnimation {
                                isInstalling.toggle()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.white)
                            Text(device.isSupported ? "执行自动化安装程序" : "您的设备版本不支持")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: geometry.size.width - 40)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .disabled(!device.isSupported || isInstalling)
                    .opacity(isInstalling ? 0.5 : 1)
                    .padding(.bottom, 50)
                }
                .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits || helperView.showAlert) ? 10 : 0)
                
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
