import SwiftUI
import Combine

class HelperAlert: ObservableObject {
    static let shared = HelperAlert()
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    private init() {}
} 