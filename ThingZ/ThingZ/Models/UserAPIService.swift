import Foundation

// MARK: - 用户API请求模型
struct UserInfoUpdateRequest: Codable {
    let nick: String?
    let avatarUrl: String?
}

struct UserPasswordUpdateRequest: Codable {
    let password: String
    let confirmPassword: String
}

struct UserNickUpdateRequest: Codable {
    let nick: String
}

struct UserAvatarUpdateRequest: Codable {
    let avatarUrl: String
}

// MARK: - 用户API响应模型
struct UserInfoResponse: Codable {
    let id: String
    let username: String?
    let phone: String
    let email: String?
    let avatarUrl: String?
    let nick: String?
    let status: String?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - 用户API服务
class UserAPIService {
    static let shared = UserAPIService()

    private init() {}

    // MARK: - 用户信息查询

    /// 获取当前用户信息
    func getCurrentUserInfo() async throws -> UserInfoResponse {
        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/info",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 根据ID获取用户信息
    /// - Parameter userId: 用户ID
    func getUserInfo(userId: String) async throws -> UserInfoResponse {
        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/\(userId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    // MARK: - 用户信息更新

    /// 更新当前用户信息
    func updateCurrentUserInfo(request: UserInfoUpdateRequest) async throws -> UserInfoResponse {
        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/modify-info",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 更新指定用户信息（需要管理员权限）
    func updateUserInfo(userId: String, request: UserInfoUpdateRequest) async throws -> UserInfoResponse {
        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/modify/\(userId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 更新用户头像
    func updateUserAvatar(avatarUrl: String) async throws -> UserInfoResponse {
        let request = UserAvatarUpdateRequest(avatarUrl: avatarUrl)

        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/change-avatar",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 更新用户昵称
    func updateUserNick(nick: String) async throws -> UserInfoResponse {
        let request = UserNickUpdateRequest(nick: nick)

        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/change-nick",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 更新用户密码
    func updateUserPassword(newPassword: String, confirmPassword: String) async throws -> UserInfoResponse {
        let request = UserPasswordUpdateRequest(password: newPassword, confirmPassword: confirmPassword)

        let response: APIResponse<UserInfoResponse> = try await APIService.shared.request(
            endpoint: "/api/user/change-password",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let userInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return userInfo
    }

    /// 修改密码v2（需要旧密码验证）
    func changePasswordV2(oldPassword: String, newPassword: String) async throws {
        struct ChangePasswordV2Request: Codable {
            let oldPassword: String
            let newPassword: String
        }

        let request = ChangePasswordV2Request(oldPassword: oldPassword, newPassword: newPassword)

        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/change-password-v2",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 刷新令牌
    func refreshToken() async throws -> (token: String, refreshToken: String) {
        let response: APIResponse<TokenResponse> = try await APIService.shared.request(
            endpoint: "/api/user/refresh-token",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200, let tokenData = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return (tokenData.token, tokenData.refreshToken)
    }

    /// 修改用户资料
    func changeProfile(nick: String?, avatarUrl: String?, email: String?) async throws {
        struct ChangeProfileRequest: Codable {
            let nick: String?
            let avatarUrl: String?
            let email: String?
        }

        let request = ChangeProfileRequest(nick: nick, avatarUrl: avatarUrl, email: email)

        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/change-profile",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 设置用户权限
    func setAuth(permissions: [String]) async throws {
        struct SetAuthRequest: Codable {
            let permissions: [String]
        }

        let request = SetAuthRequest(permissions: permissions)

        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/set-auth",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }
}

// MARK: - Token响应模型
struct TokenResponse: Codable {
    let token: String
    let refreshToken: String
}

// MARK: - AuthManager扩展 - 集成用户API
extension AuthManager {
    /// 刷新当前用户信息
    func refreshUserInfo() async throws {
        let userInfo = try await UserAPIService.shared.getCurrentUserInfo()

        await MainActor.run {
            // 更新当前用户信息
            if var user = self.currentUser {
                user.username = userInfo.username ?? userInfo.phone
                user.email = userInfo.email
                user.phoneNumber = userInfo.phone
                user.avatar = userInfo.avatarUrl
                self.currentUser = user
                self.saveAuthState()
            }
        }
    }

    /// 更新用户头像
    func updateAvatar(avatarUrl: String) async throws {
        let userInfo = try await UserAPIService.shared.updateUserAvatar(avatarUrl: avatarUrl)

        await MainActor.run {
            if var user = self.currentUser {
                user.avatar = userInfo.avatarUrl
                self.currentUser = user
                self.saveAuthState()
            }
        }
    }

    /// 更新用户昵称
    func updateNickname(nick: String) async throws {
        let userInfo = try await UserAPIService.shared.updateUserNick(nick: nick)

        await MainActor.run {
            if var user = self.currentUser {
                user.username = userInfo.nick ?? userInfo.username ?? user.username
                self.currentUser = user
                self.saveAuthState()
            }
        }
    }

    /// 修改密码
    func changePassword(newPassword: String, confirmPassword: String) async throws {
        _ = try await UserAPIService.shared.updateUserPassword(
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
    }
}

// MARK: - 认证API扩展
extension AuthManager {
    /// 退出登录（调用API）
    func logoutFromServer() async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/logout",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }

        // 清除本地认证信息
        await MainActor.run {
            self.logout()
        }
    }

    /// 注册新用户
    func register(mobile: String, password: String, code: String) async throws -> User {
        struct RegisterRequest: Codable {
            let mobile: String
            let password: String
            let code: String
        }

        let request = RegisterRequest(mobile: mobile, password: password, code: code)

        let response: APIResponse<LoginResponse> = try await APIService.shared.request(
            endpoint: "/api/user/register",
            method: .POST,
            body: request,
            requiresAuth: false
        )

        guard response.code == 200, let loginData = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        // 保存token
        await MainActor.run {
            self.authToken = loginData.token
        }

        // 创建用户对象
        let user = User(
            username: loginData.userInfo.nickname ?? loginData.userInfo.mobile,
            email: nil,
            phoneNumber: loginData.userInfo.mobile,
            avatar: loginData.userInfo.avatar,
            loginMethod: .phone
        )

        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.saveAuthState()
        }

        return user
    }

    /// 忘记密码
    func forgotPassword(mobile: String, code: String, newPassword: String) async throws {
        struct ForgotPasswordRequest: Codable {
            let mobile: String
            let code: String
            let newPassword: String
        }

        let request = ForgotPasswordRequest(mobile: mobile, code: code, newPassword: newPassword)

        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/forgot-password",
            method: .POST,
            body: request,
            requiresAuth: false
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 重置密码
    func resetPassword(mobile: String, code: String, newPassword: String) async throws {
        struct ResetPasswordRequest: Codable {
            let mobile: String
            let code: String
            let newPassword: String
        }

        let request = ResetPasswordRequest(mobile: mobile, code: code, newPassword: newPassword)

        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/api/user/reset-password",
            method: .POST,
            body: request,
            requiresAuth: false
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }
}
