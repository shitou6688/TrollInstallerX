import Foundation
import SwiftUI

/// Dylib使用示例
/// 展示如何在主界面中集成和使用dylib功能
class DylibUsageExample: ObservableObject {
    @Published var isProcessing = false
    @Published var resultText = ""
    @Published var errorMessage = ""
    
    private let exampleWrapper = ExampleWrapper.shared
    
    /// 初始化并测试dylib
    func testDylib() {
        isProcessing = true
        errorMessage = ""
        resultText = ""
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1. 初始化库
            guard self.exampleWrapper.initialize() else {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ 库初始化失败"
                    self.isProcessing = false
                }
                return
            }
            
            // 2. 获取版本信息
            let version = self.exampleWrapper.getVersion() ?? "未知版本"
            
            // 3. 处理测试数据
            let testInput = "测试数据: \(Date())"
            let processResult = self.exampleWrapper.process(input: testInput) ?? "处理失败"
            
            // 4. 清理资源
            self.exampleWrapper.cleanup()
            
            // 5. 更新UI
            DispatchQueue.main.async {
                self.resultText = """
                📋 版本信息: \(version)
                
                🔄 处理结果: \(processResult)
                
                ✅ 测试完成
                """
                self.isProcessing = false
            }
        }
    }
    
    /// 批量处理数据
    func batchProcess(inputs: [String]) {
        isProcessing = true
        errorMessage = ""
        resultText = ""
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let results = self.exampleWrapper.batchProcess(inputs: inputs)
            
            DispatchQueue.main.async {
                self.resultText = "批量处理结果:\n" + results.enumerated().map { index, result in
                    "\(index + 1). \(result)"
                }.joined(separator: "\n")
                self.isProcessing = false
            }
        }
    }
}

/// 在SwiftUI中使用dylib的示例视图
struct DylibTestView: View {
    @StateObject private var dylibExample = DylibUsageExample()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Dylib测试")
                .font(.title)
                .fontWeight(.bold)
            
            // 测试按钮
            Button(action: {
                dylibExample.testDylib()
            }) {
                HStack {
                    if dylibExample.isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(dylibExample.isProcessing ? "测试中..." : "开始测试")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(dylibExample.isProcessing ? Color.gray : Color.blue)
                )
            }
            .disabled(dylibExample.isProcessing)
            
            // 批量处理按钮
            Button(action: {
                let testInputs = [
                    "第一个测试数据",
                    "第二个测试数据", 
                    "第三个测试数据"
                ]
                dylibExample.batchProcess(inputs: testInputs)
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("批量处理")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                )
            }
            .disabled(dylibExample.isProcessing)
            
            // 结果显示
            if !dylibExample.resultText.isEmpty {
                ScrollView {
                    Text(dylibExample.resultText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                }
                .frame(maxHeight: 200)
            }
            
            // 错误信息
            if !dylibExample.errorMessage.isEmpty {
                Text(dylibExample.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 在主界面中集成示例

extension MainView {
    /// 添加dylib测试功能到主界面
    func addDylibTestButton() -> some View {
        Button(action: {
            // 这里可以添加dylib测试逻辑
            let example = ExampleWrapper.shared
            if example.initialize() {
                if let version = example.getVersion() {
                    print("Dylib版本: \(version)")
                }
                example.cleanup()
            }
        }) {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.blue)
                Text("测试Dylib")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.8))
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

// MARK: - 预览

struct DylibTestView_Previews: PreviewProvider {
    static var previews: some View {
        DylibTestView()
    }
} 