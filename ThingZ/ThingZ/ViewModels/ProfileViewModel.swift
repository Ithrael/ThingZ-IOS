import Foundation
import SwiftUI
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userInfo: UserInfoResponse?
    @Published var isLoading = false
    @Published var isUpdating = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    /// 加载用户信息
    func loadUserInfo() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let info = try await UserAPIService.shared.getCurrentUserInfo()
            userInfo = info
            isLoading = false

            // 同步到AuthManager
            try? await AuthManager.shared.refreshUserInfo()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载用户信息失败: \(error)")
        }
    }

    /// 更新用户昵称
    func updateNickname(nick: String) async {
        guard !isUpdating else { return }

        isUpdating = true
        errorMessage = nil
        successMessage = nil

        do {
            try await AuthManager.shared.updateNickname(nick: nick)
            successMessage = "昵称更新成功"
            isUpdating = false
            // 重新加载用户信息
            await loadUserInfo()
        } catch {
            isUpdating = false
            errorMessage = error.localizedDescription
            print("更新昵称失败: \(error)")
        }
    }

    /// 更新用户头像
    func updateAvatar(image: UIImage) async {
        guard !isUpdating else { return }

        isUpdating = true
        errorMessage = nil
        successMessage = nil

        do {
            // 上传图片
            let avatarUrl = try await FileUploadService.shared.uploadImage(
                image,
                type: .avatar,
                compressionQuality: 0.7
            )

            // 更新头像
            try await AuthManager.shared.updateAvatar(avatarUrl: avatarUrl)
            successMessage = "头像更新成功"
            isUpdating = false
            // 重新加载用户信息
            await loadUserInfo()
        } catch {
            isUpdating = false
            errorMessage = error.localizedDescription
            print("更新头像失败: \(error)")
        }
    }

    /// 修改密码
    func changePassword(newPassword: String, confirmPassword: String) async {
        guard !isUpdating else { return }

        // 验证密码
        guard newPassword == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return
        }

        guard newPassword.count >= 6 else {
            errorMessage = "密码长度至少为6位"
            return
        }

        isUpdating = true
        errorMessage = nil
        successMessage = nil

        do {
            try await AuthManager.shared.changePassword(
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
            successMessage = "密码修改成功"
            isUpdating = false
        } catch {
            isUpdating = false
            errorMessage = error.localizedDescription
            print("修改密码失败: \(error)")
        }
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }

    /// 清空成功信息
    func clearSuccess() {
        successMessage = nil
    }
}
