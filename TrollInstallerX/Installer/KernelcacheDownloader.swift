import Foundation
import CommonCrypto

class KernelcacheDownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = KernelcacheDownloader()
    
    // 多个 kernelcache 下载源（可根据实际情况扩展）
    let sources: [String] = [
        // 例："https://api.ipsw.me/v4/kernelcache/{buildid}/{device}",
        // 例："https://theiphonewiki.com/kernelcache/{buildid}/{device}",
        // 这里可根据实际设备和系统动态拼接
    ]
    
    private var resumeData: Data?
    private var currentSourceIndex = 0
    private var downloadSuccess = false
    private var downloadSemaphore: DispatchSemaphore?
    
    // 下载并保存到指定路径，阻塞直到完成
    func downloadKernelcacheSync(to path: String) -> Bool {
        downloadSuccess = false
        currentSourceIndex = 0
        resumeData = nil
        downloadSemaphore = DispatchSemaphore(value: 0)
        
        // 这里假设 sources 已经根据设备和系统动态拼接好
        guard !sources.isEmpty else {
            Logger.log("未配置 kernelcache 下载源", type: .error)
            return false
        }
        
        downloadFromCurrentSource(to: path)
        downloadSemaphore?.wait()
        return downloadSuccess
    }
    
    private func downloadFromCurrentSource(to path: String, retryCount: Int = 0) {
        guard currentSourceIndex < sources.count else {
            Logger.log("所有 kernelcache 下载源均失败", type: .error)
            downloadSemaphore?.signal()
            return
        }
        let urlString = sources[currentSourceIndex]
        guard let url = URL(string: urlString) else {
            Logger.log("无效的 kernelcache 下载地址", type: .error)
            currentSourceIndex += 1
            downloadFromCurrentSource(to: path)
            return
        }
        Logger.log("正在尝试从源下载 kernelcache: \(urlString)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask
        if let resumeData = resumeData {
            task = session.downloadTask(withResumeData: resumeData)
        } else {
            task = session.downloadTask(with: url)
        }
        task.taskDescription = path
        task.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let path = downloadTask.taskDescription else { return }
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
            }
            try fileManager.moveItem(at: location, to: URL(fileURLWithPath: path))
            // 完整性校验（如有官方 hash，可在此比对）
            // if !verifyKernelcache(path) { ... }
            Logger.log("kernelcache 下载并保存成功", type: .success)
            downloadSuccess = true
            downloadSemaphore?.signal()
        } catch {
            Logger.log("保存 kernelcache 失败: \(error.localizedDescription)", type: .error)
            tryNextSourceOrRetry(path: path)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError?, let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            self.resumeData = resumeData
            Logger.log("下载中断，准备断点续传...", type: .warning)
            // 自动重试断点续传
            downloadFromCurrentSource(to: task.taskDescription ?? "")
        } else if error != nil {
            Logger.log("kernelcache 下载失败: \(error!.localizedDescription)", type: .error)
            tryNextSourceOrRetry(path: task.taskDescription ?? "")
        }
    }
    
    private func tryNextSourceOrRetry(path: String) {
        // 每个源最多重试3次
        if let resumeData = resumeData, resumeData.count > 0 {
            Logger.log("尝试断点续传...", type: .info)
            downloadFromCurrentSource(to: path)
        } else {
            currentSourceIndex += 1
            self.resumeData = nil
            downloadFromCurrentSource(to: path)
        }
    }
    
    // 可选：实现进度回调
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        Logger.log(String(format: "kernelcache 下载进度：%.1f%%", progress * 100))
    }
    
    // 可选：实现 SHA256 校验
    func verifyKernelcache(_ path: String, expectedHash: String? = nil) -> Bool {
        guard let expectedHash = expectedHash else { return true }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return false }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        return hashString == expectedHash
    }
} 