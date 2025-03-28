import Foundation

struct Installation {
    static func preDownloadCheck(mirrors: [URL], completion: @escaping (URL?) -> Void) {
        // 镜像连通性检测逻辑
        var validMirrors = [URL]()
        let group = DispatchGroup()
        
        for mirror in mirrors {
            group.enter()
            var request = URLRequest(url: mirror)
            request.httpMethod = "HEAD"
            
            URLSession.shared.dataTask(with: request) { _, response, _ in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    validMirrors.append(mirror)
                }
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion(validMirrors.first)
        }
    }
    
    static func startInstallation(using mirror: URL) {
        // 安装主逻辑
        print("开始使用镜像源：\(mirror.absoluteString)")
    }
}