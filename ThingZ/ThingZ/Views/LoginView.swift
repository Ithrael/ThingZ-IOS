import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedLoginMethod: LoginMethod = .username
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 应用Logo和标题
                    VStack(spacing: 16) {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("ThingZ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("智能储物助手")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // 登录方式选择
                    VStack(spacing: 16) {
                        Text("选择登录方式")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(LoginMethod.allCases, id: \.self) { method in
                                LoginMethodButton(
                                    method: method,
                                    isSelected: selectedLoginMethod == method
                                ) {
                                    selectedLoginMethod = method
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 登录表单
                    VStack(spacing: 20) {
                        switch selectedLoginMethod {
                        case .username:
                            UsernameLoginForm()
                        case .phone:
                            PhoneLoginForm()
                        case .wechat:
                            WechatLoginForm()
                        case .apple:
                            AppleLoginForm()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .environmentObject(authManager)
        .onReceive(authManager.$errorMessage) { errorMessage in
            if !errorMessage.isEmpty {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }
}

// 登录方式选择按钮
struct LoginMethodButton: View {
    let method: LoginMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: method.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(method.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .blue)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 账号密码登录表单
struct UsernameLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("手机号")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("请输入手机号", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("密码")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Group {
                        if showPassword {
                            TextField("请输入密码", text: $password)
                        } else {
                            SecureField("请输入密码", text: $password)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Button(action: {
                Task {
                    await authManager.loginWithUsername(username, password: password)
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(authManager.isLoading || username.isEmpty || password.isEmpty)
        }
    }
}

// 手机号登录表单
struct PhoneLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var countdown = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("手机号")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("请输入手机号", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("验证码")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    TextField("请输入验证码", text: $verificationCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Button(action: sendVerificationCode) {
                        Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                            .font(.caption)
                            .foregroundColor(countdown > 0 ? .gray : .blue)
                    }
                    .disabled(countdown > 0 || phoneNumber.isEmpty)
                }
            }
            
            Button(action: {
                Task {
                    await authManager.loginWithPhone(phoneNumber, verificationCode: verificationCode)
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(authManager.isLoading || phoneNumber.isEmpty || verificationCode.isEmpty)
        }
    }
    
    private func sendVerificationCode() {
        guard !phoneNumber.isEmpty else { return }
        
        Task {
            let success = await authManager.sendVerificationCode(to: phoneNumber)
            if success {
                DispatchQueue.main.async {
                    self.countdown = 60
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if self.countdown > 0 {
                            self.countdown -= 1
                        } else {
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                    }
                }
            }
        }
    }
}

// 微信登录表单
struct WechatLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("使用微信账号登录")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("点击下方按钮跳转到微信进行授权")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            Button(action: {
                Task {
                    await authManager.loginWithWechat()
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "message.circle")
                            .font(.headline)
                    }
                    
                    Text("微信登录")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green)
                .cornerRadius(12)
            }
            .disabled(authManager.isLoading)
        }
    }
}

// Apple ID登录表单
struct AppleLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "applelogo")
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                
                Text("使用Apple ID登录")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("快速、安全地使用您的Apple ID登录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        let loginResult = authManager.loginWithApple(authorization: authorization)
                        if case .failure(let error) = loginResult {
                            // 处理错误
                            print("Apple ID login failed: \(error)")
                        }
                    case .failure(let error):
                        print("Apple ID login error: \(error)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .cornerRadius(12)
        }
    }
}

#Preview {
    LoginView()
} 