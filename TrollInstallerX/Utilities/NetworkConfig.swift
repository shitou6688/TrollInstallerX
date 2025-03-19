import Foundation

struct VPNNode {
    let host: String
    let port: Int
    let username: String?
    let password: String?
    let type: ProxyType
    
    enum ProxyType: String {
        case http
        case https
        case socks4
        case socks5
    }
}

class NetworkConfig {
    static let shared = NetworkConfig()
    
    private init() {}
    
    var vpnNodes: [VPNNode] = [
        // 日本节点
        VPNNode(host: "jp.mjhy2.com", port: 1443, username: nil, password: nil, type: .socks5),
        // 日本节点
        VPNNode(host: "jp.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 澳大利亚节点
        VPNNode(host: "au.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 土耳其节点
        VPNNode(host: "tr.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 韩国节点
        VPNNode(host: "kp.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 意大利节点
        VPNNode(host: "it.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 葡萄牙节点
        VPNNode(host: "pt.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 俄罗斯节点
        VPNNode(host: "ru.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 哈萨克斯坦节点
        VPNNode(host: "kz.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 乌克兰节点
        VPNNode(host: "ua.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 以色列节点
        VPNNode(host: "il.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 英国节点
        VPNNode(host: "uk.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 阿根廷节点
        VPNNode(host: "ar.mjt000.com", port: 443, username: nil, password: nil, type: .socks5),
        // 尼日利亚节点
        VPNNode(host: "ni.mjt000.com", port: 443, username: nil, password: nil, type: .socks5)
    ]
    
    func configureProxy(for node: VPNNode) {
        let proxyConfig: [String: Any] = [
            kCFNetworkProxiesHTTPEnable: node.type == .http || node.type == .https,
            kCFNetworkProxiesHTTPSEnable: node.type == .https,
            kCFNetworkProxiesSOCKSEnable: node.type == .socks4 || node.type == .socks5,
            kCFNetworkProxiesHTTPProxy: node.host,
            kCFNetworkProxiesHTTPPort: node.port,
            kCFNetworkProxiesSOCKSProxy: node.host,
            kCFNetworkProxiesSOCKSPort: node.port
        ]
        
        // 设置系统代理
        CFNetworkSetSystemProxySettings(proxyConfig as CFDictionary)
        
        // 如果需要认证
        if let username = node.username, let password = node.password {
            let credential = URLCredential(user: username, password: password, persistence: .permanent)
            URLCredentialStorage.shared.setDefaultCredential(credential, for: .init())
        }
    }
    
    func disableProxy() {
        let emptyConfig: [String: Any] = [
            kCFNetworkProxiesHTTPEnable: false,
            kCFNetworkProxiesHTTPSEnable: false,
            kCFNetworkProxiesSOCKSEnable: false
        ]
        CFNetworkSetSystemProxySettings(emptyConfig as CFDictionary)
    }
} 