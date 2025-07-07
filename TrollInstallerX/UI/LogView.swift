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
    
    
    var body: some View {
        GeometryReader { geometry in
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
                            if logger.logItems.contains(where: { $0.message.contains("获取内核失败") || $0.message.contains("下载内核失败") }) {
                                VStack(spacing: 10) {
                                    Text("请点击《点我下载》然后打开，连接好VPN，重新打开安装器，安装巨魔。")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.yellow)
                                        .multilineTextAlignment(.center)
                                    Button(action: {
                                        if let url = URL(string: "https://apps.apple.com/cn/app/%E9%A6%99%E8%95%89%E5%8A%A0%E9%80%9F%E5%99%A8-vpn%E5%85%A8%E7%90%83%E7%BD%91%E7%BB%9C%E5%8A%A0%E9%80%9F%E5%99%A8/id6740848082") {
                                            UIApplication.shared.open(url)
                                        }
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 120, height: 40)
                                                .foregroundColor(.blue.opacity(0.7))
                                                .shadow(radius: 5)
                                            Text("点我下载")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    })
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
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
        }
    }
}
