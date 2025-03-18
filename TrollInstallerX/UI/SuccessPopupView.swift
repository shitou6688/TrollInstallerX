import SwiftUI

struct SuccessPopupView: View {
    let helperAppName: String
    
    var body: some View {
        VStack(spacing: 20) {
            // 成功图标
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
                .padding(.top, 20)
            
            // 标题
            Text("安装成功！")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // 分割线
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.2))
                .padding(.horizontal, 30)
            
            // 提示信息
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "arrow.down.app.fill")
                        .foregroundColor(.white)
                    Text("请返回桌面查找")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text("【大头巨魔】")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.vertical, 5)
                
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                    Text("持久性助手已注入到")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text("【\(helperAppName)】")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .padding(.bottom, 5)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
} 