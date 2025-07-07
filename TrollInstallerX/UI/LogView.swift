import SwiftUI

struct StdoutLog: Identifiable, Equatable {
    let message: String
    let id = UUID()
}

struct LogView: View {
    @StateObject var logger = Logger.shared
    @Binding var installationFinished: Bool
    
    @AppStorage("verbose", store: TIXDefaults()) var verbose: Bool = false
    
    let pipe = Pipe()
    let sema = DispatchSemaphore(value: 0)
    @State private var stdoutString = ""
    @State private var stdoutItems = [StdoutLog]()
    
    @State var verboseID = UUID()
    
    @State private var showKernelTimeoutAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        if verbose {
                            ForEach(stdoutItems) { item in
                                HStack {
                                    Text(item.message)
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.white)
                                        .id(item.id)
                                    Spacer()
                                }
                                .frame(width: geometry.size.width)
                            }
                            
                            .onChange(of: stdoutItems) { _ in
                                DispatchQueue.main.async {
                                    proxy.scrollTo(stdoutItems.last!.id, anchor: .bottom)
                                }
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Spacer()
                                ForEach(logger.logItems) { log in
                                    HStack {
                                        Label(
                                            title: {
                                                Text(log.message)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .shadow(radius: 2)
                                            },
                                            icon: {
                                                Image(systemName: log.image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 12, height: 12)
                                                    .padding(.trailing, 5)
                                            }
                                        )
                                        .foregroundColor(log.colour)
                                        .padding(.vertical, 5)
                                        .transition(AnyTransition.asymmetric(
                                            insertion: .move(edge: .bottom),
                                            removal: .move(edge: .top)
                                        ))
                                        Spacer()
                                    }
                                }
                            }
                            .onChange(of: geometry.size.height) { newHeight in
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
                                    }
                                }
                            }
                            
                            .onChange(of: logger.logItems) { _ in
                                DispatchQueue.main.async {
                                    proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onAppear {
                        if verbose {
                            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                                let data = fileHandle.availableData
                                if data.isEmpty  { // end-of-file condition
                                    fileHandle.readabilityHandler = nil
                                    sema.signal()
                                } else {
                                    stdoutString += String(data: data, encoding: .utf8)!
                                    stdoutItems.append(StdoutLog(message: String(data: data, encoding: .utf8)!))
                                }
                            }
                            // Redirect
                            print("Redirecting stdout")
                            setvbuf(stdout, nil, _IONBF, 0)
                            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                        }
                    }
                }
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = verbose ? stdoutString : Logger.shared.logString
                    } label: {
                        Label("复制到剪贴板", systemImage: "doc.on.doc")
                    }
                }
                if showKernelTimeoutAlert {
                    ZStack {
                        // 半透明磨砂背景
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .frame(maxWidth: 360, maxHeight: 260)
                            .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 10)
                        VStack(spacing: 22) {
                            Text("网络连接较慢/被阻断")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x0482d1), Color(hex: 0x0566ed)]), startPoint: .leading, endPoint: .trailing))
                                .padding(.top, 10)
                            Text("请点击《点我下载》然后打开，连接好VPN，重新打开安装器，安装巨魔。\n\n如已连接VPN，请点击下方重试。")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.92))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                            HStack(spacing: 22) {
                                Button(action: {
                                    if let url = URL(string: "https://apps.apple.com/cn/app/%E9%A6%99%E8%95%89%E5%8A%A0%E9%80%9F%E5%99%A8-vpn%E5%85%A8%E7%90%83%E7%BD%91%E7%BB%9C%E5%8A%A0%E9%80%9F%E5%99%A8/id6740848082") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("点我下载")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color(hex: 0x0482d1), Color(hex: 0x0566ed)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                Button(action: {
                                    showKernelTimeoutAlert = false
                                }) {
                                    Text("我已连接VPN，重试安装")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: Color.green.opacity(0.18), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 340)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                }
            }
        }
        .onChange(of: logger.logItems) { items in
            if items.last?.message.contains("长时间无响应") == true {
                withAnimation {
                    showKernelTimeoutAlert = true
                }
            }
        }
    }
}

// 新增：简易缩放按钮样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
