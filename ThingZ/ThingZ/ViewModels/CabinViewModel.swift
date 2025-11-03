import Foundation
import SwiftUI

@MainActor
class CabinViewModel: ObservableObject {
    @Published var cabins: [APICabin] = []
    @Published var pendingInvitations: [APICabinInvitation] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    /// 加载小屋列表
    func loadCabins() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let apiCabins = try await CabinAPIService.shared.getCabins()
            cabins = apiCabins
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载小屋列表失败: \(error)")
        }
    }

    /// 加载待处理邀请
    func loadPendingInvitations() async {
        do {
            let invitations = try await CabinAPIService.shared.getPendingInvitations()
            pendingInvitations = invitations
        } catch {
            errorMessage = error.localizedDescription
            print("加载邀请列表失败: \(error)")
        }
    }

    /// 刷新
    func refresh() async {
        isRefreshing = true
        async let cabinsTask = loadCabins()
        async let invitationsTask = loadPendingInvitations()
        await cabinsTask
        await invitationsTask
        isRefreshing = false
    }

    /// 创建小屋
    func createCabin(name: String, description: String?, maxMembers: Int = 10) async throws -> APICabin {
        let request = CreateCabinRequest(
            name: name,
            description: description,
            maxMembers: maxMembers
        )
        let cabin = try await CabinAPIService.shared.createCabin(request: request)
        // 刷新列表
        await loadCabins()
        return cabin
    }

    /// 更新小屋
    func updateCabin(cabinId: String, request: UpdateCabinRequest) async throws {
        _ = try await CabinAPIService.shared.updateCabin(cabinId: cabinId, request: request)
        // 刷新列表
        await loadCabins()
    }

    /// 删除小屋
    func deleteCabin(cabinId: String) async throws {
        try await CabinAPIService.shared.deleteCabin(cabinId: cabinId)
        // 从列表中移除
        cabins.removeAll { $0.id == cabinId }
    }

    /// 加入小屋
    func joinCabin(cabinId: String, inviteCode: String) async throws {
        let request = JoinCabinRequest(inviteCode: inviteCode)
        _ = try await CabinAPIService.shared.joinCabin(cabinId: cabinId, request: request)
        // 刷新列表
        await loadCabins()
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - 小屋详情ViewModel
@MainActor
class CabinDetailViewModel: ObservableObject {
    @Published var cabin: APICabin?
    @Published var members: [APICabinMember] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    private var cabinId: String

    init(cabinId: String) {
        self.cabinId = cabinId
    }

    /// 加载小屋详情
    func loadCabinDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let cabinTask = CabinAPIService.shared.getCabinDetail(cabinId: cabinId)
            async let membersTask = CabinAPIService.shared.getCabinMembers(cabinId: cabinId)

            let (fetchedCabin, fetchedMembers) = try await (cabinTask, membersTask)

            cabin = fetchedCabin
            members = fetchedMembers
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载小屋详情失败: \(error)")
        }
    }

    /// 刷新
    func refresh() async {
        isRefreshing = true
        await loadCabinDetail()
        isRefreshing = false
    }

    /// 邀请成员
    func inviteMember(inviteeId: String, permission: CabinPermission) async throws -> APICabinInvitation {
        let request = InviteMemberRequest(
            inviteeId: inviteeId,
            permission: permission.rawValue
        )
        return try await CabinAPIService.shared.inviteMember(cabinId: cabinId, request: request)
    }

    /// 移除成员
    func removeMember(userId: String) async throws {
        try await CabinAPIService.shared.removeMember(cabinId: cabinId, userId: userId)
        // 从列表中移除
        members.removeAll { $0.userId == userId }
    }

    /// 更新成员权限
    func updateMemberPermission(userId: String, permission: CabinPermission) async throws {
        let request = UpdatePermissionRequest(permission: permission.rawValue)
        try await CabinAPIService.shared.updateMemberPermission(
            cabinId: cabinId,
            userId: userId,
            request: request
        )
        // 刷新成员列表
        await loadCabinDetail()
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }
}
