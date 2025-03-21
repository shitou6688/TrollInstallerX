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
    
    // 背景渐变动画状态
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    
    // 星星动画状态
    @State private var stars: [Star] = []
    
    // 星星结构体
    struct Star: Identifiable {
        let id = UUID()
        var position: CGPoint
        var opacity: Double
        var scale: CGFloat
        var animationDuration: Double
        var movementOffset: CGFloat = CGFloat.random(in: -20...20)  // 添加缓慢移动效果
    }
    
    // 生成星星
    func generateStars(in geometry: GeometryProxy) -> [Star] {
        return (0..<40).map { _ in  // 增加星星数量从20到40
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: 0...geometry.size.height / 3)
                ),
                opacity: Double.random(in: 0.1...0.5),
                scale: CGFloat.random(in: 0.5...1.5),
                animationDuration: Double.random(in: 3...6)  // 增加动画持续时间
            )
        }
    }
    
    // 我们不再需要显示助手选择对话框，但保留这个变量以避免改动太多代码
    @ObservedObject var helperView = HelperAlert.shared
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    // 背景颜色定义
    let colors = [
        Color(hex: 0x0466b3).opacity(0.8)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 静态的背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: 0x0466b3)]),  // 略微深一点的蓝色
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 星星动画层
                ForEach(stars.isEmpty ? generateStars(in: geometry) : stars) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .position(
                            x: star.position.x + star.movementOffset,
                            y: star.position.y
                        )
                        .opacity(star.opacity)
                        .scaleEffect(star.scale)
                        .animation(
                            Animation.easeInOut(duration: star.animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: star.opacity
                        )
                        .animation(
                            Animation.easeInOut(duration: 5)  // 添加水平缓慢移动动画
                                .repeatForever(autoreverses: true),
                            value: star.movementOffset
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
                        Text("巨魔安装器")
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
                                .font(.system(size: 24))  // 放大图标
                            Text(device.isSupported ? "执行自动化安装程序" : "您的设备版本不支持")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))  // 放大并加粗字体
                        }
                        .frame(maxWidth: geometry.size.width - 30)  // 略微缩小边距
                        .frame(height: 65)  // 增加高度
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)  // 略微增加圆角
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
