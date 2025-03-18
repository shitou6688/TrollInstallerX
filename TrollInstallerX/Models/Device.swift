//
//  Device.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

enum CPUFamily {
    // These also remain as-is for X verrsions (e.g. A10 and A10X are the same family)
    case Unknown
    case A8
    case A9
    case A10
    case A11
    case A12
    case A13
    case A14
    case A15
    case A16
}

struct Device {
    let version: Version
    let isArm64e: Bool
    let supportsOTA: Bool
    let isSupported: Bool
    let isOnSupported17Beta: Bool
    var cpuFamily: CPUFamily
    let modelIdentifier: String
    let boardConfig: String
    
    init() {
        self.version = Version(UIDevice.current.systemVersion)
        
        // 获取设备型号标识符
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        self.modelIdentifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // 根据设备型号获取 boardConfig
        switch self.modelIdentifier {
            case "iPhone14,2": self.boardConfig = "D63AP"  // iPhone 13 Pro
            case "iPhone14,3": self.boardConfig = "D64AP"  // iPhone 13 Pro Max
            case "iPhone14,4": self.boardConfig = "D16AP"  // iPhone 13 mini
            case "iPhone14,5": self.boardConfig = "D17AP"  // iPhone 13
            case "iPhone14,6": self.boardConfig = "D49AP"  // iPhone SE (3rd generation)
            case "iPhone14,7": self.boardConfig = "D27AP"  // iPhone 14
            case "iPhone14,8": self.boardConfig = "D28AP"  // iPhone 14 Plus
            case "iPhone15,2": self.boardConfig = "D73AP"  // iPhone 14 Pro
            case "iPhone15,3": self.boardConfig = "D74AP"  // iPhone 14 Pro Max
            default: self.boardConfig = "Unknown"
        }
        
        // Check if arm64e
        var cpusubtype: Int32 = 0
        var len = MemoryLayout.size(ofValue: cpusubtype)
        sysctlbyname("hw.cpusubtype", &cpusubtype, &len, nil, 0)
        self.isArm64e = cpusubtype == CPU_SUBTYPE_ARM64E
        
        // Check if device supports TrollHelperOTA
        if self.isArm64e {
            supportsOTA = self.version < Version("15.7")
        } else {
            supportsOTA = self.version >= Version("15.0") && self.version < Version("15.5")
        }
        
        // Set the CPU family (for checking dmaFail compatibility)
        var deviceCPU = 0
        len = MemoryLayout.size(ofValue: deviceCPU);
        sysctlbyname("hw.cpufamily", &deviceCPU, &len, nil, 0);
        
        // Set the SoC
        switch deviceCPU {
        case 0x2C91A47E:
            self.cpuFamily = .A8
        case 0x92FB37C8:
            self.cpuFamily = .A9
        case 0x67CEEE93:
            self.cpuFamily = .A10
        case 0xE81E7EF6:
            self.cpuFamily = .A11
        case 0x07D34B9F:
            self.cpuFamily = .A12
        case 0x462504D2:
            self.cpuFamily = .A13
        case 0x1B588BB3:
            self.cpuFamily = .A14
        case 0xDA33D83D:
            self.cpuFamily = .A15
        case 0x8765EDEA:
            self.cpuFamily = .A16
        default:
            self.cpuFamily = .Unknown
        }
        
        // Check build number
        len = 256;
        var buildNumber = [CChar](repeating: 0, count: len)
        sysctlbyname("kern.osversion", &buildNumber, &len, nil, 0);
        let buildNumberStr = String(cString: buildNumber)
        
        if buildNumberStr == "21A5248v" // Beta 1
        || buildNumberStr == "21A5268h" // Beta 2
        || buildNumberStr == "21A5277j" // Beta 3
        || buildNumberStr == "21A5291h" // Beta 4
        || buildNumberStr == "21A5291j" // Beta 4 (re-release)
        {
            self.isOnSupported17Beta = true
        } else {
            self.isOnSupported17Beta = false
        }
        
        var isM2 = false
        
        let registryEntry = IORegistryEntryFromPath(mach_port_t(MACH_PORT_NULL), "IODeviceTree:/chosen")
        if let bmHash = IORegistryEntryCreateCFProperty(registryEntry, "chip-id" as CFString, kCFAllocatorDefault, 0) {
            if let bootManifestHashData = bmHash.takeRetainedValue() as? Data {
                let cpid: Int = bootManifestHashData.withUnsafeBytes { $0.pointee }
                isM2 = cpid == 0x8112
            }
        }
        
        if self.cpuFamily == .A8 {
            isSupported = self.version < Version("15.2")
        } else {
            isSupported = (self.version <= Version("16.6.1")) || (self.isOnSupported17Beta && !((self.cpuFamily == .A15 && !isM2) || self.cpuFamily == .A16))
        }
    }
    
    var supportsDirectInstall: Bool {
        if !self.isArm64e { return true }
        if self.cpuFamily == .A15 || self.cpuFamily == .A16 {
            return self.version < Version("16.5.1")
        } else {
            return self.version < Version("16.6")
        }
    }
}
