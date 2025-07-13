#!/usr/bin/env python3
"""
Dylib集成助手脚本
用于自动将dylib文件集成到TrollInstallerX项目中
"""

import os
import sys
import shutil
import uuid

def generate_uuid():
    """生成UUID用于Xcode项目配置"""
    return str(uuid.uuid4()).upper().replace('-', '')

def add_dylib_to_project(dylib_name, dylib_path):
    """
    将dylib添加到Xcode项目中
    
    Args:
        dylib_name: dylib文件名 (例如: mylib.dylib)
        dylib_path: dylib文件路径
    """
    
    # 1. 复制dylib文件到项目目录
    lib_dir = "TrollInstallerX/External/lib"
    target_path = os.path.join(lib_dir, dylib_name)
    
    if not os.path.exists(lib_dir):
        os.makedirs(lib_dir)
    
    shutil.copy2(dylib_path, target_path)
    print(f"✅ 已复制 {dylib_name} 到 {target_path}")
    
    # 2. 生成项目配置信息
    dylib_uuid = generate_uuid()
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    copy_file_uuid = generate_uuid()
    
    print(f"\n📋 项目配置信息:")
    print(f"Dylib UUID: {dylib_uuid}")
    print(f"File Reference UUID: {file_ref_uuid}")
    print(f"Build File UUID: {build_file_uuid}")
    print(f"Copy File UUID: {copy_file_uuid}")
    
    # 3. 生成需要添加到project.pbxproj的内容
    config_content = f"""
# 在 PBXBuildFile section 中添加:
{build_file_uuid} /* {dylib_name} in Frameworks */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {dylib_name} */; }};
{copy_file_uuid} /* {dylib_name} in CopyFiles */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {dylib_name} */; settings = {{ATTRIBUTES = (CodeSignOnCopy, ); }}; }};

# 在 PBXCopyFilesBuildPhase section 的 files 数组中添加:
{copy_file_uuid} /* {dylib_name} in CopyFiles */,

# 在 PBXFileReference section 中添加:
{file_ref_uuid} /* {dylib_name} */ = {{isa = PBXFileReference; lastKnownFileType = "compiled.mach-o.dylib"; path = {dylib_name}; sourceTree = "<group>"; }};

# 在 PBXFrameworksBuildPhase section 的 files 数组中添加:
{build_file_uuid} /* {dylib_name} in Frameworks */,

# 在项目文件组中添加文件引用
"""
    
    print(config_content)
    
    # 4. 生成头文件模板
    header_name = dylib_name.replace('.dylib', '.h')
    header_path = f"TrollInstallerX/External/include/{header_name}"
    
    header_content = f"""#ifndef {dylib_name.replace('.dylib', '_h').replace('.', '_')}
#define {dylib_name.replace('.dylib', '_h').replace('.', '_')}

#ifdef __cplusplus
extern "C" {{
#endif

// 请根据您的 {dylib_name} 实际函数进行修改

// 初始化函数
int {dylib_name.replace('.dylib', '_init')}(void);

// 示例功能函数
int {dylib_name.replace('.dylib', '_do_something')}(const char* input, char* output, int output_size);

// 清理函数
void {dylib_name.replace('.dylib', '_cleanup')}(void);

#ifdef __cplusplus
}}
#endif

#endif /* {dylib_name.replace('.dylib', '_h').replace('.', '_')} */
"""
    
    include_dir = "TrollInstallerX/External/include"
    if not os.path.exists(include_dir):
        os.makedirs(include_dir)
    
    with open(header_path, 'w') as f:
        f.write(header_content)
    
    print(f"✅ 已创建头文件模板: {header_path}")
    
    # 5. 生成Swift包装类
    wrapper_name = f"{dylib_name.replace('.dylib', '')}Wrapper.swift"
    wrapper_path = f"TrollInstallerX/Models/{wrapper_name}"
    
    wrapper_content = f"""import Foundation

// 导入C头文件
import {dylib_name.replace('.dylib', '')}

class {dylib_name.replace('.dylib', '').capitalize()}Wrapper {{
    static let shared = {dylib_name.replace('.dylib', '').capitalize()}Wrapper()
    
    private init() {{}}
    
    // 初始化dylib
    func initialize() -> Bool {{
        let result = {dylib_name.replace('.dylib', '_init')}()
        return result == 0 // 假设0表示成功
    }}
    
    // 调用dylib功能
    func doSomething(input: String) -> String? {{
        let inputCString = input.cString(using: .utf8)
        let outputSize = 1024
        let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: outputSize)
        defer {{
            outputBuffer.deallocate()
        }}
        
        guard let inputCString = inputCString else {{
            return nil
        }}
        
        let result = {dylib_name.replace('.dylib', '_do_something')}(inputCString, outputBuffer, outputSize)
        
        if result == 0 {{
            return String(cString: outputBuffer)
        }}
        
        return nil
    }}
    
    // 清理资源
    func cleanup() {{
        {dylib_name.replace('.dylib', '_cleanup')}()
    }}
}}

// 使用示例
extension {dylib_name.replace('.dylib', '').capitalize()}Wrapper {{
    func exampleUsage() {{
        // 初始化
        if initialize() {{
            print("{dylib_name} initialized successfully")
            
            // 使用功能
            if let result = doSomething(input: "Hello from Swift!") {{
                print("Result: {{result}}")
            }}
            
            // 清理
            cleanup()
        }} else {{
            print("Failed to initialize {dylib_name}")
        }}
    }}
}}
"""
    
    with open(wrapper_path, 'w') as f:
        f.write(wrapper_content)
    
    print(f"✅ 已创建Swift包装类: {wrapper_path}")
    
    print(f"\n🎉 集成完成！")
    print(f"请按照以下步骤完成配置:")
    print(f"1. 将上述配置信息添加到 TrollInstallerX.xcodeproj/project.pbxproj 文件中")
    print(f"2. 根据您的dylib实际函数修改头文件 {header_path}")
    print(f"3. 修改Swift包装类 {wrapper_path} 以匹配您的函数")
    print(f"4. 在需要的地方调用 {dylib_name.replace('.dylib', '').capitalize()}Wrapper.shared")

def main():
    if len(sys.argv) != 3:
        print("使用方法: python add_dylib.py <dylib文件名> <dylib文件路径>")
        print("示例: python add_dylib.py mylib.dylib /path/to/mylib.dylib")
        sys.exit(1)
    
    dylib_name = sys.argv[1]
    dylib_path = sys.argv[2]
    
    if not os.path.exists(dylib_path):
        print(f"❌ 错误: 文件 {dylib_path} 不存在")
        sys.exit(1)
    
    if not dylib_name.endswith('.dylib'):
        print(f"❌ 错误: 文件名必须以 .dylib 结尾")
        sys.exit(1)
    
    add_dylib_to_project(dylib_name, dylib_path)

if __name__ == "__main__":
    main() 