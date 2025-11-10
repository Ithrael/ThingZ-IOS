import SwiftUI

struct OptimizedLoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedLoginMethod: LoginMethod = .username
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 预定义的颜色，避免重复计算
    private let primaryColor = Color(red: 0.4, green: 0.2, blue: 0.1)
    private let secondaryColor = Color(red: 0.6, green: 0.4, blue: 0.3)
    private let accentColor = Color(red: 1.0, green: 0.75, blue: 0.8)
    
    // 预定义的渐变，避免重复创建
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.97, blue: 0.86),
            Color(red: 1.0, green: 0.95, blue: 0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let logoGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.82, blue: 0.86),
            Color(red: 1.0, green: 0.75, blue: 0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        logoSection
                            .padding(.top, 20)

                        loginMethodSelection
                            .padding(.horizontal, 20)

                        loginFormSection
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("提示", isPresented: $showingAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
        .environmentObject(authManager)
        .onReceive(authManager.$errorMessage.removeDuplicates()) { errorMessage in
            if !errorMessage.isEmpty {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }
    
    // MARK: - Logo区域
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(logoGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: accentColor.opacity(0.2), radius: 6, x: 0, y: 3)

                Image(systemName: "archivebox.fill")
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text("猫搜搜")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)

                Text("你的贴心储物小助手")
                    .font(.subheadline)
                    .foregroundColor(secondaryColor)
            }
        }
    }
    
    // MARK: - 登录方式选择
    private var loginMethodSelection: some View {
        VStack(spacing: 16) {
            Text("选择登录方式")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(primaryColor)

            HStack(spacing: 20) {
                ForEach(LoginMethod.allCases, id: \.self) { method in
                    OptimizedLoginMethodButton(
                        method: method,
                        isSelected: selectedLoginMethod == method,
                        primaryColor: primaryColor,
                        accentColor: accentColor
                    ) {
                        selectedLoginMethod = method
                    }
                }
            }
        }
    }
    
    // MARK: - 登录表单区域
    private var loginFormSection: some View {
        Group {
            switch selectedLoginMethod {
            case .username:
                OptimizedUsernameLoginForm(
                    primaryColor: primaryColor,
                    accentColor: accentColor
                )
            case .phone:
                OptimizedPhoneLoginForm(
                    primaryColor: primaryColor,
                    accentColor: accentColor
                )
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: selectedLoginMethod)
    }
}

// MARK: - 优化的登录方式按钮
struct OptimizedLoginMethodButton: View {
    let method: LoginMethod
    let isSelected: Bool
    let primaryColor: Color
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .shadow(color: accentColor.opacity(0.15), radius: 4, x: 0, y: 2)

                    Image(systemName: method.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? .white : accentColor)
                }

                Text(method.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? primaryColor : primaryColor.opacity(0.7))
            }
            .frame(width: 70, height: 75)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 优化的用户名登录表单
struct OptimizedUsernameLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    
    let primaryColor: Color
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            OptimizedInputField(
                title: "手机号",
                text: $username,
                placeholder: "请输入手机号",
                keyboardType: .phonePad,
                primaryColor: primaryColor,
                accentColor: accentColor
            )

            OptimizedPasswordField(
                title: "密码",
                text: $password,
                placeholder: "请输入密码",
                showPassword: $showPassword,
                primaryColor: primaryColor,
                accentColor: accentColor
            )

            OptimizedLoginButton(
                title: "登录",
                isLoading: authManager.isLoading,
                isDisabled: username.isEmpty || password.isEmpty,
                accentColor: accentColor
            ) {
                Task {
                    await authManager.loginWithUsername(username, password: password)
                }
            }
        }
    }
}

// MARK: - 优化的手机号登录表单
struct OptimizedPhoneLoginForm: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var countdown = 0
    @State private var timer: Timer?
    
    let primaryColor: Color
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            OptimizedInputField(
                title: "手机号",
                text: $phoneNumber,
                placeholder: "请输入手机号",
                keyboardType: .phonePad,
                primaryColor: primaryColor,
                accentColor: accentColor
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("验证码")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(primaryColor)

                HStack(spacing: 10) {
                    OptimizedTextField(
                        text: $verificationCode,
                        placeholder: "请输入验证码",
                        keyboardType: .numberPad,
                        accentColor: accentColor
                    )

                    Button(action: sendVerificationCode) {
                        Text(countdown > 0 ? "\(countdown)s" : "获取")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(countdown > 0 ? primaryColor.opacity(0.6) : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(countdown > 0 ? Color.gray.opacity(0.3) : Color.orange)
                            )
                    }
                    .disabled(countdown > 0 || phoneNumber.isEmpty)
                }
            }

            OptimizedLoginButton(
                title: "登录",
                isLoading: authManager.isLoading,
                isDisabled: phoneNumber.isEmpty || verificationCode.isEmpty,
                accentColor: accentColor
            ) {
                Task {
                    await authManager.loginWithPhone(phoneNumber, verificationCode: verificationCode)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func sendVerificationCode() {
        guard !phoneNumber.isEmpty else { return }
        
        Task {
            let success = await authManager.sendVerificationCode(to: phoneNumber)
            if success {
                await MainActor.run {
                    countdown = 60
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if countdown > 0 {
                            countdown -= 1
                        } else {
                            timer?.invalidate()
                            timer = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 通用组件

// 优化的输入框
struct OptimizedInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    let primaryColor: Color
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(primaryColor)
            
            OptimizedTextField(
                text: $text,
                placeholder: placeholder,
                keyboardType: keyboardType,
                accentColor: accentColor
            )
        }
    }
}

// 优化的文本输入框
struct OptimizedTextField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    let accentColor: Color

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
    }
}

// 优化的密码输入框
struct OptimizedPasswordField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var showPassword: Bool
    let primaryColor: Color
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(primaryColor)

            HStack {
                Group {
                    if showPassword {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .foregroundColor(primaryColor)

                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
    }
}

// 优化的登录按钮
struct OptimizedLoginButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let accentColor: Color
    let action: () -> Void

    private let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.75, blue: 0.8),
            Color(red: 1.0, green: 0.65, blue: 0.75)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    private let disabledGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.gray.opacity(0.4),
            Color.gray.opacity(0.4)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDisabled ? disabledGradient : buttonGradient)
            )
            .shadow(color: Color.black.opacity(isDisabled ? 0 : 0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    OptimizedLoginView()
}