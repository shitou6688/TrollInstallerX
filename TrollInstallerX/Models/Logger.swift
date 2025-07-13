//
//  Logger.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

enum LogType {
    case success
    case warning
    case error
    case info
}

struct LogItem: Identifiable, Equatable {
    let message: String
    let type: LogType
    let date: Date = Date()
    var id = UUID()
    
    var image: String {
        switch self.type {
        case .success:
            return "checkmark"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark"
        case .info:
            return "info"
        }
    }
    
    var colour: Color {
        switch self.type {
        case .success:
            return .init(hex: 0x08d604)
        case .warning:
            return .yellow
        case .error:
            return .red
        case .info:
            return .white
        }
    }
}

class Logger: ObservableObject {
    @Published var logString: String = ""
    @Published var logItems: [LogItem] = [LogItem]()
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading: Bool = false
    @Published var downloadStatus: String = ""
    
    static var shared = Logger()
    
    static func log(_ logMessage: String, type: LogType? = .info) {
        let newItem = LogItem(message: logMessage, type: type ?? .info)
        print(logMessage)
        UIImpactFeedbackGenerator().impactOccurred()
        DispatchQueue.main.async {
            shared.logItems.append(newItem)
            shared.logString.append(logMessage + "\n")
            shared.logItems.sort(by: { $0.date < $1.date })
        }
    }
    
    static func updateDownloadProgress(_ progress: Double, status: String) {
        DispatchQueue.main.async {
            shared.downloadProgress = progress
            shared.downloadStatus = status
            shared.isDownloading = progress > 0 && progress < 1.0
        }
    }
    
    static func resetDownloadProgress() {
        DispatchQueue.main.async {
            shared.downloadProgress = 0.0
            shared.isDownloading = false
            shared.downloadStatus = ""
        }
    }
}
