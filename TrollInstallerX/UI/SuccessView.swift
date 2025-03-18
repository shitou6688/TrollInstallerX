//
//  SuccessView.swift
//  TrollInstallerX
//
//  Created on 11/05/2024.
//

import SwiftUI

struct SuccessView: View {
    @Binding var isShowingSuccess: Bool
    let helperAppName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 60))
                .padding(.top, 20)
            
            Text("安装成功！")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("返回桌面查找 TrollStore（大头巨魔）")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("持久性助手已注入到【\(helperAppName)】中")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("感谢您的使用！")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Button {
                withAnimation {
                    isShowingSuccess = false
                }
            } label: {
                Text("确定")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.blue.cornerRadius(10))
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
} 