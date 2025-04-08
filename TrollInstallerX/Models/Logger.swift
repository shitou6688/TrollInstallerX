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
    
    static var shared = Logger()
    
    static func log(_ logMessage: String, type: LogType? = .info, updateLast: Bool = false) {
        print(logMessage)
        
        DispatchQueue.main.async {
            if updateLast && !shared.logItems.isEmpty {
                // 更新最后一条日志，而不是添加新的
                shared.logItems[shared.logItems.count - 1].id = UUID() // 触发UI刷新
                shared.logItems[shared.logItems.count - 1] = LogItem(message: logMessage, type: type ?? .info)
                
                // 更新日志字符串
                if let lastNewlineIndex = shared.logString.lastIndex(of: "\n") {
                    shared.logString = String(shared.logString[..<lastNewlineIndex]) + "\n" + logMessage + "\n"
                } else {
                    shared.logString = logMessage + "\n"
                }
            } else {
                // 添加新的日志
                let newItem = LogItem(message: logMessage, type: type ?? .info)
                UIImpactFeedbackGenerator().impactOccurred()
                shared.logItems.append(newItem)
                shared.logString.append(logMessage + "\n")
                shared.logItems.sort(by: { $0.date < $1.date })
            }
        }
    }
}
