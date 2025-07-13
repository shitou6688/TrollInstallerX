//
//  Installation.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

let fileManager = FileManager.default
let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
let kernelPath = docsDir + "/kernelcache"

// 预下载内核缓存函数
func preDownloadKernel(_ device: Device) async -> Bool {
    Logger.log("🚀 开始预下载内核缓存...")
    
    // 如果已经存在，直接返回成功
    if fileManager.fileExists(atPath: kernelPath) {
        Logger.log("✅ 内核缓存已存在，无需下载")
        return true
    }
    
    // 尝试下载
    Logger.log("📥 正在下载内核缓存，请保持网络连接...")
    
    let success = await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let result = grab_kernelcache(kernelPath)
            continuation.resume(returning: result)
        }
    }
    
    if success {
        Logger.log("✅ 内核缓存预下载成功！")
        return true
    } else {
        Logger.log("❌ 内核缓存预下载失败", type: .error)
        return false
    }
}


func checkForMDCUnsandbox() -> Bool {
    return fileManager.fileExists(atPath: docsDir + "/full_disk_access_sandbox_token.txt")
}

func getKernel(_ device: Device) -> Bool {
    Logger.log("正在获取内核缓存...")
    
    var kernelDownloaded = false
    var attemptCount = 0
    let maxAttempts = 3
    
    // 超时提示 - 缩短到60秒
    DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
        if !kernelDownloaded {
            Logger.log("网络连接较慢，建议使用VPN或切换网络", type: .warning)
        }
    }
    
    // 首先检查本地缓存
    if fileManager.fileExists(atPath: kernelPath) {
        Logger.log("✅ 内核缓存已存在，跳过下载")
        kernelDownloaded = true
        return true
    }
    
    // 检查捆绑的内核缓存（最快的方式）
    if let bundledPath = Bundle.main.path(forResource: "kernelcache", ofType: "") {
        Logger.log("📦 发现捆绑内核缓存，正在复制...")
        do {
            try fileManager.copyItem(atPath: bundledPath, toPath: kernelPath)
            if fileManager.fileExists(atPath: kernelPath) { 
                Logger.log("✅ 已使用捆绑的内核缓存文件")
                kernelDownloaded = true
                return true 
            }
        } catch {
            Logger.log("❌ 复制捆绑内核缓存失败: \(error.localizedDescription)", type: .error)
        }
    }
    
    // 使用MacDirtyCow尝试获取内核缓存（本地方式，无需网络）
    if MacDirtyCow.supports(device) && checkForMDCUnsandbox() {
        Logger.log("🔍 尝试使用MacDirtyCow获取本地内核缓存...")
        let fd = open(docsDir + "/full_disk_access_sandbox_token.txt", O_RDONLY)
        if fd > 0 {
            let tokenData = get_NSString_from_file(fd)
            sandbox_extension_consume(tokenData)
            let path = get_kernelcache_path()
            if let path = path {
                do {
                    try fileManager.copyItem(atPath: path, toPath: kernelPath)
                    Logger.log("✅ 使用MacDirtyCow获取内核缓存成功")
                    kernelDownloaded = true
                    return true
                } catch {
                    Logger.log("❌ 复制内核缓存失败: \(error.localizedDescription)", type: .error)
                }
            }
        }
    }
    
    // 网络下载（最后的选择）
    Logger.log("🌐 开始网络下载内核缓存...")
    Logger.log("📊 预计下载时间：30-60秒（取决于网络速度）")
    
    while attemptCount < maxAttempts && !kernelDownloaded {
        attemptCount += 1
        Logger.log("📥 下载尝试 \(attemptCount)/\(maxAttempts)")
        
        // 添加下载进度提示
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            if !kernelDownloaded {
                Logger.log("⏳ 下载进行中，请保持网络连接...")
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 25) {
            if !kernelDownloaded {
                Logger.log("⏳ 下载仍在进行，请耐心等待...")
            }
        }
        
        if grab_kernelcache(kernelPath) {
            Logger.log("✅ 内核下载成功")
            kernelDownloaded = true
            return true
        } else {
            Logger.log("❌ 下载尝试 \(attemptCount) 失败", type: .error)
            if attemptCount < maxAttempts {
                Logger.log("⏳ 等待3秒后重试...")
                Thread.sleep(forTimeInterval: 3.0)
            }
        }
    }
    
    Logger.log("❌ 所有下载方式都失败了", type: .error)
    Logger.log("💡 建议：", type: .warning)
    Logger.log("   1. 检查网络连接", type: .warning)
    Logger.log("   2. 尝试使用VPN", type: .warning)
    Logger.log("   3. 重启设备后重试", type: .warning)
    
    return false
}


func cleanupPrivatePreboot() -> Bool {
    // Remove /private/preboot/tmp
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: "/private/preboot/tmp")
    } catch let e {
        print("Failed to remove /private/preboot/tmp! \(e.localizedDescription)")
        return false
    }
    return true
}

