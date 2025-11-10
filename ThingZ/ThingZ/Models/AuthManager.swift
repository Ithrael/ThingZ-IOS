import Foundation
import SwiftUI
// import AuthenticationServices  // Apple登录相关，已注释

// 用户模型
struct User: Codable, Identifiable {
    let id = UUID()
    var username: String
    var email: String?
    var phoneNumber: String?
    var avatar: String?
    var loginMethod: LoginMethod
    var createdAt: Date = Date()
    var lastLoginAt: Date = Date()
}

// API请求和响应模型
struct SendSmsCodeRequest: Codable {
    let mobile: String
}

struct SmsLoginRequest: Codable {
    let mobile: String
    let code: String
}

struct LoginRequest: Codable {
    let mobile: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int
    let userInfo: UserInfo
    
    struct UserInfo: Codable {
        let id: Int
        let mobile: String
        let nickname: String?
        let avatar: String?
        let status: Int
        let createdAt: String
        let updatedAt: String
    }
}

struct SendCodeResponse: Codable {
    let success: Bool
}

// 登录方式枚举
enum LoginMethod: String, Codable, CaseIterable {
    case username = "username"
    case phone = "phone"
    // case wechat = "wechat"  // 微信登录已注释
    // case apple = "apple"    // Apple登录已注释

    var displayName: String {
        switch self {
        case .username: return "账号密码"
        case .phone: return "手机号"
        // case .wechat: return "微信"      // 微信登录已注释
        // case .apple: return "Apple ID"   // Apple登录已注释
        }
    }

    var icon: String {
        switch self {
        case .username: return "person.circle"
        case .phone: return "phone.circle"
        // case .wechat: return "message.circle"  // 微信登录已注释
        // case .apple: return "applelogo"        // Apple登录已注释
        }
    }
}

// 认证状态枚举
enum AuthState {
    case unauthenticated
    case needsProfileSetup
    case authenticated
}

// 登录结果
enum LoginResult {
    case success(User)
    case needsProfileSetup(String) // 需要完善个人信息，传入手机号
    case failure(String)
}

