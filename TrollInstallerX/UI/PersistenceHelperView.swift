//
//  PersistenceHelperView.swift
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

import SwiftUI

struct PersistenceHelperView: View {
    @Binding var isShowingHelperAlert: Bool
    let allowNoPersistenceHelper: Bool
    
    @ObservedObject var helperAlert = HelperAlert.shared
    
    var body: some View {
        ScrollView {
            VStack {
                if !helperAlert.alertMessage.isEmpty {
                    // 错误提示
                    VStack {
                        Text(helperAlert.alertTitle)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                        
                        Text(helperAlert.alertMessage)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    // 原始标题
                    Text("选择一个应用作为持久性助手")
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if allowNoPersistenceHelper {
                        Text("如果您已经安装了持久性助手，请点击底部的"跳过"按钮")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
            
            if helperAlert.alertMessage.isEmpty {
                VStack(spacing: 20) {
                    ForEach(persistenceHelperCandidates, id: \.self) { candidate in
                        Button(action: {
                            TIXDefaults().setValue(candidate.bundleIdentifier, forKey: "persistenceHelper")
                            withAnimation {
                                isShowingHelperAlert = false
                            }
                        }, label: {
                            HStack {
                                if let image = candidate.icon {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .cornerRadius(10)
                                }
                                Text(candidate.displayName)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                Spacer()
                            }
                        })
                    }
                    
                    if allowNoPersistenceHelper {
                        Divider()
                        Button(action: {
                            TIXDefaults().setValue("", forKey: "persistenceHelper")
                            withAnimation {
                                isShowingHelperAlert = false
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "arrow.forward.circle")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .cornerRadius(10)
                                    .foregroundColor(.blue)
                                Text("跳过（已安装持久性助手）")
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                Spacer()
                            }
                        })
                        .padding(.bottom)
                    }
                }
            }
        }
        .onDisappear {
            // 清除错误提示
            helperAlert.alertTitle = ""
            helperAlert.alertMessage = ""
        }
    }
}
