import Foundation

// 导入C头文件
import mylib

class MyLibWrapper {
    static let shared = MyLibWrapper()
    
    private init() {}
    
    // 初始化dylib
    func initialize() -> Bool {
        let result = mylib_init()
        return result == 0 // 假设0表示成功
    }
    
    // 调用dylib功能
    func doSomething(input: String) -> String? {
        let inputCString = input.cString(using: .utf8)
        let outputSize = 1024
        let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: outputSize)
        defer {
            outputBuffer.deallocate()
        }
        
        guard let inputCString = inputCString else {
            return nil
        }
        
        let result = mylib_do_something(inputCString, outputBuffer, outputSize)
        
        if result == 0 {
            return String(cString: outputBuffer)
        }
        
        return nil
    }
    
    // 清理资源
    func cleanup() {
        mylib_cleanup()
    }
}

// 使用示例
extension MyLibWrapper {
    func exampleUsage() {
        // 初始化
        if initialize() {
            print("MyLib initialized successfully")
            
            // 使用功能
            if let result = doSomething(input: "Hello from Swift!") {
                print("Result: \(result)")
            }
            
            // 清理
            cleanup()
        } else {
            print("Failed to initialize MyLib")
        }
    }
} 