func selectExploit(_ device: Device) -> KernelExploit {
    let flavour = (TIXDefaults().string(forKey: "exploitFlavour") ?? (physpuppet.supports(device) ? "physpuppet" : "landa"))
    if flavour == "landa" { return landa }
    if flavour == "physpuppet" { return physpuppet }
    if flavour == "smith" { return smith }
    return landa
}

func getCandidates() -> [InstalledApp] {
    var apps = [InstalledApp]()
    for candidate in persistenceHelperCandidates {
        if candidate.isInstalled { apps.append(candidate) }
    }
    return apps
}

func tryInstallPersistenceHelper(_ candidates: [InstalledApp]) -> Bool {
    for candidate in candidates {
        Logger.log("正在尝试安装持久性助手到 \(candidate.displayName)")
        if install_persistence_helper(candidate.bundleIdentifier) {
            Logger.log("成功安装持久性助手到 \(candidate.displayName)！", type: .success)
            return true
        }
        Logger.log("安装失败，尝试下一个应用", type: .error)
    }
    Logger.log("所有应用都安装失败", type: .error)
    return false
}

// 添加内核查找函数的更健壮版本
func robustInitialiseKernelInfo(_ kernelPath: String, _ iOS14: Bool) -> Bool {
    for attempt in 1...3 {
        Logger.log("正在查找内核漏洞 (尝试 \(attempt)/3)")
        if initialise_kernel_info(kernelPath, iOS14) {
            Logger.log("查找内核漏洞成功")
            return true
        }
        
        Logger.log("查找内核漏洞失败，将尝试重试", type: .error)
        // 短暂等待后重试
        sleep(1)
    }
    
    Logger.log("查找内核漏洞失败，已尝试3次", type: .error)
    return false
}

@discardableResult
func doDirectInstall(_ device: Device) async -> Bool {
    
    let exploit = selectExploit(device)
    
    let iOS14 = device.version < Version("15.0")
    let supportsFullPhysRW = !(device.cpuFamily == .A8 && device.version > Version("15.1.1")) && ((device.isArm64e && device.version >= Version(major: 15, minor: 2)) || (!device.isArm64e && device.version >= Version("15.0")))
    
    Logger.log("正运行在 \(device.modelIdentifier) 设备上的 iOS 版本为 \(device.version.readableString)")
    
    if !iOS14 {
        if !(getKernel(device)) {
            Logger.log("获取内核漏洞失败", type: .error)
            return false
        }
    }
    
    Logger.log("正在查找内核漏洞")
    if !robustInitialiseKernelInfo(kernelPath, iOS14) {
        Logger.log("查找内核漏洞失败", type: .error)
        return false
    }
    
    Logger.log("正在利用内核 (\(exploit.name)) 漏洞")
    if !exploit.initialise() {
        Logger.log("利用内核漏洞失败", type: .error)
        return false
    }
    Logger.log("成功利用内核漏洞", type: .success)
    post_kernel_exploit(iOS14)
    
    var trollstoreTarData: Data?
    if FileManager.default.fileExists(atPath: docsDir + "/TrollStore.tar") {
        trollstoreTarData = try? Data(contentsOf: docsURL.appendingPathComponent("TrollStore.tar"))
    }
    
    if supportsFullPhysRW {
        if device.isArm64e {
            Logger.log("正在绕过 PPL (\(dmaFail.name))")
            if !dmaFail.initialise() {
                Logger.log("绕过 PPL 失败", type: .error)
                return false
            }
            Logger.log("成功绕过 PPL", type: .success)
        }
        
        if #available(iOS 16, *) {
            libjailbreak_kalloc_pt_init()
        }
        
        if !build_physrw_primitive() {
            Logger.log("构建硬件读写条件失败", type: .error)
            return false
        }
        
        if device.isArm64e {
            if !dmaFail.deinitialise() {
                Logger.log("初始化 \(dmaFail.name) 失败", type: .error)
                return false
            }
        }
        
        if !exploit.deinitialise() {
            Logger.log("初始化 \(exploit.name) 失败", type: .error)
            return false
        }
        
        Logger.log("正在解除沙盒")
        if !unsandbox() {
            Logger.log("解除沙盒失败", type: .error)
            return false
        }
        
        Logger.log("提升权限")
        if !get_root_pplrw() {
            Logger.log("提升权限失败", type: .error)
            return false
        }
        if !platformise() {
            Logger.log("平台化失败", type: .error)
            return false
        }
    } else {
        
        Logger.log("解除沙盒并提升权限中")
        if !get_root_krw(iOS14) {
            Logger.log("解除沙盒并提升权限失败", type: .error)
            return false
        }
    }
    
    remount_private_preboot()
    
    if let data = trollstoreTarData {
        do {
            try FileManager.default.createDirectory(atPath: "/private/preboot/tmp", withIntermediateDirectories: false)
            FileManager.default.createFile(atPath: "/private/preboot/tmp/TrollStore.tar", contents: nil)
            try data.write(to: URL(string: "file:///private/preboot/tmp/TrollStore.tar")!)
        } catch {
            print("无法成功写出 TrollStore.tar - \(error.localizedDescription)")
        }
    }
    
    // Prevents download finishing between extraction and installation
    let useLocalCopy = FileManager.default.fileExists(atPath: "/private/preboot/tmp/TrollStore.tar")

    if !fileManager.fileExists(atPath: "/private/preboot/tmp/trollstorehelper") {
        Logger.log("正在获取 TrollStore.tar")
        if !extractTrollStore(useLocalCopy) {
            Logger.log("获取 TrollStore.tar 失败", type: .error)
            return false
        }
    }
    
    let newCandidates = getCandidates()
    persistenceHelperCandidates = newCandidates
    
    // 自动尝试安装持久性助手
    if !tryInstallPersistenceHelper(newCandidates) {
        Logger.log("无法安装持久性助手", type: .error)
    }
    
    Logger.log("正在安装 TrollStore")
    if !install_trollstore(useLocalCopy ? "/private/preboot/tmp/TrollStore.tar" : Bundle.main.bundlePath + "/TrollStore.tar") {
        Logger.log("安装 TrollStore 失败", type: .error)
    } else {
        Logger.log("成功安装 TrollStore！", type: .success)
        Logger.log("巨魔已安装成功，返回桌面查找大头巨魔！", type: .success)
        Logger.log("如无显示，请在桌面右滑到资源库，搜 troll（没有的话重启一下）", type: .warning)
    }
    
    if !cleanupPrivatePreboot() {
        Logger.log("清除 /private/preboot 失败", type: .error)
    }
    
    if !supportsFullPhysRW {
        if !drop_root_krw(iOS14) {
            Logger.log("降低root权限失败", type: .error)
            return false
        }
        if !exploit.deinitialise() {
            Logger.log("初始化 \(exploit.name) 失败", type: .error)
            return false
        }
    }
    
    return true
}

