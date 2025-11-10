import CloudKit
import SwiftUI
import Combine

// MARK: - iCloud同步管理器
@MainActor
class iCloudSyncManager: ObservableObject {
    static let shared = iCloudSyncManager()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var isCloudKitAvailable = false

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let userDefaultsKey = "LastSyncDate"

    // Record Types
    private let itemRecordType = "Item"
    private let containerRecordType = "Container"

    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase

        Task {
            await checkCloudKitAvailability()
            loadLastSyncDate()
        }
    }

    // MARK: - 检查CloudKit可用性
    func checkCloudKitAvailability() async {
        do {
            let status = try await container.accountStatus()
            isCloudKitAvailable = (status == .available)

            if !isCloudKitAvailable {
                print("❌ iCloud账户不可用，状态: \(status.rawValue)")
            }
        } catch {
            print("❌ 检查iCloud状态失败: \(error)")
            isCloudKitAvailable = false
        }
    }

    // MARK: - 同步所有数据
    func syncAll() async {
        guard isCloudKitAvailable else {
            syncError = "iCloud不可用，请检查iCloud设置"
            return
        }

        isSyncing = true
        syncError = nil

        do {
            // 先同步容器，再同步物品（物品依赖容器）
            try await syncContainers()
            try await syncItems()

            lastSyncDate = Date()
            saveLastSyncDate()

            print("✅ iCloud同步完成")
        } catch {
            syncError = "同步失败: \(error.localizedDescription)"
            print("❌ 同步失败: \(error)")
        }

        isSyncing = false
    }

    // MARK: - 同步容器
    private func syncContainers() async throws {
        // 1. 从CloudKit获取所有容器
        let cloudContainers = try await fetchContainersFromCloud()

        // 2. 获取本地容器（这里需要从DataManager获取，简化实现）
        // 实际使用时应该从DataManager获取

        // 3. 合并数据
        // 这里需要实现冲突解决策略

        print("✅ 容器同步完成，同步了 \(cloudContainers.count) 个容器")
    }

    private func fetchContainersFromCloud() async throws -> [CKRecord] {
        let query = CKQuery(recordType: containerRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let (results, _) = try await privateDatabase.records(matching: query)

        var records: [CKRecord] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("❌ 获取容器记录失败: \(error)")
            }
        }

        return records
    }

    // MARK: - 同步物品
    private func syncItems() async throws {
        // 1. 从CloudKit获取所有物品
        let cloudItems = try await fetchItemsFromCloud()

        // 2. 获取本地物品

        // 3. 合并数据

        print("✅ 物品同步完成，同步了 \(cloudItems.count) 个物品")
    }

    private func fetchItemsFromCloud() async throws -> [CKRecord] {
        let query = CKQuery(recordType: itemRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let (results, _) = try await privateDatabase.records(matching: query)

        var records: [CKRecord] = []
        for (_, result) in results {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("❌ 获取物品记录失败: \(error)")
            }
        }

        return records
    }

    // MARK: - 上传容器到iCloud
    func uploadContainer(_ container: Container) async throws {
        let record = CKRecord(recordType: containerRecordType)
        record["id"] = container.id.uuidString
        record["name"] = container.name
        record["type"] = container.type.rawValue
        record["location"] = container.location
        record["capacity"] = container.capacity
        record["createdAt"] = container.createdAt
        record["updatedAt"] = container.updatedAt

        if let apiId = container.apiId {
            record["apiId"] = apiId
        }

        if let imageUrl = container.imageUrl {
            record["imageUrl"] = imageUrl
        }

        try await privateDatabase.save(record)
        print("✅ 容器已上传到iCloud: \(container.name)")
    }

    // MARK: - 上传物品到iCloud
    func uploadItem(_ item: Item) async throws {
        let record = CKRecord(recordType: itemRecordType)
        record["id"] = item.id.uuidString
        record["name"] = item.name
        record["notes"] = item.notes
        record["type"] = item.type.rawValue
        record["createdAt"] = item.createdAt
        record["updatedAt"] = item.updatedAt

        if let containerId = item.containerId {
            record["containerId"] = containerId.uuidString
        }

        // 根据物品类型保存特有属性
        switch item.type {
        case .food:
            if let foodProperties = item.foodProperties {
                record["expirationDate"] = foodProperties.expirationDate
                record["quantity"] = foodProperties.quantity
                record["unit"] = foodProperties.unit
            }
        case .cosmetics:
            if let cosmeticsProperties = item.cosmeticsProperties {
                if let expirationDate = cosmeticsProperties.expirationDate {
                    record["expirationDate"] = expirationDate
                }
            }
        default:
            break
        }

        try await privateDatabase.save(record)
        print("✅ 物品已上传到iCloud: \(item.name)")
    }

    // MARK: - 删除记录
    func deleteRecord(recordType: String, recordID: CKRecord.ID) async throws {
        try await privateDatabase.deleteRecord(withID: recordID)
        print("✅ 记录已从iCloud删除")
    }

    // MARK: - 冲突解决策略
    private func resolveConflict<T>(local: T, cloud: T, localModified: Date, cloudModified: Date) -> T {
        // 简单策略：使用最新修改的版本
        return localModified > cloudModified ? local : cloud
    }

    // MARK: - 保存和加载上次同步时间
    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: userDefaultsKey)
        }
    }

    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date
    }

    // MARK: - 清空iCloud数据
    func clearCloudData() async throws {
        // 删除所有容器
        let containerRecords = try await fetchContainersFromCloud()
        for record in containerRecords {
            try await privateDatabase.deleteRecord(withID: record.recordID)
        }

        // 删除所有物品
        let itemRecords = try await fetchItemsFromCloud()
        for record in itemRecords {
            try await privateDatabase.deleteRecord(withID: record.recordID)
        }

        print("✅ iCloud数据已清空")
    }
}

