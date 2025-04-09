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
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                grant_full_disk_access()
                withAnimation {
                    isShowingMDCAlert = false
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
        }
        .padding()
    }
}
