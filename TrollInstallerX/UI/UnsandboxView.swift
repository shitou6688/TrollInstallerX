//
//  UnsandboxView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct UnsandboxView: View {
    @Binding var isShowingMDCAlert: Bool
    
    var body: some View {
        VStack {
            Text("解除沙盒")
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(0) // 隐藏标题
            
            Text("TrollInstallerX 使用100%可靠的\nMacDirtyCow 漏洞来解除沙盒并复制内\n核缓存，按下下方的按钮运行该漏洞利\n用程序-您只需要这样操作一次。")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(0) // 隐藏说明文字
            
            Button(action: {
                grant_full_disk_access { success in
                    if success {
                        withAnimation {
                            isShowingMDCAlert = false
                        }
                    }
                }
            }, label: {
                Text("安装巨魔")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            })
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.accentColor)
            )
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
    }
}