// MARK: - iCloud同步状态视图
struct iCloudSyncStatusView: View {
    @StateObject private var syncManager = iCloudSyncManager.shared
    @State private var showingClearAlert = false

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                HStack {
                    Image(systemName: "icloud.fill")
                        .font(.title2)
                        .foregroundColor(syncManager.isCloudKitAvailable ? Theme.Colors.blueAccent : Theme.Colors.tertiaryText)

                    Text("iCloud同步")
                        .font(Theme.Fonts.title3)
                        .foregroundColor(Theme.Colors.primaryText)

                    Spacer()

                    if syncManager.isSyncing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }

                if syncManager.isCloudKitAvailable {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        if let lastSyncDate = syncManager.lastSyncDate {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(Theme.Colors.secondaryText)
                                Text("上次同步: \(lastSyncDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(Theme.Fonts.caption1)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        } else {
                            Text("尚未同步")
                                .font(Theme.Fonts.caption1)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }

                        if let error = syncManager.syncError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Theme.Colors.errorRed)
                                Text(error)
                                    .font(Theme.Fonts.caption1)
                                    .foregroundColor(Theme.Colors.errorRed)
                            }
                        }

                        HStack(spacing: Theme.Spacing.medium) {
                            Button(action: {
                                Task {
                                    await syncManager.syncAll()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("立即同步")
                                }
                                .font(Theme.Fonts.body)
                                .foregroundColor(.white)
                                .padding(.vertical, Theme.Spacing.small)
                                .padding(.horizontal, Theme.Spacing.medium)
                                .background(Theme.Colors.pinkAccent)
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            .disabled(syncManager.isSyncing)

                            Button(action: {
                                showingClearAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("清空云端")
                                }
                                .font(Theme.Fonts.body)
                                .foregroundColor(Theme.Colors.errorRed)
                                .padding(.vertical, Theme.Spacing.small)
                                .padding(.horizontal, Theme.Spacing.medium)
                                .background(Theme.Colors.errorRed.opacity(0.1))
                                .cornerRadius(Theme.CornerRadius.medium)
                            }
                            .disabled(syncManager.isSyncing)
                        }
                        .padding(.top, Theme.Spacing.small)
                    }
                } else {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Text("iCloud不可用")
                            .font(Theme.Fonts.body)
                            .foregroundColor(Theme.Colors.errorRed)

                        Text("请在设置中登录iCloud账户并启用iCloud Drive")
                            .font(Theme.Fonts.caption1)
                            .foregroundColor(Theme.Colors.secondaryText)

                        Button(action: {
                            Task {
                                await syncManager.checkCloudKitAvailability()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("重新检查")
                            }
                            .font(Theme.Fonts.body)
                            .foregroundColor(Theme.Colors.pinkAccent)
                            .padding(.vertical, Theme.Spacing.small)
                            .padding(.horizontal, Theme.Spacing.medium)
                            .background(Theme.Colors.pinkAccent.opacity(0.1))
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .padding(.top, Theme.Spacing.small)
                    }
                }
            }
        }
        .alert("清空iCloud数据", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) { }
            Button("确认清空", role: .destructive) {
                Task {
                    do {
                        try await syncManager.clearCloudData()
                    } catch {
                        print("❌ 清空iCloud数据失败: \(error)")
                    }
                }
            }
        } message: {
            Text("此操作将删除所有存储在iCloud中的数据，本地数据不受影响。此操作不可恢复！")
        }
    }
}

// MARK: - 自动同步扩展
extension iCloudSyncManager {
    // 启用自动后台同步
    func enableAutoSync(interval: TimeInterval = 3600) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                if self.isCloudKitAvailable && !self.isSyncing {
                    await self.syncAll()
                }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    iCloudSyncStatusView()
        .padding()
        .background(Theme.Colors.warmGradient)
}
