//
//  LaunchView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct Star: View {
    let size: CGFloat
    let opacity: Double
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let animationDuration: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(isAnimating ? 0.2 : opacity)
            .scaleEffect(isAnimating ? 0.5 : 1)
            .position(x: x, y: y)
            .animation(
                .easeInOut(duration: animationDuration)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating.toggle()
            }
    }
}

struct StarfieldView: View {
    let starCount: Int
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(0..<starCount, id: \.self) { _ in
            Star(
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.8),
                color: .white,
                x: CGFloat.random(in: 0...geometry.size.width),
                y: CGFloat.random(in: 0...200),
                animationDuration: Double.random(in: 2...5)
            )
        }
    }
}

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
    
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    
    // 我们不再需要显示助手选择对话框，但保留这个变量以避免改动太多代码
    @ObservedObject var helperView = HelperAlert.shared
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    let colors = [Color(hex: 0x0482d1), Color(hex: 0x0566ed), Color(hex: 0x0450d1)]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 添加动态渐变背景
                LinearGradient(gradient: Gradient(colors: colors), startPoint: gradientStart, endPoint: gradientEnd)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 3), value: gradientStart)
                    .animation(.easeInOut(duration: 3), value: gradientEnd)
                    .onReceive(timer) { _ in
                        withAnimation {
                            self.gradientStart = UnitPoint(x: CGFloat.random(in: -0.5...1.5), y: CGFloat.random(in: -0.5...1.5))
                            self.gradientEnd = UnitPoint(x: CGFloat.random(in: -0.5...1.5), y: CGFloat.random(in: -0.5...1.5))
                        }
                    }
                
                // 添加星星效果
                StarfieldView(starCount: 20, geometry: geometry)
                
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
