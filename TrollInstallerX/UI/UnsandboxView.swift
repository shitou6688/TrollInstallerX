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
                    .padding()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    grant_full_disk_access({ error in
                        if let error = error {
                            Logger.log("利用 MacDirtyCow 漏洞失败")
                            NSLog("Failed to MacDirtyCow - \(error.localizedDescription)")
                        }
                        withAnimation {
                            isShowingMDCAlert = false
                        }
                    })
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 175, height: 45)
                            .foregroundColor(.white.opacity(0.2))
                            .shadow(radius: 10)
                        Text("安装巨魔")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                    }
                })
                .padding(.vertical)
            }
    }
}
