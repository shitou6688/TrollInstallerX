# Xcode项目配置模板

本模板展示如何手动将dylib添加到Xcode项目中。

## 📋 配置步骤

### 1. 生成UUID

首先需要生成4个UUID用于项目配置：

```bash
# 在终端中运行以下命令生成UUID
uuidgen | tr '[:lower:]' '[:upper:]' | tr -d '-'
```

需要生成4个UUID：
- `FILE_REF_UUID` - 文件引用UUID
- `BUILD_FILE_UUID` - 构建文件UUID  
- `COPY_FILE_UUID` - 复制文件UUID
- `GROUP_UUID` - 文件组UUID

### 2. 修改project.pbxproj文件

需要修改 `TrollInstallerX.xcodeproj/project.pbxproj` 文件，在以下位置添加配置：

#### 2.1 在PBXBuildFile section中添加

找到 `/* Begin PBXBuildFile section */` 部分，添加：

```
BUILD_FILE_UUID /* example.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = FILE_REF_UUID /* example.dylib */; };
COPY_FILE_UUID /* example.dylib in CopyFiles */ = {isa = PBXBuildFile; fileRef = FILE_REF_UUID /* example.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
```

#### 2.2 在PBXCopyFilesBuildPhase section中添加

找到 `/* Begin PBXCopyFilesBuildPhase section */` 部分，在files数组中添加：

```
COPY_FILE_UUID /* example.dylib in CopyFiles */,
```

#### 2.3 在PBXFileReference section中添加

找到 `/* Begin PBXFileReference section */` 部分，添加：

```
FILE_REF_UUID /* example.dylib */ = {isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = example.dylib; sourceTree = "<group>"; };
```

#### 2.4 在PBXFrameworksBuildPhase section中添加

找到 `/* Begin PBXFrameworksBuildPhase section */` 部分，在files数组中添加：

```
BUILD_FILE_UUID /* example.dylib in Frameworks */,
```

#### 2.5 在PBXGroup section中添加

找到External/lib组，在children数组中添加：

```
FILE_REF_UUID /* example.dylib */,
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
		B2C3D4E5F678901234567890123456A1 /* example.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F678901234567890123456 /* example.dylib */; };
		C3D4E5F678901234567890123456A1B2 /* example.dylib in CopyFiles */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F678901234567890123456 /* example.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
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
				C3D4E5F678901234567890123456A1B2 /* example.dylib in CopyFiles */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
```

#### 3.3 PBXFileReference section

```
/* Begin PBXFileReference section */
		// ... 其他文件 ...
		A1B2C3D4E5F678901234567890123456 /* example.dylib */ = {isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = example.dylib; sourceTree = "<group>"; };
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
				B2C3D4E5F678901234567890123456A1 /* example.dylib in Frameworks */,
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
				A1B2C3D4E5F678901234567890123456 /* example.dylib */,
				31D334322C9367A9003050AB /* libgrabkernel2.a */,
				511A788A2BBE0A8700D262F9 /* libpartial.a */,
			);
			path = lib;
			sourceTree = "<group>";
		};
```

### 4. 验证配置

配置完成后，在Xcode中：

1. 打开项目文件
2. 检查External/lib组中是否出现example.dylib
3. 检查Frameworks组中是否出现example.dylib
4. 尝试编译项目，确保没有链接错误

### 5. 常见问题

#### Q: 编译时出现"symbol not found"错误
A: 检查：
- dylib文件是否正确添加到项目中
- 头文件中的函数声明是否正确
- 函数名称是否匹配

#### Q: 运行时出现"image not found"错误
A: 检查：
- dylib是否被正确复制到应用包中
- 架构是否匹配（arm64）
- 依赖库是否满足

#### Q: 如何检查dylib的符号表？
A: 使用命令：
```bash
nm -D example.dylib
```

### 6. 完整配置检查清单

- [ ] dylib文件已复制到 `TrollInstallerX/External/lib/`
- [ ] 头文件已创建在 `TrollInstallerX/External/include/`
- [ ] Swift包装类已创建在 `TrollInstallerX/Models/`
- [ ] PBXBuildFile section已添加
- [ ] PBXCopyFilesBuildPhase section已添加
- [ ] PBXFileReference section已添加
- [ ] PBXFrameworksBuildPhase section已添加
- [ ] PBXGroup section已添加
- [ ] 项目编译成功
- [ ] 运行时测试通过 