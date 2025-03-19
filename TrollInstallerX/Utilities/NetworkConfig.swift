import Foundation
import Network

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
    
    func fetchSubscriptionNodes(from urlString: String) {
        guard let url = URL(string: urlString) else {
            Logger.log("无效的订阅链接", type: .error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                Logger.log("获取订阅节点失败：\(error.localizedDescription)", type: .error)
                return
            }
            
            guard let data = data,
                  let base64Decoded = Data(base64Encoded: data),
                  let nodeString = String(data: base64Decoded, encoding: .utf8) else {
                Logger.log("解码订阅节点失败", type: .error)
                return
            }
            
            // 解析 SS/SSR/V2Ray 等协议的节点
            let nodes = self.parseSubscriptionNodes(from: nodeString)
            
            DispatchQueue.main.async {
                self.vpnNodes = nodes
                Logger.log("成功获取 \(nodes.count) 个节点", type: .success)
            }
        }
        task.resume()
    }
    
    private func parseSubscriptionNodes(from nodeString: String) -> [VPNNode] {
        var parsedNodes: [VPNNode] = []
        
        // 这里是一个简单的解析示例，实际使用时需要根据具体的订阅协议格式调整
        let lines = nodeString.components(separatedBy: .newlines)
        for line in lines {
            // 解析 SS/SSR/V2Ray 等协议的节点信息
            // 这里只是一个示例，需要根据实际订阅格式修改
            if let node = parseNode(from: line) {
                parsedNodes.append(node)
            }
        }
        
        return parsedNodes
    }
    
    private func parseNode(from line: String) -> VPNNode? {
        // 这是一个非常简单的解析示例，实际使用时需要更复杂的解析逻辑
        let components = line.components(separatedBy: ":")
        guard components.count >= 3 else { return nil }
        
        return VPNNode(
            host: components[0],
            port: Int(components[1]) ?? 443,
            username: nil,
            password: nil,
            type: .socks5
        )
    }
}

// 在应用启动时自动获取节点
extension NetworkConfig {
    func autoUpdateNodes() {
        let subscriptionURL = "https://mojie.co/api/v1/client/subscribe?token=d521299fdfefe000e01adfe619590850"
        fetchSubscriptionNodes(from: subscriptionURL)
    }
} 