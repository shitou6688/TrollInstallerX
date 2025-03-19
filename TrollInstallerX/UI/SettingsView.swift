//
//  SettingsView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct SettingsView: View {
    
    let device: Device
    
    @AppStorage("exploitFlavour", store: TIXDefaults()) var exploitFlavour: String = ""
    @AppStorage("verbose", store: TIXDefaults()) var verbose: Bool = false
    
    // 代理配置
    @State private var proxyHost: String = NetworkConfig.proxyHost ?? ""
    @State private var proxyPort: String = NetworkConfig.proxyPort.map { String($0) } ?? ""
    @State private var isProxyEnabled: Bool = NetworkConfig.proxyHost != nil
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                try? FileManager.default.removeItem(atPath: docsDir.path + "/kernelcache")
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: 225)
                        .frame(maxHeight: 40)
                        .foregroundColor(.white.opacity(0.2))
                        .shadow(radius: 10)
                    Text("清除内核缓存")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                }
            })
            .padding()
            
            if smith.supports(device) || physpuppet.supports(device) {
                Picker("Kernel exploit", selection: $exploitFlavour) {
                    Text("landa").foregroundColor(.white).tag("landa")
                    if smith.supports(device) {
                        Text("smith").foregroundColor(.white).tag("smith")
                    }
                    if physpuppet.supports(device) {
                        Text("physpuppet").foregroundColor(.white).tag("physpuppet")
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.white)
                .padding()
            }
            
            VStack {
                Toggle(isOn: $verbose, label: {
                    Text("详细日志记录")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                })
            }
            .padding()
            
            // 代理配置
            VStack {
                Toggle(isOn: $isProxyEnabled, label: {
                    Text("启用代理")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                })
                
                if isProxyEnabled {
                    TextField("代理地址", text: $proxyHost)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                        .padding()
                    
                    TextField("代理端口", text: $proxyPort)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            if exploitFlavour == "" {
                exploitFlavour = physpuppet.supports(device) ? "physpuppet" : "landa"
            }
        }
        .onChange(of: isProxyEnabled) { newValue in
            if newValue {
                NetworkConfig.proxyHost = proxyHost.isEmpty ? nil : proxyHost
                NetworkConfig.proxyPort = Int(proxyPort)
            } else {
                NetworkConfig.proxyHost = nil
                NetworkConfig.proxyPort = nil
            }
        }
        .onChange(of: proxyHost) { newValue in
            if isProxyEnabled {
                NetworkConfig.proxyHost = newValue.isEmpty ? nil : newValue
            }
        }
        .onChange(of: proxyPort) { newValue in
            if isProxyEnabled {
                NetworkConfig.proxyPort = Int(newValue)
            }
        }
    }
}
