import LocalAuthentication
import SwiftUI

// MARK: - 生物识别认证管理器
class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()

    @Published var isBiometricAvailable = false
    @Published var biometricType: LABiometryType = .none
    @Published var isBiometricEnabled = false

    private let context = LAContext()
    private let userDefaultsKey = "BiometricAuthEnabled"

    private init() {
        checkBiometricAvailability()
        loadBiometricPreference()
    }

    // MARK: - 检查生物识别可用性
    func checkBiometricAvailability() {
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAvailable = true
            biometricType = context.biometryType
        } else {
            isBiometricAvailable = false
            biometricType = .none

            if let error = error {
                print("❌ 生物识别不可用: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 生物识别类型描述
    var biometricTypeDescription: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "无生物识别"
        @unknown default:
            return "未知识别方式"
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.fill"
        @unknown default:
            return "lock.fill"
        }
    }

    // MARK: - 执行生物识别验证
    func authenticate(reason: String = "验证您的身份以继续") async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "取消"
        context.localizedFallbackTitle = "使用密码"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            return success
        } catch let error as LAError {
            handleAuthenticationError(error)
            throw error
        }
    }

    // MARK: - 使用设备密码验证（作为备选方案）
    func authenticateWithPasscode(reason: String = "验证您的身份以继续") async throws -> Bool {
        let context = LAContext()

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )

            return success
        } catch let error as LAError {
            handleAuthenticationError(error)
            throw error
        }
    }

    // MARK: - 启用/禁用生物识别
    func enableBiometric(_ enabled: Bool) {
        isBiometricEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: userDefaultsKey)
    }

    func loadBiometricPreference() {
        isBiometricEnabled = UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    // MARK: - 错误处理
    private func handleAuthenticationError(_ error: LAError) {
        switch error.code {
        case .authenticationFailed:
            print("❌ 认证失败：识别未通过")
        case .userCancel:
            print("⚠️ 用户取消了认证")
        case .userFallback:
            print("ℹ️ 用户选择使用备选方案")
        case .systemCancel:
            print("⚠️ 系统取消了认证")
        case .passcodeNotSet:
            print("❌ 设备未设置密码")
        case .biometryNotAvailable:
            print("❌ 生物识别不可用")
        case .biometryNotEnrolled:
            print("❌ 未注册生物识别")
        case .biometryLockout:
            print("❌ 生物识别已锁定")
        default:
            print("❌ 认证错误: \(error.localizedDescription)")
        }
    }
}

