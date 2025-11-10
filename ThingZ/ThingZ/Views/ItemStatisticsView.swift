import SwiftUI
import Charts

// MARK: - 物品统计视图
struct ItemStatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = ItemStatisticsViewModel()
    @State private var selectedPeriod: StatisticsPeriod = .week

    enum StatisticsPeriod: String, CaseIterable {
        case week = "最近一周"
        case month = "最近一月"
        case year = "最近一年"
        case all = "全部"
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.warmGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // 时间段选择器
                        Picker("统计周期", selection: $selectedPeriod) {
                            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // 总览卡片
                        OverviewCards(statistics: viewModel.statistics)

                        // 分类统计图表
                        CategoryStatisticsChart(statistics: viewModel.statistics)

                        // 容器分布图表
                        ContainerDistributionChart(statistics: viewModel.statistics)

                        // 过期趋势图表
                        ExpirationTrendChart(statistics: viewModel.statistics)

                        // 详细列表
                        StatisticsDetailList(statistics: viewModel.statistics)
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.loadStatistics(dataManager: dataManager)
                }

                if viewModel.isLoading {
                    LoadingView(message: "加载统计数据...")
                }
            }
            .navigationTitle("物品统计")
            .task {
                viewModel.loadStatistics(dataManager: dataManager)
            }
            .errorAlert($viewModel.errorMessage)
        }
    }
}

// MARK: - 总览卡片
struct OverviewCards: View {
    let statistics: ItemStatistics

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack(spacing: Theme.Spacing.medium) {
                StatCard(
                    title: "物品总数",
                    value: "\(statistics.totalItems)",
                    icon: "cube.box.fill",
                    color: Theme.Colors.pinkAccent
                )

                StatCard(
                    title: "容器数量",
                    value: "\(statistics.totalContainers)",
                    icon: "shippingbox.fill",
                    color: Theme.Colors.blueAccent
                )
            }

