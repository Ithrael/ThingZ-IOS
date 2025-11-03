import Foundation
import SwiftUI

@MainActor
class ContainerDetailViewModel: ObservableObject {
    @Published var container: APIContainerItem?
    @Published var items: [APIItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var qrCodeUrl: String?

    private var containerId: String

    init(containerId: String) {
        self.containerId = containerId
    }

    /// 加载容器详情
    func loadContainerDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let containerTask = ContainerAPIService.shared.getContainerDetail(containerId: containerId)
            async let itemsTask = ContainerAPIService.shared.getContainerItems(containerId: containerId)

            let (fetchedContainer, fetchedItems) = try await (containerTask, itemsTask)

            container = fetchedContainer
            items = fetchedItems
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载容器详情失败: \(error)")
        }
    }

    /// 刷新容器详情
    func refresh() async {
        isRefreshing = true
        await loadContainerDetail()
        isRefreshing = false
    }

    /// 生成二维码
    func generateQRCode() async {
        do {
            let url = try await ContainerAPIService.shared.generateQRCode(containerId: containerId)
            qrCodeUrl = url
        } catch {
            errorMessage = error.localizedDescription
            print("生成二维码失败: \(error)")
        }
    }

    /// 添加物品到容器
    func addItem(request: CreateItemRequest) async throws {
        _ = try await ItemAPIService.shared.createItem(request: request)
        // 刷新物品列表
        await loadContainerDetail()
    }

    /// 从容器移除物品
    func removeItem(itemId: String) async throws {
        try await ItemAPIService.shared.deleteItem(itemId: itemId)
        // 从列表中移除
        items.removeAll { $0.id == itemId }
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }
}
