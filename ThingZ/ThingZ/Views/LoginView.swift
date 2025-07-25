import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedLoginMethod: LoginMethod = .username
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.86), // 奶cream色
                        Color(red: 1.0, green: 0.92, blue: 0.8),   // 温暖的桃色
                        Color(red: 1.0, green: 0.95, blue: 0.9)    // 浅桃色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
            ScrollView {
                    VStack(spacing: 40) {
                    // 应用Logo和标题
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.82, blue: 0.86),
                                                Color(red: 1.0, green: 0.75, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                
                        Image(systemName: "archivebox.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        
                            VStack(spacing: 8) {
                        Text("ThingZ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                        
                                Text("你的贴心储物小助手 🥰")
                            .font(.subheadline)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            }
                    }
                    .padding(.top, 40)
                    
                    // 登录方式选择
                        VStack(spacing: 20) {
                            Text("选择你喜欢的登录方式 ✨")
                            .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                        
                            HStack(spacing: 16) {
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
                        .padding(.horizontal, 20)
                    
                    // 登录表单
                        VStack(spacing: 24) {
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
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("温馨提示 💫"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("好的"))
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
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isSelected ? [
                                    Color(red: 1.0, green: 0.75, blue: 0.8),
                                    Color(red: 1.0, green: 0.65, blue: 0.75)
                                ] : [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                            radius: isSelected ? 12 : 6,
                            x: 0,
                            y: isSelected ? 6 : 3
                        )
                    
                Image(systemName: method.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : Color(red: 1.0, green: 0.75, blue: 0.8))
                }
                
                Text(method.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? Color(red: 0.4, green: 0.2, blue: 0.1) : Color(red: 0.6, green: 0.4, blue: 0.3))
            }
            .frame(width: 80, height: 90)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// 账号密码登录表单
struct UsernameLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("手机号 📱")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                
                TextField("请输入手机号", text: $username)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                }
                .frame(height: 50)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("密码 🔐")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.8))
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                
                HStack {
                    Group {
                        if showPassword {
                            TextField("请输入密码", text: $password)
                        } else {
                            SecureField("请输入密码", text: $password)
                        }
                    }
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .frame(height: 50)
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
                    
                    Text("开始我的收纳之旅 ✨")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.75, blue: 0.8),
                            Color(red: 1.0, green: 0.65, blue: 0.75)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .disabled(authManager.isLoading || username.isEmpty || password.isEmpty)
            .scaleEffect(authManager.isLoading || username.isEmpty || password.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: authManager.isLoading || username.isEmpty || password.isEmpty)
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
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("手机号 📱")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                
                TextField("请输入手机号", text: $phoneNumber)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    .keyboardType(.phonePad)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                }
                .frame(height: 50)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("验证码 🔢")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.8))
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        
                    TextField("请输入验证码", text: $verificationCode)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        .keyboardType(.numberPad)
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    }
                    .frame(height: 50)
                    
                    Button(action: sendVerificationCode) {
                        Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(countdown > 0 ? Color(red: 0.6, green: 0.4, blue: 0.3) : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(countdown > 0 ? Color.gray.opacity(0.3) : Color(red: 1.0, green: 0.8, blue: 0.4))
                            )
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
                    
                    Text("开始我的收纳之旅 ✨")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.75, blue: 0.8),
                            Color(red: 1.0, green: 0.65, blue: 0.75)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .disabled(authManager.isLoading || phoneNumber.isEmpty || verificationCode.isEmpty)
            .scaleEffect(authManager.isLoading || phoneNumber.isEmpty || verificationCode.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: authManager.isLoading || phoneNumber.isEmpty || verificationCode.isEmpty)
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
        VStack(spacing: 24) {
        VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.7, green: 0.9, blue: 0.7),
                                    Color(red: 0.6, green: 0.8, blue: 0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: Color.green.opacity(0.3),
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                    
                Image(systemName: "message.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("使用微信账号登录 💬")
                    .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                    Text("点击下方按钮跳转到微信进行授权～")
                    .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                }
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
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.7, green: 0.9, blue: 0.7),
                            Color(red: 0.6, green: 0.8, blue: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(
                    color: Color.green.opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .disabled(authManager.isLoading)
            .scaleEffect(authManager.isLoading ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: authManager.isLoading)
        }
    }
}

// Apple ID登录表单
struct AppleLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 24) {
        VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.2, blue: 0.2),
                                    Color(red: 0.1, green: 0.1, blue: 0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                    
                Image(systemName: "applelogo")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("使用Apple ID登录 🍎")
                    .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                    Text("快速、安全地使用您的Apple ID登录～")
                    .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                }
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
            .frame(height: 54)
            .cornerRadius(20)
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
        }
    }
}

#Preview {
    LoginView()
} 