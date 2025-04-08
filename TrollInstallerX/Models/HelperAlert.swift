import Foundation
import SwiftUI

public class HelperAlert: ObservableObject {
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    private static var shared: HelperAlert?
    private static let lock = NSLock()
    
    public static func sharedInstance() -> HelperAlert {
        lock.lock()
        defer { lock.unlock() }
        
        if shared == nil {
            shared = HelperAlert()
        }
        return shared!
    }
    
    private init() {}
    
    func show(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showAlert = true
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.showAlert = false
        }
    }
} 