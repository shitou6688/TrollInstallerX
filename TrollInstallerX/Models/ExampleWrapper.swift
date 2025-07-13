import Foundation

// 导入C头文件
import example

/// Example库的Swift包装类
class ExampleWrapper {
    static let shared = ExampleWrapper()
    
    private var isInitialized = false
    
    private init() {}
    
    // MARK: - 初始化
    
    /// 初始化库
    /// - Returns: 是否初始化成功
    func initialize() -> Bool {
        guard !isInitialized else {
            return true // 已经初始化过了
        }
        
        let result = example_init()
        isInitialized = (result == 0)
        
        if isInitialized {
            print("✅ Example库初始化成功")
        } else {
            print("❌ Example库初始化失败，错误码: \(result)")
        }
        
        return isInitialized
    }
    
    // MARK: - 主要功能
    
    /// 处理输入数据
    /// - Parameter input: 输入字符串
    /// - Returns: 处理结果，失败时返回nil
    func process(input: String) -> String? {
        guard isInitialized else {
            print("❌ 库未初始化，请先调用initialize()")
            return nil
        }
        
        let inputCString = input.cString(using: .utf8)
        let outputSize = 1024
        let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: outputSize)
        defer {
            outputBuffer.deallocate()
        }
        
        guard let inputCString = inputCString else {
            print("❌ 输入字符串转换失败")
            return nil
        }
        
        let result = example_process(inputCString, outputBuffer, outputSize)
        
        if result == 0 {
            let outputString = String(cString: outputBuffer)
            print("✅ 处理成功: \(outputString)")
            return outputString
        } else {
            print("❌ 处理失败，错误码: \(result)")
            return nil
        }
    }
    
    /// 获取库版本信息
    /// - Returns: 版本信息，失败时返回nil
    func getVersion() -> String? {
        guard isInitialized else {
            print("❌ 库未初始化，请先调用initialize()")
            return nil
        }
        
        let bufferSize = 256
        let versionBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer {
            versionBuffer.deallocate()
        }
        
        let result = example_get_version(versionBuffer, bufferSize)
        
        if result == 0 {
            let versionString = String(cString: versionBuffer)
            print("📋 版本信息: \(versionString)")
            return versionString
        } else {
            print("❌ 获取版本失败，错误码: \(result)")
            return nil
        }
    }
    
    // MARK: - 清理
    
    /// 清理资源
    func cleanup() {
        guard isInitialized else {
            return // 未初始化，无需清理
        }
        
        example_cleanup()
        isInitialized = false
        print("🧹 Example库资源已清理")
    }
    
    // MARK: - 便捷方法
    
    /// 检查库是否已初始化
    var initialized: Bool {
        return isInitialized
    }
}

// MARK: - 使用示例

extension ExampleWrapper {
    /// 完整的使用示例
    func exampleUsage() {
        print("🚀 开始使用Example库...")
        
        // 1. 初始化
        guard initialize() else {
            print("❌ 初始化失败，无法继续")
            return
        }
        
        // 2. 获取版本信息
        if let version = getVersion() {
            print("📋 当前版本: \(version)")
        }
        
        // 3. 处理数据
        let testInput = "Hello from Swift!"
        if let result = process(input: testInput) {
            print("✅ 处理结果: \(result)")
        }
        
        // 4. 清理资源
        cleanup()
        
        print("🎉 Example库使用完成")
    }
    
    /// 批量处理示例
    func batchProcess(inputs: [String]) -> [String] {
        guard initialize() else {
            print("❌ 初始化失败")
            return []
        }
        
        defer {
            cleanup()
        }
        
        var results: [String] = []
        
        for (index, input) in inputs.enumerated() {
            print("🔄 处理第\(index + 1)个输入: \(input)")
            
            if let result = process(input: input) {
                results.append(result)
            } else {
                results.append("处理失败")
            }
        }
        
        return results
    }
} 