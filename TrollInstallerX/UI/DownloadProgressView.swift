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
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text(downloadManager.downloadStatus)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // 进度条
            VStack(spacing: 8) {
                ProgressView(value: downloadManager.downloadProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("\(Int(downloadManager.downloadProgress * 100))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(downloadManager.downloadedSize) / \(downloadManager.totalSize)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // 下载速度
            if !downloadManager.downloadSpeed.isEmpty {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    
                    Text("下载速度: \(downloadManager.downloadSpeed)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                    
                    Spacer()
                }
            }
            
            // 取消按钮
            if downloadManager.isDownloading {
                Button(action: {
                    downloadManager.cancelDownload()
                }) {
                    Text("取消下载")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .shadow(radius: 5)
        )
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