            HStack(spacing: Theme.Spacing.medium) {
                StatCard(
                    title: "即将过期",
                    value: "\(statistics.nearExpirationCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: Theme.Colors.warningYellow
                )

                StatCard(
                    title: "已过期",
                    value: "\(statistics.expiredCount)",
                    icon: "xmark.circle.fill",
                    color: Theme.Colors.errorRed
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 分类统计图表
struct CategoryStatisticsChart: View {
    let statistics: ItemStatistics

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("分类统计")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.primaryText)

                if statistics.categoryBreakdown.isEmpty {
                    EmptyStateView(
                        icon: "chart.pie.fill",
                        title: "暂无数据",
                        message: "还没有物品数据"
                    )
                    .frame(height: 200)
                } else {
                    Chart(statistics.categoryBreakdown) { item in
                        BarMark(
                            x: .value("数量", item.count),
                            y: .value("分类", item.category)
                        )
                        .foregroundStyle(by: .value("分类", item.category))
                        .annotation(position: .trailing) {
                            Text("\(item.count)")
                                .font(Theme.Fonts.caption1)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                    }
                    .frame(height: CGFloat(max(200, statistics.categoryBreakdown.count * 40)))
                    .chartLegend(position: .bottom)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 容器分布图表
struct ContainerDistributionChart: View {
    let statistics: ItemStatistics

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("容器分布")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.primaryText)

                if statistics.containerDistribution.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "暂无数据",
                        message: "还没有容器数据"
                    )
                    .frame(height: 200)
                } else {
                    Chart(statistics.containerDistribution) { item in
                        SectorMark(
                            angle: .value("数量", item.count),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("容器", item.containerName))
                        .annotation(position: .overlay) {
                            Text("\(item.count)")
                                .font(Theme.Fonts.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, spacing: 8)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 过期趋势图表
struct ExpirationTrendChart: View {
    let statistics: ItemStatistics

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("过期趋势")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.primaryText)

                if statistics.expirationTrend.isEmpty {
                    EmptyStateView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "暂无数据",
                        message: "还没有过期数据"
                    )
                    .frame(height: 200)
                } else {
                    Chart {
                        ForEach(statistics.expirationTrend) { trend in
                            LineMark(
                                x: .value("日期", trend.date, unit: .day),
                                y: .value("数量", trend.count)
                            )
                            .foregroundStyle(Theme.Colors.pinkAccent)
                            .lineStyle(StrokeStyle(lineWidth: 2))

                            AreaMark(
                                x: .value("日期", trend.date, unit: .day),
                                y: .value("数量", trend.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.Colors.pinkAccent.opacity(0.3), Theme.Colors.pinkAccent.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            PointMark(
                                x: .value("日期", trend.date, unit: .day),
                                y: .value("数量", trend.count)
                            )
                            .foregroundStyle(Theme.Colors.pinkAccent)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 统计详细列表
struct StatisticsDetailList: View {
    let statistics: ItemStatistics

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("详细统计")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.primaryText)

                VStack(spacing: Theme.Spacing.small) {
                    DetailRow(title: "物品总数", value: "\(statistics.totalItems)")
                    DetailRow(title: "容器总数", value: "\(statistics.totalContainers)")
                    DetailRow(title: "平均每容器物品数", value: String(format: "%.1f", statistics.averageItemsPerContainer))
                    DetailRow(title: "即将过期物品", value: "\(statistics.nearExpirationCount)")
                    DetailRow(title: "已过期物品", value: "\(statistics.expiredCount)")
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 详细行
struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(Theme.Fonts.bodyBold)
                .foregroundColor(Theme.Colors.primaryText)
        }
        .padding(.vertical, Theme.Spacing.tiny)
    }
}

// MARK: - 统计数据模型
struct ItemStatistics {
    var totalItems: Int = 0
    var totalContainers: Int = 0
    var nearExpirationCount: Int = 0
    var expiredCount: Int = 0
    var averageItemsPerContainer: Double = 0.0
    var categoryBreakdown: [CategoryBreakdown] = []
    var containerDistribution: [ContainerDistribution] = []
    var expirationTrend: [ExpirationTrend] = []
}

struct CategoryBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}

struct ContainerDistribution: Identifiable {
    let id = UUID()
    let containerName: String
    let count: Int
}

struct ExpirationTrend: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

// MARK: - ViewModel
@MainActor
class ItemStatisticsViewModel: ObservableObject {
    @Published var statistics = ItemStatistics()
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadStatistics(dataManager: DataManager) {
        isLoading = true
        defer { isLoading = false }

        // 使用本地DataManager数据计算统计
        calculateStatistics(items: dataManager.items, containers: dataManager.containers)
    }

    private func calculateStatistics(items: [Item], containers: [Container]) {
        // 基础统计
        statistics.totalItems = items.count
        statistics.totalContainers = containers.count
        statistics.averageItemsPerContainer = containers.isEmpty ? 0 : Double(items.count) / Double(containers.count)

        // 过期统计
        statistics.nearExpirationCount = items.filter { $0.isExpiringSoon && !$0.isExpired }.count
        statistics.expiredCount = items.filter { $0.isExpired }.count

        // 分类统计
        var categoryCount: [String: Int] = [:]
        for item in items {
            let category = item.type.displayName
            categoryCount[category, default: 0] += 1
        }
        statistics.categoryBreakdown = categoryCount.map { CategoryBreakdown(category: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // 容器分布统计
        var containerCount: [String: Int] = [:]
        for item in items {
            if let containerId = item.containerId {
                // 查找容器名称
                if let container = containers.first(where: { $0.id == containerId }) {
                    containerCount[container.name, default: 0] += 1
                }
            }
        }
        statistics.containerDistribution = containerCount.map { ContainerDistribution(containerName: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(10)
            .map { $0 }

        // 过期趋势（最近30天） - 基于创建时间的简化版本
        var trendData: [Date: Int] = [:]
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: now)!

        for day in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                let dayStart = calendar.startOfDay(for: date)
                trendData[dayStart] = 0
            }
        }

        // 按物品创建时间生成趋势（简化版本）
        for item in items {
            if item.createdAt >= startDate && item.createdAt <= now {
                let dayStart = calendar.startOfDay(for: item.createdAt)
                trendData[dayStart, default: 0] += 1
            }
        }

        statistics.expirationTrend = trendData.map { ExpirationTrend(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - 预览
#Preview {
    ItemStatisticsView()
        .environmentObject(DataManager.shared)
}