func doIndirectInstall(_ device: Device) async -> Bool {
    let exploit = selectExploit(device)
    
    Logger.log("正运行在 \(device.modelIdentifier) 设备上的 iOS 版本为 \(device.version.readableString)")
    
    if !extractTrollStoreIndirect() {
        return false
    }
    defer {
        cleanupIndirectInstall()
    }
    
    if !(getKernel(device)) {
        Logger.log("获取内核失败", type: .error)
    }
    
    Logger.log("正在查找内核漏洞")
    if !robustInitialiseKernelInfo(kernelPath, false) {
        Logger.log("查找内核漏洞失败", type: .error)
        return false
    }
    
    Logger.log("正在利用内核漏洞 (\(exploit.name))")
    if !exploit.initialise() {
        Logger.log("利用内核漏洞失败", type: .error)
        return false
    }
    defer {
        if !exploit.deinitialise() {
            Logger.log("初始化 \(exploit.name) 失败", type: .error)
        }
    }
    Logger.log("成功利用内核", type: .success)
    post_kernel_exploit(false)
    
    let apps = get_installed_apps() as? [String]
    var candidates = [InstalledApp]()
    for app in apps ?? [String]() {
        print(app)
        for candidate in persistenceHelperCandidates {
            if app.components(separatedBy: "/")[1].replacingOccurrences(of: ".app", with: "") == candidate.bundleName {
                candidates.append(candidate)
                candidates[candidates.count - 1].isInstalled = true
                candidates[candidates.count - 1].bundlePath = "/var/containers/Bundle/Application/" + app
            }
        }
    }
    
    persistenceHelperCandidates = candidates
    
    // 自动选择第一个可用的应用作为持久性助手
    if let firstCandidate = candidates.first {
        Logger.log("正在自动注入持久性助手到 \(firstCandidate.displayName)")
        let pathToInstall = firstCandidate.bundlePath!
        var success = false
        if !install_persistence_helper_via_vnode(pathToInstall) {
            Logger.log("安装持久性助手失败", type: .error)
            Logger.log("重启手机后，请再来点击安装！", type: .warning)
            Logger.log("5秒后注销...", type: .warning)
            DispatchQueue.global().async {
                sleep(5)
                restartBackboard()
            }
        } else {
            Logger.log("成功安装持久性助手", type: .success)
            Logger.log("返回桌面打开\"\(firstCandidate.displayName)\"这个软件。（找不到这个软件，桌面上搜一下。）", type: .warning)
            success = true
        }
        
        if success {
            let verbose = TIXDefaults().bool(forKey: "verbose")
            Logger.log("\(verbose ? "15" : "5") 秒后注销")
            DispatchQueue.global().async {
                sleep(verbose ? 15 : 5)
                restartBackboard()
            }
        }
        return true
    }
    
    Logger.log("未找到可用的应用来安装持久性助手", type: .error)
    return false
}
