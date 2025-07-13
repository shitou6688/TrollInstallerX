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
                        Text("内核下载遇到问题")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Text("内核下载失败或超时，这通常是由于网络问题导致的。\n\n建议按以下步骤操作：\n1. 检查网络连接\n2. 使用VPN（推荐）\n3. 重启设备后重试\n\n点击下方按钮获取VPN工具或重试安装。")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 15) {
                            Button(action: {
                                if let url = URL(string: "https://apps.apple.com/cn/app/%E9%A6%99%E8%95%89%E5%8A%A0%E9%80%9F%E5%99%A8-vpn%E5%85%A8%E7%90%83%E7%BD%91%E7%BB%9C%E5%8A%A0%E9%80%9F%E5%99%A8/id6740848082") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "network")
                                        .font(.system(size: 16))
                                    Text("获取VPN")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                            Button(action: {
                                showKernelTimeoutAlert = false
                                // 可选：触发重试逻辑
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16))
                                    Text("重试安装")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).foregroundColor(.white))
                    .frame(maxWidth: 360)
                    .shadow(radius: 20)
                }
            }
        }
        .onChange(of: logger.logItems) { items in
            if let lastMessage = items.last?.message {
                if lastMessage.contains("长时间无响应") || 
                   lastMessage.contains("下载时间较长") ||
                   lastMessage.contains("所有获取内核缓存的方法都失败了") {
                    withAnimation {
                        showKernelTimeoutAlert = true
                    }
                }
            }
        }
    }
}
