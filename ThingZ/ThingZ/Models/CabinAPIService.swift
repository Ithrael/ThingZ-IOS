import Foundation

// MARK: - 小屋权限枚举
enum CabinPermission: String, Codable {
    case owner = "owner"         // 所有者（完全控制权）
    case admin = "admin"         // 管理员（管理成员和内容）
    case write = "write"         // 写入权限（可编辑内容）
    case read = "read"           // 只读权限（仅查看）

    var displayName: String {
        switch self {
        case .owner:
            return "所有者"
        case .admin:
            return "管理员"
        case .write:
            return "编辑"
        case .read:
            return "只读"
        }
    }
}

// MARK: - 小屋API请求模型
struct CreateCabinRequest: Codable {
    let name: String
    let description: String?
    let maxMembers: Int?
}

struct UpdateCabinRequest: Codable {
    let name: String?
    let description: String?
    let maxMembers: Int?
    let status: String?
}

struct InviteMemberRequest: Codable {
    let inviteeId: String
    let permission: String
}

struct JoinCabinRequest: Codable {
    let inviteCode: String
}

struct UpdatePermissionRequest: Codable {
    let permission: String
}

// MARK: - 小屋API响应模型
struct APICabin: Codable {
    let id: String
    let name: String
    let description: String?
    let ownerId: String
    let ownerNick: String?
    let maxMembers: Int
    let currentMembers: Int
    let status: String
    let createdAt: String
    let updatedAt: String
}

struct APICabinMember: Codable {
    let id: String
    let cabinId: String
    let userId: String
    let userNick: String?
    let avatarUrl: String?
    let permission: String
    let joinedAt: String
}

struct APICabinInvitation: Codable {
    let id: String
    let cabinId: String
    let cabinName: String
    let inviterId: String
    let inviterNick: String?
    let inviteeId: String
    let inviteeNick: String?
    let permission: String
    let inviteCode: String
    let status: String
    let expiresAt: String
    let createdAt: String
}

struct JoinCabinResponse: Codable {
    let cabinId: String
    let cabinName: String
    let memberId: String
    let permission: String
    let joinedAt: String
}

// MARK: - 小屋API服务
class CabinAPIService {
    static let shared = CabinAPIService()

    private init() {}

    // MARK: - 小屋CRUD操作

