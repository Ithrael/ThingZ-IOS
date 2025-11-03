import Foundation

// MARK: - 容器API请求模型
struct CreateContainerRequest: Codable {
    let name: String
    let category: String
    let location: String?
    let description: String?
    let capacity: Int
    let room: String?
    let floor: String?
    let isShareable: Bool
    let isExpirationReminder: Bool
    let imageUrl: String?
}

struct UpdateContainerAPIRequest: Codable {
    let name: String
    let category: String?
    let location: String?
    let description: String?
    let capacity: Int?
    let room: String?
    let floor: String?
    let isShareable: Bool?
    let isExpirationReminder: Bool?
    let imageUrl: String?
}

// MARK: - 容器API响应模型
struct APIContainerItem: Codable {
    let id: String
    let name: String
    let category: String
    let location: String?
    let description: String?
    let capacity: Int
    let status: String
    let imageUrl: String?
    let qrCodeUrl: String?
    let isShareable: Bool
    let isExpirationReminder: Bool
    let room: String?
    let floor: String?
    let userId: String
    let createdAt: String
    let updatedAt: String
    let isDeleted: Bool
}

struct QRCodeResponse: Codable {
    let qrCodeUrl: String
}

struct NFCResponse: Codable {
    let nfcId: String
}

// MARK: - 容器API服务
class ContainerAPIService {
    static let shared = ContainerAPIService()

    private init() {}

    // MARK: - 容器CRUD操作

    /// 获取容器列表
    func getContainers() async throws -> [APIContainerItem] {
        let response: APIResponse<[APIContainerItem]> = try await APIService.shared.request(
            endpoint: "/v1/containers",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let containers = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return containers
    }

    /// 创建容器
    func createContainer(request: CreateContainerRequest) async throws -> APIContainerItem {
        let response: APIResponse<APIContainerItem> = try await APIService.shared.request(
            endpoint: "/v1/containers",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let container = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return container
    }

    /// 获取容器详情
    func getContainerDetail(containerId: String) async throws -> APIContainerItem {
        let response: APIResponse<APIContainerItem> = try await APIService.shared.request(
            endpoint: "/v1/containers/\(containerId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let container = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return container
    }

    /// 更新容器
    func updateContainer(containerId: String, request: UpdateContainerAPIRequest) async throws -> APIContainerItem {
        let response: APIResponse<APIContainerItem> = try await APIService.shared.request(
            endpoint: "/v1/containers/modify/\(containerId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let container = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return container
    }

    /// 删除容器
    func deleteContainer(containerId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/containers/remove/\(containerId)",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    // MARK: - 容器物品管理

    /// 获取容器中的物品
    func getContainerItems(containerId: String) async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/containers/\(containerId)/items",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    // MARK: - 二维码和NFC

    /// 生成容器二维码
    func generateQRCode(containerId: String) async throws -> String {
        let response: APIResponse<QRCodeResponse> = try await APIService.shared.request(
            endpoint: "/v1/containers/\(containerId)/qrcode",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200, let qrData = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return qrData.qrCodeUrl
    }

    /// 绑定NFC标签
    func bindNFC(containerId: String, nfcTagId: String) async throws -> String {
        struct NFCBindRequest: Encodable {
            let nfcTagId: String
        }

        let request = NFCBindRequest(nfcTagId: nfcTagId)

        let response: APIResponse<NFCResponse> = try await APIService.shared.request(
            endpoint: "/v1/containers/\(containerId)/nfc?nfcTagId=\(nfcTagId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let nfcResponse = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return nfcResponse.nfcId
    }
}

// MARK: - 容器类型映射扩展
extension ContainerType {
    var apiCategory: String {
        switch self {
        case .refrigerator:
            return "冰箱"
        case .box:
            return "箱子"
        case .wardrobe:
            return "衣柜"
        case .drawer:
            return "抽屉"
        case .cabinet:
            return "储物柜"
        }
    }

    static func from(apiCategory: String) -> ContainerType {
        switch apiCategory {
        case "冰箱":
            return .refrigerator
        case "箱子":
            return .box
        case "衣柜":
            return .wardrobe
        case "抽屉":
            return .drawer
        case "储物柜":
            return .cabinet
        default:
            return .box
        }
    }
}

// MARK: - 容器API模型转本地模型
extension Container {
    /// 从API模型创建Container
    static func from(apiContainer: APIContainerItem) -> Container {
        return Container(
            name: apiContainer.name,
            type: ContainerType.from(apiCategory: apiContainer.category),
            location: apiContainer.location ?? "未设置位置",
            capacity: apiContainer.capacity,
            apiId: apiContainer.id,
            imageUrl: apiContainer.imageUrl
        )
    }

    /// 转换为创建请求
    func toCreateRequest() -> CreateContainerRequest {
        return CreateContainerRequest(
            name: name,
            category: type.apiCategory,
            location: location,
            description: nil,
            capacity: capacity,
            room: nil,
            floor: nil,
            isShareable: false,
            isExpirationReminder: true,
            imageUrl: imageUrl
        )
    }

    /// 转换为更新请求
    func toUpdateRequest() -> UpdateContainerAPIRequest {
        return UpdateContainerAPIRequest(
            name: name,
            category: type.apiCategory,
            location: location,
            description: nil,
            capacity: capacity,
            room: nil,
            floor: nil,
            isShareable: nil,
            isExpirationReminder: nil,
            imageUrl: imageUrl
        )
    }
}
