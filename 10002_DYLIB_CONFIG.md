# 10002.dylib 项目配置指南

## 📋 已完成的工作

✅ **文件已复制**: `10002.dylib` 已复制到 `TrollInstallerX/External/lib/`
✅ **头文件已创建**: `TrollInstallerX/External/include/10002.h`
✅ **Swift包装类已创建**: `TrollInstallerX/Models/Lib10002Wrapper.swift`

## 🔧 需要手动配置的项目文件

### 1. 生成UUID

请在终端中运行以下命令生成4个UUID：

```bash
# 方法1: 使用PowerShell
[System.Guid]::NewGuid().ToString().ToUpper().Replace('-', '')

# 方法2: 使用在线UUID生成器
# 访问: https://www.uuidgenerator.net/
```

需要生成4个UUID：
- `FILE_REF_UUID` - 文件引用UUID
- `BUILD_FILE_UUID` - 构建文件UUID  
- `COPY_FILE_UUID` - 复制文件UUID
- `GROUP_UUID` - 文件组UUID

### 2. 修改 project.pbxproj 文件

需要修改 `TrollInstallerX.xcodeproj/project.pbxproj` 文件，在以下位置添加配置：

#### 2.1 在PBXBuildFile section中添加

找到 `/* Begin PBXBuildFile section */` 部分，添加：

```
BUILD_FILE_UUID /* 10002.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = FILE_REF_UUID /* 10002.dylib */; };
COPY_FILE_UUID /* 10002.dylib in CopyFiles */ = {isa = PBXBuildFile; fileRef = FILE_REF_UUID /* 10002.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
```

#### 2.2 在PBXCopyFilesBuildPhase section中添加

找到 `/* Begin PBXCopyFilesBuildPhase section */` 部分，在files数组中添加：

```
COPY_FILE_UUID /* 10002.dylib in CopyFiles */,
```

#### 2.3 在PBXFileReference section中添加

找到 `/* Begin PBXFileReference section */` 部分，添加：

```
FILE_REF_UUID /* 10002.dylib */ = {isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = 10002.dylib; sourceTree = "<group>"; };
```

#### 2.4 在PBXFrameworksBuildPhase section中添加

找到 `/* Begin PBXFrameworksBuildPhase section */` 部分，在files数组中添加：

```
BUILD_FILE_UUID /* 10002.dylib in Frameworks */,
```

#### 2.5 在PBXGroup section中添加

找到External/lib组，在children数组中添加：

```
FILE_REF_UUID /* 10002.dylib */,
```

### 3. 实际配置示例

假设生成的UUID为：
- FILE_REF_UUID: `A1B2C3D4E5F678901234567890123456`
- BUILD_FILE_UUID: `B2C3D4E5F678901234567890123456A1`
- COPY_FILE_UUID: `C3D4E5F678901234567890123456A1B2`

#### 3.1 PBXBuildFile section

```
/* Begin PBXBuildFile section */
		// ... 其他文件 ...
		B2C3D4E5F678901234567890123456A1 /* 10002.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F678901234567890123456 /* 10002.dylib */; };
		C3D4E5F678901234567890123456A1B2 /* 10002.dylib in CopyFiles */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F678901234567890123456 /* 10002.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
/* End PBXBuildFile section */
```

#### 3.2 PBXCopyFilesBuildPhase section

```
/* Begin PBXCopyFilesBuildPhase section */
		31ABE9802BAD981C003C35E0 /* CopyFiles */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 7;
			files = (
				31ABE9812BAD9821003C35E0 /* libxpf.dylib in CopyFiles */,
				C3D4E5F678901234567890123456A1B2 /* 10002.dylib in CopyFiles */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
```

#### 3.3 PBXFileReference section

```
/* Begin PBXFileReference section */
		// ... 其他文件 ...
		A1B2C3D4E5F678901234567890123456 /* 10002.dylib */ = {isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = 10002.dylib; sourceTree = "<group>"; };
/* End PBXFileReference section */
```

#### 3.4 PBXFrameworksBuildPhase section

```
/* Begin PBXFrameworksBuildPhase section */
		316661262BAD8465009D22D8 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				511A788B2BBE0A8700D262F9 /* libpartial.a in Frameworks */,
				316661D42BAD9221009D22D8 /* libxpf.dylib in Frameworks */,
				B2C3D4E5F678901234567890123456A1 /* 10002.dylib in Frameworks */,
				// ... 其他框架 ...
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
```

#### 3.5 PBXGroup section

找到External/lib组：

```
		316661D12BAD9221009D22D8 /* lib */ = {
			isa = PBXGroup;
			children = (
				316661B22BAD91ED009D22D8 /* libchoma.a */,
				316661D02BAD9221009D22D8 /* libxpf.dylib */,
				A1B2C3D4E5F678901234567890123456 /* 10002.dylib */,
				31D334322C9367A9003050AB /* libgrabkernel2.a */,
				511A788A2BBE0A8700D262F9 /* libpartial.a */,
			);
			path = lib;
			sourceTree = "<group>";
		};
```

## 🚀 在代码中使用

配置完成后，您可以在代码中这样使用：

```swift
import Foundation

// 使用10002库
let wrapper = Lib10002Wrapper.shared

if wrapper.initialize() {
    // 获取版本信息
    if let version = wrapper.getVersion() {
        print("10002库版本: \(version)")
    }
    
    // 处理数据
    if let result = wrapper.process(input: "测试数据") {
        print("处理结果: \(result)")
    }
    
    // 清理资源
    wrapper.cleanup()
}
```

## 🔍 验证配置

配置完成后，在Xcode中：

1. 打开项目文件
2. 检查External/lib组中是否出现10002.dylib
3. 检查Frameworks组中是否出现10002.dylib
4. 尝试编译项目，确保没有链接错误

## 📝 注意事项

1. **函数名称**: 请根据10002.dylib的实际函数修改头文件中的函数声明
2. **架构匹配**: 确保dylib是arm64架构，适用于iOS设备
3. **依赖库**: 检查dylib是否有其他依赖库需要一起添加

## 🆘 需要帮助？

如果遇到问题，请提供：
1. 编译错误信息
2. 运行时错误信息
3. 10002.dylib的实际函数列表（可以使用 `nm -D 10002.dylib` 命令查看） 