    /// 获取小屋列表
    func getCabins() async throws -> [APICabin] {
        let response: APIResponse<[APICabin]> = try await APIService.shared.request(
            endpoint: "/v1/cabins",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let cabins = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return cabins
    }

    /// 创建小屋
    func createCabin(request: CreateCabinRequest) async throws -> APICabin {
        let response: APIResponse<APICabin> = try await APIService.shared.request(
            endpoint: "/v1/cabins",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let cabin = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return cabin
    }

    /// 获取小屋详情
    func getCabinDetail(cabinId: String) async throws -> APICabin {
        let response: APIResponse<APICabin> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let cabin = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return cabin
    }

    /// 更新小屋信息
    func updateCabin(cabinId: String, request: UpdateCabinRequest) async throws -> APICabin {
        let response: APIResponse<APICabin> = try await APIService.shared.request(
            endpoint: "/v1/cabins/modify/\(cabinId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let cabin = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return cabin
    }

    /// 删除小屋
    func deleteCabin(cabinId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/cabins/remove/\(cabinId)",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    // MARK: - 成员管理

    /// 邀请成员加入小屋
    func inviteMember(cabinId: String, request: InviteMemberRequest) async throws -> APICabinInvitation {
        let response: APIResponse<APICabinInvitation> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)/invite",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let invitation = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return invitation
    }

    /// 加入小屋
    func joinCabin(cabinId: String, request: JoinCabinRequest) async throws -> JoinCabinResponse {
        let response: APIResponse<JoinCabinResponse> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)/join",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let joinResponse = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return joinResponse
    }

    /// 移除成员
    func removeMember(cabinId: String, userId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)/remove-member/\(userId)",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 更新成员权限
    func updateMemberPermission(cabinId: String, userId: String, request: UpdatePermissionRequest) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)/change-permission/\(userId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 获取小屋成员列表
    func getCabinMembers(cabinId: String) async throws -> [APICabinMember] {
        let response: APIResponse<[APICabinMember]> = try await APIService.shared.request(
            endpoint: "/v1/cabins/\(cabinId)/members",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let members = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return members
    }

    // MARK: - 邀请管理

    /// 获取待处理邀请列表
    func getPendingInvitations() async throws -> [APICabinInvitation] {
        let response: APIResponse<[APICabinInvitation]> = try await APIService.shared.request(
            endpoint: "/v1/cabins/invitations/pending",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let invitations = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return invitations
    }
}

// MARK: - 小屋数据模型（用于本地）
struct Cabin: Identifiable, Codable {
    let id: String
    var name: String
    var description: String?
    var ownerId: String
    var ownerNick: String?
    var maxMembers: Int
    var currentMembers: Int
    var status: String
    var members: [CabinMember]?
    var createdAt: Date?
    var updatedAt: Date?

    /// 从API模型创建Cabin
    static func from(apiCabin: APICabin) -> Cabin {
        let dateFormatter = ISO8601DateFormatter()

        return Cabin(
            id: apiCabin.id,
            name: apiCabin.name,
            description: apiCabin.description,
            ownerId: apiCabin.ownerId,
            ownerNick: apiCabin.ownerNick,
            maxMembers: apiCabin.maxMembers,
            currentMembers: apiCabin.currentMembers,
            status: apiCabin.status,
            members: nil,
            createdAt: dateFormatter.date(from: apiCabin.createdAt),
            updatedAt: dateFormatter.date(from: apiCabin.updatedAt)
        )
    }

    /// 转换为创建请求
    func toCreateRequest() -> CreateCabinRequest {
        return CreateCabinRequest(
            name: name,
            description: description,
            maxMembers: maxMembers
        )
    }

    /// 转换为更新请求
    func toUpdateRequest() -> UpdateCabinRequest {
        return UpdateCabinRequest(
            name: name,
            description: description,
            maxMembers: maxMembers,
            status: status
        )
    }
}

// MARK: - 小屋成员模型（用于本地）
struct CabinMember: Identifiable, Codable {
    let id: String
    let cabinId: String
    let userId: String
    var userNick: String?
    var avatarUrl: String?
    var permission: CabinPermission
    var joinedAt: Date?

    /// 从API模型创建CabinMember
    static func from(apiMember: APICabinMember) -> CabinMember {
        let dateFormatter = ISO8601DateFormatter()

        return CabinMember(
            id: apiMember.id,
            cabinId: apiMember.cabinId,
            userId: apiMember.userId,
            userNick: apiMember.userNick,
            avatarUrl: apiMember.avatarUrl,
            permission: CabinPermission(rawValue: apiMember.permission) ?? .read,
            joinedAt: dateFormatter.date(from: apiMember.joinedAt)
        )
    }
}

// MARK: - 小屋邀请模型（用于本地）
struct CabinInvitation: Identifiable, Codable {
    let id: String
    let cabinId: String
    var cabinName: String
    let inviterId: String
    var inviterNick: String?
    let inviteeId: String
    var inviteeNick: String?
    var permission: CabinPermission
    var inviteCode: String
    var status: String
    var expiresAt: Date?
    var createdAt: Date?

    /// 从API模型创建CabinInvitation
    static func from(apiInvitation: APICabinInvitation) -> CabinInvitation {
        let dateFormatter = ISO8601DateFormatter()

        return CabinInvitation(
            id: apiInvitation.id,
            cabinId: apiInvitation.cabinId,
            cabinName: apiInvitation.cabinName,
            inviterId: apiInvitation.inviterId,
            inviterNick: apiInvitation.inviterNick,
            inviteeId: apiInvitation.inviteeId,
            inviteeNick: apiInvitation.inviteeNick,
            permission: CabinPermission(rawValue: apiInvitation.permission) ?? .read,
            inviteCode: apiInvitation.inviteCode,
            status: apiInvitation.status,
            expiresAt: dateFormatter.date(from: apiInvitation.expiresAt),
            createdAt: dateFormatter.date(from: apiInvitation.createdAt)
        )
    }
}