// 认证管理器
class AuthManager: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var isAuthenticated: Bool = false
    @Published var needsProfileSetup: Bool = false
    @Published var pendingPhoneNumber: String = ""
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    static let shared = AuthManager()
    
    private let apiBaseURL = "https://api.anyongtech.cn"
    private let tokenKey = "AuthManager_Token"

    var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    private let userKey = "ThingZ_CurrentUser"
    private let authKey = "ThingZ_IsAuthenticated"
    
    private init() {
        loadAuthState()
    }
    
    // MARK: - 数据持久化
    
    func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: authKey)
        if let user = currentUser {
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: userKey)
            }
        }
    }
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: authKey)
        
        if let data = UserDefaults.standard.data(forKey: userKey),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = decoded
        }
    }
    
    // MARK: - 登录方法
    
    // 账号密码登录
    func loginWithUsername(_ username: String, password: String) async -> LoginResult {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        // 基本验证
        if username.isEmpty || password.isEmpty {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "用户名或密码不能为空"
            }
            return .failure("用户名或密码不能为空")
        }
        
        if password.count < 6 {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "密码长度不能少于6位"
            }
            return .failure("密码长度不能少于6位")
        }
        
        // 调用API
        do {
            let loginRequest = LoginRequest(
                mobile: username, // 使用用户名作为手机号
                password: password
            )
            
            let user = try await performLogin(request: loginRequest)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.saveAuthState()
            }
            
            return .success(user)
        } catch {
            let errorMessage = error.localizedDescription
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = errorMessage
            }
            return .failure(errorMessage)
        }
    }
    
    // 执行登录API请求
    private func performLogin(request: LoginRequest) async throws -> User {
        guard let url = URL(string: "\(apiBaseURL)/thingz/api/user/login") else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "无效的API地址"
            ])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30.0 // 30秒超时
        
        do {
            let requestData = try JSONEncoder().encode(request)
            urlRequest.httpBody = requestData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "服务器响应异常"
                ])
            }
            
            // 根据HTTP状态码判断
            if httpResponse.statusCode == 200 {
                // 解析响应
                let apiResponse = try JSONDecoder().decode(APIResponse<LoginResponse>.self, from: data)
                
                if apiResponse.code == 200, let loginData = apiResponse.data {
                    // 保存token
                    self.authToken = loginData.token

                    // 创建用户对象
                    let user = User(
                        username: loginData.userInfo.nickname ?? loginData.userInfo.mobile,
                        email: nil,
                        phoneNumber: loginData.userInfo.mobile,
                        avatar: loginData.userInfo.avatar,
                        loginMethod: .username
                    )

                    return user
                } else {
                    throw NSError(domain: "AuthError", code: apiResponse.code, userInfo: [
                        NSLocalizedDescriptionKey: apiResponse.message
                    ])
                }
            } else {
                // 尝试解析错误响应
                if let apiResponse = try? JSONDecoder().decode(APIResponse<LoginResponse>.self, from: data) {
                    throw NSError(domain: "AuthError", code: apiResponse.code, userInfo: [
                        NSLocalizedDescriptionKey: apiResponse.message
                    ])
                } else {
                    throw NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "登录失败 (HTTP \(httpResponse.statusCode))"
                    ])
                }
            }
            
        } catch let decodingError as DecodingError {
            throw NSError(domain: "AuthError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "响应数据解析失败，请稍后重试"
            ])
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                throw NSError(domain: "AuthError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "请求超时，请检查网络连接"
                ])
            case .notConnectedToInternet:
                throw NSError(domain: "AuthError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "网络连接失败，请检查网络设置"
                ])
            default:
                throw NSError(domain: "AuthError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "网络错误: \(urlError.localizedDescription)"
                ])
            }
        } catch {
            throw error
        }
    }
    
    // 手机号登录
    func loginWithPhone(_ phoneNumber: String, verificationCode: String) async -> LoginResult {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        // 基本验证
        if phoneNumber.isEmpty || verificationCode.isEmpty {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "手机号或验证码不能为空"
            }
            return .failure("手机号或验证码不能为空")
        }
        
        // 调用API
        do {
            let loginRequest = SmsLoginRequest(
                mobile: phoneNumber,
                code: verificationCode
            )
            
            let user = try await performSmsLogin(request: loginRequest)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.saveAuthState()
            }
            
            return .success(user)
        } catch {
            let errorMessage = error.localizedDescription
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = errorMessage
            }
            return .failure(errorMessage)
        }
    }
    
    // 执行短信登录API请求
    private func performSmsLogin(request: SmsLoginRequest) async throws -> User {
        guard let url = URL(string: "\(apiBaseURL)/thingz/api/user/sms-login") else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "无效的API地址"
            ])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30.0 // 30秒超时
        
        do {
            let requestData = try JSONEncoder().encode(request)
            urlRequest.httpBody = requestData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "服务器响应异常"
                ])
            }
            
            // 根据HTTP状态码判断
            if httpResponse.statusCode == 200 {
                // 解析响应
                let apiResponse = try JSONDecoder().decode(APIResponse<LoginResponse>.self, from: data)

                if apiResponse.code == 200, let loginData = apiResponse.data {
                    // 保存token
                    self.authToken = loginData.token

                    // 创建用户对象
                    let user = User(
                        username: loginData.userInfo.nickname ?? loginData.userInfo.mobile,
                        email: nil,
                        phoneNumber: loginData.userInfo.mobile,
                        avatar: loginData.userInfo.avatar,
                        loginMethod: .phone
                    )

                    return user
                } else {
                    throw NSError(domain: "AuthError", code: apiResponse.code, userInfo: [
                        NSLocalizedDescriptionKey: apiResponse.message
                    ])
                }
            } else {
                // 尝试解析错误响应
                if let apiResponse = try? JSONDecoder().decode(APIResponse<LoginResponse>.self, from: data) {
                    throw NSError(domain: "AuthError", code: apiResponse.code, userInfo: [
                        NSLocalizedDescriptionKey: apiResponse.message
                    ])
                } else {
                    throw NSError(domain: "AuthError", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "登录失败 (HTTP \(httpResponse.statusCode))"
                    ])
                }
            }
            
        } catch {
            throw error
        }
    }
    
    // 微信登录 - 已注释
    /*
    func loginWithWechat() async -> LoginResult {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = ""
        }

        // 模拟网络请求
        await Task.sleep(1_500_000_000) // 1.5秒延迟

        // 模拟微信登录成功
        let user = User(
            username: "微信用户",
            loginMethod: .wechat
        )

        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveAuthState()
        }

        return .success(user)
    }
    */
    
    // Apple ID登录 - 已注释
    /*
    func loginWithApple(authorization: ASAuthorization) -> LoginResult {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return .failure("Apple ID 认证失败")
        }

        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email

        let username = fullName?.givenName ?? "Apple用户"

        let user = User(
            username: username,
            email: email,
            loginMethod: .apple
        )

        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveAuthState()
        }

        return .success(user)
    }
    */
    
    // 发送验证码
    func sendVerificationCode(to phoneNumber: String) async -> Bool {
        guard let url = URL(string: "\(apiBaseURL)/thingz/api/user/send-sms-code") else {
            DispatchQueue.main.async {
                self.errorMessage = "无效的API地址"
            }
            return false
        }
        
        let request = SendSmsCodeRequest(mobile: phoneNumber)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30.0
        
        do {
            let requestData = try JSONEncoder().encode(request)
            urlRequest.httpBody = requestData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "服务器响应异常"
                }
                return false
            }
            
            if httpResponse.statusCode == 200 {
                let apiResponse = try JSONDecoder().decode(APIResponse<SendCodeResponse>.self, from: data)
                
                if apiResponse.code == 200 {
                    return true
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = apiResponse.message
                    }
                    return false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "发送验证码失败 (HTTP \(httpResponse.statusCode))"
                }
                return false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // 登出
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = ""

        // 清除存储的认证信息
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: authKey)
        // 清除token
        authToken = nil
    }
    
    // 检查登录状态
    func checkAuthStatus() {
        loadAuthState()
    }

    // MARK: - Token管理

    /// 检查token是否有效（简化版本，因为新API没有refresh token机制）
    /// - Returns: token有效返回true，否则返回false
    func isTokenValid() -> Bool {
        return authToken != nil && !authToken!.isEmpty
    }
} 