// MARK: - 生物识别登录视图
struct BiometricLoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var biometricManager = BiometricAuthManager.shared

    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPasswordLogin = false

    var body: some View {
        ZStack {
            Theme.Colors.warmGradient.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.Colors.pinkAccent)
                        .shadow(
                            color: Theme.Colors.pinkAccent.opacity(0.4),
                            radius: 15,
                            x: 0,
                            y: 8
                        )

                    Text("ThingZ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.primaryText)
                }

                // 生物识别按钮
                if biometricManager.isBiometricAvailable {
                    VStack(spacing: 24) {
                        Button(action: {
                            Task {
                                await performBiometricAuth()
                            }
                        }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.pinkGradient)
                                        .frame(width: 80, height: 80)
                                        .shadow(
                                            color: Theme.Colors.pinkAccent.opacity(0.4),
                                            radius: 12,
                                            x: 0,
                                            y: 6
                                        )

                                    if isAuthenticating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                    } else {
                                        Image(systemName: biometricManager.biometricIcon)
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                }

                                Text("使用 \(biometricManager.biometricTypeDescription) 登录")
                                    .font(Theme.Fonts.bodyBold)
                                    .foregroundColor(Theme.Colors.primaryText)
                            }
                        }
                        .disabled(isAuthenticating)

                        // 备选登录方式
                        Button(action: {
                            showPasswordLogin = true
                        }) {
                            Text("使用密码登录")
                                .font(Theme.Fonts.body)
                                .foregroundColor(Theme.Colors.secondaryText)
                                .underline()
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.Colors.warningYellow)

                        Text("生物识别不可用")
                            .font(Theme.Fonts.title3)
                            .foregroundColor(Theme.Colors.primaryText)

                        Text("请在设备设置中启用Face ID或Touch ID")
                            .font(Theme.Fonts.body)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            showPasswordLogin = true
                        }) {
                            Text("使用密码登录")
                                .font(Theme.Fonts.bodyBold)
                                .foregroundColor(Theme.Colors.pinkAccent)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(
                                            color: Theme.Shadow.light.color,
                                            radius: Theme.Shadow.light.radius,
                                            x: Theme.Shadow.light.x,
                                            y: Theme.Shadow.light.y
                                        )
                                )
                        }
                        .padding(.top)
                    }
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showPasswordLogin) {
            // 这里应该显示密码登录视图
            Text("密码登录")
        }
        .alert("认证失败", isPresented: $showError) {
            Button("确定", role: .cancel) { }
            Button("重试") {
                Task {
                    await performBiometricAuth()
                }
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // 自动触发生物识别
            if biometricManager.isBiometricAvailable && biometricManager.isBiometricEnabled {
                Task {
                    await performBiometricAuth()
                }
            }
        }
    }

    @MainActor
    private func performBiometricAuth() async {
        isAuthenticating = true

        do {
            let success = try await biometricManager.authenticate(reason: "登录到ThingZ")

            if success {
                // 认证成功，登录用户
                // 这里应该从安全存储中获取用户凭证并自动登录
                print("✅ 生物识别认证成功")
                // authManager.loginWithStoredCredentials()
            }
        } catch {
            errorMessage = "认证失败，请重试"
            showError = true
        }

        isAuthenticating = false
    }
}

// MARK: - 生物识别设置视图
struct BiometricSettingsView: View {
    @StateObject private var biometricManager = BiometricAuthManager.shared
    @State private var showingEnableAlert = false
    @State private var showingDisableAlert = false

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                HStack {
                    Image(systemName: biometricManager.biometricIcon)
                        .font(.title2)
                        .foregroundColor(Theme.Colors.pinkAccent)

                    Text("生物识别登录")
                        .font(Theme.Fonts.title3)
                        .foregroundColor(Theme.Colors.primaryText)

                    Spacer()
                }

                if biometricManager.isBiometricAvailable {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Text("使用 \(biometricManager.biometricTypeDescription) 快速登录")
                            .font(Theme.Fonts.body)
                            .foregroundColor(Theme.Colors.secondaryText)

                        Toggle("启用\(biometricManager.biometricTypeDescription)", isOn: Binding(
                            get: { biometricManager.isBiometricEnabled },
                            set: { newValue in
                                if newValue {
                                    showingEnableAlert = true
                                } else {
                                    showingDisableAlert = true
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.pinkAccent))
                    }
                } else {
                    Text("此设备不支持生物识别功能")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .alert("启用生物识别登录", isPresented: $showingEnableAlert) {
            Button("取消", role: .cancel) { }
            Button("启用") {
                Task {
                    await enableBiometric()
                }
            }
        } message: {
            Text("启用后，您可以使用\(biometricManager.biometricTypeDescription)快速登录ThingZ")
        }
        .alert("禁用生物识别登录", isPresented: $showingDisableAlert) {
            Button("取消", role: .cancel) { }
            Button("禁用", role: .destructive) {
                biometricManager.enableBiometric(false)
            }
        } message: {
            Text("禁用后，您需要使用账号密码登录")
        }
    }

    @MainActor
    private func enableBiometric() async {
        do {
            let success = try await biometricManager.authenticate(reason: "验证身份以启用\(biometricManager.biometricTypeDescription)")

            if success {
                biometricManager.enableBiometric(true)
            }
        } catch {
            print("❌ 启用生物识别失败: \(error)")
        }
    }
}

// MARK: - 预览
#Preview("生物识别登录") {
    BiometricLoginView()
        .environmentObject(AuthManager.shared)
}

#Preview("生物识别设置") {
    BiometricSettingsView()
        .padding()
        .background(Theme.Colors.warmGradient)
}
