# Dylib集成指南

本指南将帮助您将dylib文件集成到TrollInstallerX项目中。

## 📋 快速开始

### 方法1: 使用自动化脚本（推荐）

1. **运行集成脚本**
   ```bash
   python add_dylib.py yourlib.dylib /path/to/yourlib.dylib
   ```

2. **脚本会自动完成以下操作：**
   - 复制dylib文件到项目目录
   - 生成项目配置信息
   - 创建头文件模板
   - 创建Swift包装类

3. **手动完成剩余配置：**
   - 将配置信息添加到Xcode项目文件
   - 根据实际函数修改头文件和Swift包装类

### 方法2: 手动集成

## 🔧 详细步骤

### 1. 文件准备

将您的dylib文件放到以下目录：
```
TrollInstallerX/External/lib/yourlib.dylib
```

### 2. 创建头文件

在 `TrollInstallerX/External/include/` 目录下创建头文件：

```c
// yourlib.h
#ifndef yourlib_h
#define yourlib_h

#ifdef __cplusplus
extern "C" {
#endif

// 声明您的函数
int yourlib_init(void);
int yourlib_function(const char* input, char* output, int size);
void yourlib_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif
```

### 3. 创建Swift包装类

在 `TrollInstallerX/Models/` 目录下创建Swift文件：

```swift
import Foundation

// 导入C头文件
import yourlib

class YourLibWrapper {
    static let shared = YourLibWrapper()
    
    private init() {}
    
    func initialize() -> Bool {
        let result = yourlib_init()
        return result == 0
    }
    
    func callFunction(input: String) -> String? {
        let inputCString = input.cString(using: .utf8)
        let outputSize = 1024
        let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: outputSize)
        defer {
            outputBuffer.deallocate()
        }
        
        guard let inputCString = inputCString else {
            return nil
        }
        
        let result = yourlib_function(inputCString, outputBuffer, outputSize)
        
        if result == 0 {
            return String(cString: outputBuffer)
        }
        
        return nil
    }
    
    func cleanup() {
        yourlib_cleanup()
    }
}
```

### 4. 配置Xcode项目

需要修改 `TrollInstallerX.xcodeproj/project.pbxproj` 文件：

#### 4.1 添加文件引用

在 `PBXFileReference` 部分添加：
```
YOUR_UUID /* yourlib.dylib */ = {isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = yourlib.dylib; sourceTree = "<group>"; };
```

#### 4.2 添加构建文件

在 `PBXBuildFile` 部分添加：
```
BUILD_UUID /* yourlib.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = YOUR_UUID /* yourlib.dylib */; };
COPY_UUID /* yourlib.dylib in CopyFiles */ = {isa = PBXBuildFile; fileRef = YOUR_UUID /* yourlib.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
```

#### 4.3 添加到框架阶段

在 `PBXFrameworksBuildPhase` 的 `files` 数组中添加：
```
BUILD_UUID /* yourlib.dylib in Frameworks */,
```

#### 4.4 添加到复制阶段

在 `PBXCopyFilesBuildPhase` 的 `files` 数组中添加：
```
COPY_UUID /* yourlib.dylib in CopyFiles */,
```

### 5. 在代码中使用

```swift
// 在需要的地方调用
let wrapper = YourLibWrapper.shared

if wrapper.initialize() {
    if let result = wrapper.callFunction(input: "Hello") {
        print("Result: \(result)")
    }
    wrapper.cleanup()
}
```

## 🔍 常见问题

### Q: 如何获取dylib中的函数列表？
A: 使用 `nm` 命令：
```bash
nm -D yourlib.dylib
```

### Q: 编译时出现链接错误怎么办？
A: 确保：
1. dylib文件已正确添加到项目中
2. 头文件路径正确
3. 函数声明与实现匹配

### Q: 运行时出现符号找不到错误？
A: 检查：
1. dylib是否被正确复制到应用包中
2. 函数名称是否正确
3. 架构是否匹配（arm64）

## 📝 示例：集成libxpf.dylib

项目中已经集成了 `libxpf.dylib`，可以参考其配置：

1. **文件位置**: `TrollInstallerX/External/lib/libxpf.dylib`
2. **头文件**: `TrollInstallerX/External/include/xpf.h`
3. **项目配置**: 在 `project.pbxproj` 中搜索 `libxpf.dylib`

## 🛠️ 调试技巧

1. **检查dylib架构**:
   ```bash
   file yourlib.dylib
   ```

2. **查看符号表**:
   ```bash
   nm -D yourlib.dylib | grep your_function
   ```

3. **验证链接**:
   ```bash
   otool -L yourlib.dylib
   ```

## 📞 需要帮助？

如果遇到问题，请提供：
1. dylib文件名和路径
2. 错误信息
3. 您想要实现的功能

我会帮您完成集成！ 