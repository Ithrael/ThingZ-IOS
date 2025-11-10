import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var apiItems: [APIItem] = []
    @Published var apiContainers: [APIContainerItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var searchTask: Task<Void, Never>?

    /// 搜索物品和容器
    func search(keyword: String) {
        // 取消之前的搜索任务
        searchTask?.cancel()

        // 如果关键词为空，清空结果
        guard !keyword.isEmpty, keyword.count >= 2 else {
            apiItems = []
            apiContainers = []
            return
        }

        // 创建新的搜索任务（去抖动）
        searchTask = Task {
            // 等待300ms避免频繁请求
            try? await Task.sleep(nanoseconds: 300_000_000)

            // 检查任务是否被取消
            guard !Task.isCancelled else { return }

            isLoading = true
            errorMessage = nil

            do {
                // 并发搜索物品和容器
                async let items = ItemAPIService.shared.getItems(keyword: keyword)
                async let containers = ContainerAPIService.shared.getContainers()

                let (fetchedItems, fetchedContainers) = try await (items, containers)

                // 过滤容器（本地过滤，因为API可能不支持容器搜索）
                let filteredContainers = fetchedContainers.filter {
                    $0.name.localizedCaseInsensitiveContains(keyword) ||
                    ($0.location?.localizedCaseInsensitiveContains(keyword) ?? false)
                }

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.apiItems = fetchedItems
                    self.apiContainers = filteredContainers
                    self.isLoading = false
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("搜索失败: \(error)")
                }
            }
        }
    }

    /// 清空搜索结果
    func clearResults() {
        searchTask?.cancel()
        apiItems = []
        apiContainers = []
        isLoading = false
        errorMessage = nil
    }
}
