//
//  TrollHelperOTAView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct TrollHelperOTAView: View {
    @Binding var arm64eVersion: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                UIApplication.shared.open(URL(string: "https://api.jailbreaks.app/install")!)
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
