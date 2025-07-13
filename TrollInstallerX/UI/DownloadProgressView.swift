//
//  DownloadProgressView.swift
//  TrollInstallerX
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct DownloadProgressView: View {
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // 下载状态
            HStack {
                Text(downloadManager.downloadStatus)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // 进度条
            VStack(spacing: 8) {
                ProgressView(value: downloadManager.downloadProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                HStack {
                    Text("\(Int(downloadManager.downloadProgress * 100))%")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(downloadManager.downloadedSize) / \(downloadManager.totalSize)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            
            // 下载速度
            if !downloadManager.downloadSpeed.isEmpty {
                HStack {
                    Text("下载速度: \(downloadManager.downloadSpeed)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            

        }
        .padding()
    }
}

struct DownloadProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DownloadProgressView()
        }
    }
} 