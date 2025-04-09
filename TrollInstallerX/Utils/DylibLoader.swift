import Foundation
import UIKit

class DylibLoader {
    static func loadVerificationDylib() {
        let frameworkPath = Bundle.main.path(forResource: "10011", ofType: "dylib")
        if let path = frameworkPath {
            dlopen(path, RTLD_NOW)
            if let error = UnsafePointer<Int8>(dlerror()) {
                print("加载验证插件失败: \(String(cString: error))")
            } else {
                print("成功加载验证插件")
            }
        } else {
            print("未找到验证插件")
        }
    }
} 