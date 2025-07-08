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
                    VStack(spacing: 18) {
                        Text("网络连接较慢/被阻断")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Text("请点击《点我下载》然后打开，连接好VPN，重新打开安装器，安装巨魔。\n\n如已连接VPN，请点击下方重试。")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 20) {
                            Button(action: {
                                if let url = URL(string: "https://apps.apple.com/cn/app/%E9%A6%99%E8%95%89%E5%8A%A0%E9%80%9F%E5%99%A8-vpn%E5%85%A8%E7%90%83%E7%BD%91%E7%BB%9C%E5%8A%A0%E9%80%9F%E5%99%A8/id6740848082") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("点我下载")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            Button(action: {
                                showKernelTimeoutAlert = false
                                // 可选：触发重试逻辑
                            }) {
                                Text("我已连接VPN，重试安装")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.white))
                    .frame(maxWidth: 340)
                    .shadow(radius: 20)
                }
            }
        }
        .onChange(of: logger.logItems) { items in
            if items.last?.message.contains("长时间无响应") == true {
                withAnimation {
                    showKernelTimeoutAlert = true
                }
            }
            if let lastMsg = items.last?.message, lastMsg.contains("已注入到") || lastMsg.contains("成功安装持久性助手到") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showKernelTimeoutAlert = false
                    UIApplication.shared.windows.first?.rootViewController?.present(
                        UIHostingController(rootView: InjectionSuccessAlert()), animated: true, completion: nil)
                }
            }
        }
    }
}

struct InjectionSuccessAlert: View {
    var body: some View {
        VStack(spacing: 18) {
            Text("注入成功")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            Text("请返回主屏幕，打开刚才被替换的应用以激活 TrollStore。无需注销或重启手机。")
                .font(.system(size: 15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            Button(action: {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }) {
                Text("我知道了")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.white))
        .frame(maxWidth: 340)
        .shadow(radius: 20)
    }
}
