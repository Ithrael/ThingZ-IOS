import Foundation
import SwiftUI

@MainActor
class ItemListViewModel: ObservableObject {
    @Published var items: [APIItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var hasMore = true

    private let pageSize = 20

    /// 加载物品列表（首页）
    func loadItems(keyword: String? = nil) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 0

        do {
            let apiItems = try await ItemAPIService.shared.getItems(
                page: currentPage,
                size: pageSize,
                keyword: keyword
            )

            items = apiItems
            hasMore = apiItems.count == pageSize
            currentPage = 1

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("加载物品列表失败: \(error)")
        }
    }

    /// 加载更多物品
    func loadMore(keyword: String? = nil) async {
        guard !isLoadingMore, !isLoading, hasMore else { return }

        isLoadingMore = true

        do {
            let apiItems = try await ItemAPIService.shared.getItems(
                page: currentPage,
                size: pageSize,
                keyword: keyword
            )

            items.append(contentsOf: apiItems)
            hasMore = apiItems.count == pageSize
            currentPage += 1

            isLoadingMore = false
        } catch {
            isLoadingMore = false
            errorMessage = error.localizedDescription
            print("加载更多物品失败: \(error)")
        }
    }

    /// 刷新物品列表
    func refresh(keyword: String? = nil) async {
        await loadItems(keyword: keyword)
    }

    /// 清空错误信息
    func clearError() {
        errorMessage = nil
    }
}
