import SwiftUI

// MARK: - 过期物品视图
struct ExpirationItemsView: View {
    @StateObject private var viewModel = ExpirationItemsViewModel()
    @State private var selectedDays: Int = 7

    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.warmGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 天数选择器
                    Picker("提醒范围", selection: $selectedDays) {
                        Text("3天").tag(3)
                        Text("7天").tag(7)
                        Text("15天").tag(15)
                        Text("30天").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedDays) { newValue in
                        Task {
                            await viewModel.loadNearExpirationItems(days: newValue)
                        }
                    }

                    // 统计卡片
                    HStack(spacing: Theme.Spacing.medium) {
                        StatCard(
                            title: "即将过期",
                            value: "\(viewModel.nearExpirationItems.count)",
                            icon: "exclamationmark.triangle.fill",
                            color: Theme.Colors.warningYellow
                        )

                        StatCard(
                            title: "已过期",
                            value: "\(viewModel.expiredItems.count)",
                            icon: "xmark.circle.fill",
                            color: Theme.Colors.errorRed
                        )
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        LoadingView(message: "加载中...")
                    } else if viewModel.nearExpirationItems.isEmpty && viewModel.expiredItems.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle.fill",
                            title: "太棒了！",
                            message: "暂无即将过期或已过期的物品"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.Spacing.medium) {
                                // 已过期物品
                                if !viewModel.expiredItems.isEmpty {
                                    SectionHeader(title: "已过期", count: viewModel.expiredItems.count)

                                    ForEach(viewModel.expiredItems, id: \.id) { item in
                                        ExpirationItemCard(item: item, isExpired: true)
                                    }
                                }

                                // 即将过期物品
                                if !viewModel.nearExpirationItems.isEmpty {
                                    SectionHeader(title: "即将过期（\(selectedDays)天内）", count: viewModel.nearExpirationItems.count)

                                    ForEach(viewModel.nearExpirationItems, id: \.id) { item in
                                        ExpirationItemCard(item: item, isExpired: false)
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh(days: selectedDays)
                        }
                    }
                }
            }
            .navigationTitle("过期提醒")
            .task {
                await viewModel.loadData(days: selectedDays)
            }
        }
    }
}

// MARK: - 区域标题
struct SectionHeader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.title3)
                .foregroundColor(Theme.Colors.primaryText)

            Text("(\(count))")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondaryText)

            Spacer()
        }
        .padding(.top, Theme.Spacing.medium)
    }
}

// MARK: - 过期物品卡片
struct ExpirationItemCard: View {
    let item: APIItem
    let isExpired: Bool

    var body: some View {
        CardView {
            HStack(spacing: Theme.Spacing.medium) {
                // 状态图标
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: statusIcon)
                        .font(.system(size: Theme.IconSize.large))
                        .foregroundColor(statusColor)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text(item.name)
                        .font(Theme.Fonts.bodyBold)
                        .foregroundColor(Theme.Colors.primaryText)

                    if let expirationDate = item.expirationDate {
                        HStack(spacing: Theme.Spacing.tiny) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("过期时间: \(expirationDate)")
                                .font(Theme.Fonts.caption1)
                        }
                        .foregroundColor(Theme.Colors.secondaryText)
                    }

                    if let days = daysUntilExpiration {
                        Text(days)
                            .font(Theme.Fonts.caption1)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, Theme.Spacing.small)
                            .padding(.vertical, Theme.Spacing.tiny)
                            .background(statusColor.opacity(0.1))
                            .cornerRadius(Theme.CornerRadius.small)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.Colors.tertiaryText)
            }
        }
    }

    private var statusColor: Color {
        isExpired ? Theme.Colors.errorRed : Theme.Colors.warningYellow
    }

    private var statusIcon: String {
        isExpired ? "xmark.circle.fill" : "exclamationmark.triangle.fill"
    }

    private var daysUntilExpiration: String? {
        guard let expirationDateStr = item.expirationDate else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let expirationDate = formatter.date(from: expirationDateStr) else { return nil }

        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0

        if days < 0 {
            return "已过期 \(abs(days)) 天"
        } else if days == 0 {
            return "今天过期"
        } else {
            return "还有 \(days) 天过期"
        }
    }
}

// MARK: - 过期物品ViewModel
@MainActor
class ExpirationItemsViewModel: ObservableObject {
    @Published var nearExpirationItems: [APIItem] = []
    @Published var expiredItems: [APIItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadData(days: Int) async {
        isLoading = true

        async let nearTask = loadNearExpirationItems(days: days)
        async let expiredTask = loadExpiredItems()

        await nearTask
        await expiredTask

        isLoading = false
    }

    func loadNearExpirationItems(days: Int) async {
        do {
            nearExpirationItems = try await ItemAPIService.shared.getNearExpirationItems(days: days)
        } catch {
            errorMessage = "加载即将过期物品失败: \(error.localizedDescription)"
        }
    }

    func loadExpiredItems() async {
        do {
            expiredItems = try await ItemAPIService.shared.getExpiredItems()
        } catch {
            errorMessage = "加载已过期物品失败: \(error.localizedDescription)"
        }
    }

    func refresh(days: Int) async {
        await loadData(days: days)
    }
}

// MARK: - 预览
#Preview {
    ExpirationItemsView()
}
