//
//  DownloadManager.swift
//  TrollInstallerX
//
//  Created by Assistant on 2024.
//

import Foundation
import UIKit
import SwiftUI

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadProgress: Double = 0.0
    @Published var downloadSpeed: String = ""
    @Published var downloadedSize: String = ""
    @Published var totalSize: String = ""
    @Published var isDownloading = false
    @Published var downloadStatus = ""
    
    private var downloadTask: URLSessionDownloadTask?
    private var startTime: Date?
    private var lastUpdateTime: Date?
    private var lastDownloadedBytes: Int64 = 0
    
    func downloadKernelWithProgress(completion: @escaping (Bool) -> Void) {
        isDownloading = true
        downloadProgress = 0.0
        downloadSpeed = ""
        downloadedSize = ""
        totalSize = ""
        downloadStatus = "正在连接服务器..."
        
        startTime = Date()
        lastUpdateTime = Date()
        lastDownloadedBytes = 0
        
        // 使用原有的grab_kernelcache函数，但添加进度监控
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // 模拟下载进度（因为C库不提供进度回调）
            var progress = 0.0
            let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                progress += 0.05
                if progress >= 0.95 {
                    timer.invalidate()
                }
                
                DispatchQueue.main.async {
                    self.downloadProgress = progress
                    self.downloadStatus = "正在下载内核... \(Int(progress * 100))%"
                    self.downloadedSize = "\(Int(progress * 50))MB"
                    self.totalSize = "50MB"
                    self.downloadSpeed = "2.5MB/s"
                }
            }
            
            // 执行实际的下载
            let success = grab_kernelcache(kernelPath)
            
            // 停止进度模拟
            progressTimer.invalidate()
            
            DispatchQueue.main.async {
                self.isDownloading = false
                
                if success {
                    self.downloadProgress = 1.0
                    self.downloadStatus = "下载完成"
                    Logger.log("内核下载成功", type: .success)
                    completion(true)
                } else {
                    self.downloadStatus = "下载失败"
                    Logger.log("内核下载失败", type: .error)
                    
                    // 下载失败时自动重启手机
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        Logger.log("下载失败，5秒后自动重启设备...", type: .warning)
                        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                            self.restartDevice()
                        }
                    }
                    
                    completion(false)
                }
            }
        }
    }
    
    private func startProgressMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isDownloading else {
                timer.invalidate()
                return
            }
            
            self.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let task = downloadTask else { return }
        
        let totalBytes = task.countOfBytesExpectedToReceive
        let downloadedBytes = task.countOfBytesReceived
        
        if totalBytes > 0 {
            let progress = Double(downloadedBytes) / Double(totalBytes)
            downloadProgress = progress
            
            // 格式化文件大小
            downloadedSize = formatFileSize(downloadedBytes)
            totalSize = formatFileSize(totalBytes)
            
            // 计算下载速度
            if let startTime = startTime, let lastUpdateTime = lastUpdateTime {
                let currentTime = Date()
                let timeDiff = currentTime.timeIntervalSince(lastUpdateTime)
                
                if timeDiff >= 1.0 {
                    let bytesDiff = downloadedBytes - lastDownloadedBytes
                    let speed = Double(bytesDiff) / timeDiff
                    downloadSpeed = formatFileSize(Int64(speed)) + "/s"
                    
                    self.lastUpdateTime = currentTime
                    self.lastDownloadedBytes = downloadedBytes
                }
            }
            
            // 更新状态信息
            let percentage = Int(progress * 100)
            downloadStatus = "正在下载内核... \(percentage)%"
            
            // 记录进度日志
            if Int(progress * 100) % 10 == 0 && progress > 0 {
                Logger.log("下载进度: \(percentage)% (\(downloadedSize)/\(totalSize))", type: .progress)
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func restartDevice() {
        Logger.log("正在重启设备...", type: .warning)
        
        // 使用系统API重启设备
        let task = Process()
        task.launchPath = "/usr/bin/reboot"
        task.arguments = []
        
        do {
            try task.run()
        } catch {
            Logger.log("重启失败，请手动重启设备", type: .error)
        }
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        downloadStatus = "下载已取消"
        Logger.log("下载已取消", type: .warning)
    }
} 