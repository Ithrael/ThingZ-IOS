import Foundation

// MARK: - 物品API请求模型
struct CreateItemRequest: Codable {
    let name: String
    let category: String
    let containerId: String?
    let quantity: Int?
    let unit: String?
    let imageUrl: String?
    let description: String?
    let purchaseDate: String?
    let expirationDate: String?
    let price: Double?
    let brand: String?
    let model: String?
    let status: String?
}

struct UpdateItemRequest: Codable {
    let name: String?
    let category: String?
    let containerId: String?
    let quantity: Int?
    let unit: String?
    let imageUrl: String?
    let description: String?
    let purchaseDate: String?
    let expirationDate: String?
    let price: Double?
    let brand: String?
    let model: String?
    let status: String?
}

struct BatchUpdateStatusRequest: Codable {
    let itemIds: [String]
    let status: String
}

// MARK: - 物品API响应模型
struct APIItem: Codable {
    let id: String
    let name: String
    let category: String
    let containerId: String?
    let quantity: Int?
    let unit: String?
    let imageUrl: String?
    let description: String?
    let purchaseDate: String?
    let expirationDate: String?
    let price: Double?
    let brand: String?
    let model: String?
    let status: String
    let userId: String
    let createdAt: String
    let updatedAt: String
    let isDeleted: Bool
}

struct ItemListResponse: Codable {
    let items: [APIItem]
    let total: Int
    let page: Int
    let size: Int
}

struct ItemCountResponse: Codable {
    let counts: [String: Int]
}

// MARK: - 物品API服务
class ItemAPIService {
    static let shared = ItemAPIService()

    private init() {}

    // MARK: - 物品CRUD操作

    /// 获取物品列表
    func getItems(page: Int = 0, size: Int = 20, keyword: String? = nil) async throws -> [APIItem] {
        var parameters: [String: Any] = [
            "page": page,
            "size": size
        ]
        if let keyword = keyword {
            parameters["keyword"] = keyword
        }

        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items",
            method: .GET,
            parameters: parameters,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    /// 创建物品
    func createItem(request: CreateItemRequest) async throws -> APIItem {
        let response: APIResponse<APIItem> = try await APIService.shared.request(
            endpoint: "/v1/items",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let item = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return item
    }

    /// 获取物品详情
    func getItemDetail(itemId: String) async throws -> APIItem {
        let response: APIResponse<APIItem> = try await APIService.shared.request(
            endpoint: "/v1/items/\(itemId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let item = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return item
    }

    /// 更新物品
    func updateItem(itemId: String, request: UpdateItemRequest) async throws -> APIItem {
        let response: APIResponse<APIItem> = try await APIService.shared.request(
            endpoint: "/v1/items/modify/\(itemId)",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let item = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return item
    }

    /// 删除物品
    func deleteItem(itemId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/remove/\(itemId)",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 批量删除物品
    func batchDeleteItems(itemIds: [String]) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/batch/remove",
            method: .POST,
            body: itemIds,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    // MARK: - 物品状态管理

    /// 批量更新物品状态
    func batchUpdateItemStatus(itemIds: [String], status: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/batch/change-status",
            method: .POST,
            parameters: ["status": status],
            body: itemIds,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 移动物品到容器
    func moveItem(itemId: String, containerId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/\(itemId)/move-to-container",
            method: .POST,
            parameters: ["containerId": containerId],
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 放入物品
    func putInItem(itemId: String, containerId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/\(itemId)/put-in-container",
            method: .POST,
            parameters: ["containerId": containerId],
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 取出物品
    func takeOutItem(itemId: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/v1/items/\(itemId)/take-out-item",
            method: .POST,
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    // MARK: - 物品查询

    /// 获取容器中的物品
    func getItemsByContainer(containerId: String) async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items/container/\(containerId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    /// 按分类获取物品
    func getItemsByCategory(category: String) async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items/category/\(category)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    /// 按状态获取物品
    func getItemsByStatus(status: String) async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items/status/\(status)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    /// 获取即将过期的物品
    func getNearExpirationItems(days: Int = 7) async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items/near-expiration",
            method: .GET,
            parameters: ["days": days],
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    /// 获取已过期的物品
    func getExpiredItems() async throws -> [APIItem] {
        let response: APIResponse<[APIItem]> = try await APIService.shared.request(
            endpoint: "/v1/items/expired",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let items = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return items
    }

    // MARK: - 统计功能

    /// 按分类统计物品数量
    func getItemCountByCategory() async throws -> [String: Int] {
        let response: APIResponse<[String: Int]> = try await APIService.shared.request(
            endpoint: "/v1/items/count/category",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let counts = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return counts
    }

    /// 按状态统计物品数量
    func getItemCountByStatus() async throws -> [String: Int] {
        let response: APIResponse<[String: Int]> = try await APIService.shared.request(
            endpoint: "/v1/items/count/status",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let counts = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return counts
    }

    /// 统计容器物品数量
    func getItemCountByContainer(containerId: String) async throws -> Int {
        let response: APIResponse<Int> = try await APIService.shared.request(
            endpoint: "/v1/items/count/container/\(containerId)",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let count = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return count
    }
}

// MARK: - 物品类型映射扩展
extension ItemType {
    var apiCategory: String {
        switch self {
        case .clothing:
            return "服饰"
        case .food:
            return "食品"
        case .cosmetics:
            return "化妆品"
        case .miscellaneous:
            return "杂物"
        }
    }

    static func from(apiCategory: String) -> ItemType {
        switch apiCategory {
        case "服饰":
            return .clothing
        case "食品":
            return .food
        case "化妆品":
            return .cosmetics
        default:
            return .miscellaneous
        }
    }
}

// MARK: - 物品状态定义
enum ItemStatus: String {
    case inContainer = "IN_CONTAINER"
    case takenOut = "TAKEN_OUT"
    case expired = "EXPIRED"
    case normal = "NORMAL"

    var displayName: String {
        switch self {
        case .inContainer:
            return "在容器中"
        case .takenOut:
            return "已取出"
        case .expired:
            return "已过期"
        case .normal:
            return "正常"
        }
    }
}
