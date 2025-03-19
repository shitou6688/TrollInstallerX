import Foundation
import SwiftUI

class ActivationManager: ObservableObject {
    static let shared = ActivationManager()
    
    @AppStorage("activationCode") private var savedActivationCode: String = ""
    @Published var isActivated: Bool = false
    @Published var showActivationPrompt: Bool = false
    
    private let validActivationCodes = [
        "TROLL2024",
        "ALFIE666",
        "JAILBREAK",
        "TROLLSTORE"
    ]
    
    private init() {
        checkActivation()
    }
    
    func checkActivation() {
        isActivated = validActivationCodes.contains(savedActivationCode)
        showActivationPrompt = !isActivated
    }
    
    func validateActivationCode(_ code: String) -> Bool {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if validActivationCodes.contains(trimmedCode) {
            savedActivationCode = trimmedCode
            isActivated = true
            showActivationPrompt = false
            return true
        }
        
        return false
    }
    
    func resetActivation() {
        savedActivationCode = ""
        isActivated = false
        showActivationPrompt = true
    }
}

struct ActivationView: View {
    @ObservedObject var activationManager = ActivationManager.shared
    @State private var activationCode: String = ""
    @State private var showErrorMessage: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("请输入激活码")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("请输入激活码", text: $activationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
                .padding()
            
            if showErrorMessage {
                Text("激活码无效，请重新输入")
                    .foregroundColor(.red)
            }
            
            Button(action: {
                if activationManager.validateActivationCode(activationCode) {
                    showErrorMessage = false
                    activationManager.showActivationPrompt = false
                } else {
                    showErrorMessage = true
                }
            }) {
                Text("验证")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
} 