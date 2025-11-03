import Foundation
import SwiftUI

@MainActor
class ContainerViewModel: ObservableObject {
    @Published var containers: [APIContainerItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    /// 加载容器列表
    func loadContainers() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let apiContainers = try await ContainerAPIService.shared.getContainers()
            containers = apiContainers
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载容器列表失败: \(error)")
        }
    }

    /// 刷新容器列表
    func refresh() async {
        isRefreshing = true
        await loadContainers()
        isRefreshing = false
    }

    /// 创建容器
    func createContainer(request: CreateContainerRequest) async throws -> APIContainerItem {
        let container = try await ContainerAPIService.shared.createContainer(request: request)
        // 刷新列表
        await loadContainers()
        return container
    }

    /// 更新容器
    func updateContainer(containerId: String, request: UpdateContainerAPIRequest) async throws {
        _ = try await ContainerAPIService.shared.updateContainer(containerId: containerId, request: request)
        // 刷新列表
        await loadContainers()
    }

    /// 删除容器
    func deleteContainer(containerId: String) async throws {
        try await ContainerAPIService.shared.deleteContainer(containerId: containerId)
        // 从列表中移除
        containers.removeAll { $0.id == containerId }
    }

    /// 生成容器二维码
    func generateQRCode(containerId: String) async throws -> String {
        return try await ContainerAPIService.shared.generateQRCode(containerId: containerId)
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }
}
