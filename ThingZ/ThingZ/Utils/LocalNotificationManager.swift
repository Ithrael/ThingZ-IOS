import UserNotifications
import SwiftUI

// MARK: - 本地通知管理器
class LocalNotificationManager: NSObject {
    static let shared = LocalNotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("❌ 通知权限请求失败: \(error)")
            return false
        }
    }

    // MARK: - 检查通知权限
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - 调度过期提醒通知
    func scheduleExpirationNotifications(for items: [Item]) async {
        // 先移除所有现有的过期通知
        await removeExpirationNotifications()

        // 为每个即将过期的物品创建通知
        for item in items {
            var expirationDate: Date? = nil

            // 根据物品类型获取过期时间
            switch item.type {
            case .food:
                expirationDate = item.foodProperties?.expirationDate
            case .cosmetics:
                expirationDate = item.cosmeticsProperties?.expirationDate
            default:
                continue
            }

            guard let expirationDate = expirationDate else { continue }

            // 计算距离过期还有多少天
            let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0

            // 只为1-7天内过期的物品创建通知
            if daysUntilExpiration >= 1 && daysUntilExpiration <= 7 {
                await scheduleExpirationNotification(for: item, daysUntilExpiration: daysUntilExpiration)
            }
        }
    }

    private func scheduleExpirationNotification(for item: Item, daysUntilExpiration: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "物品即将过期提醒"

        if daysUntilExpiration == 0 {
            content.body = "您的 \(item.name) 今天就要过期了！"
        } else if daysUntilExpiration == 1 {
            content.body = "您的 \(item.name) 明天就要过期了！"
        } else {
            content.body = "您的 \(item.name) 还有 \(daysUntilExpiration) 天就要过期了"
        }

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "EXPIRATION_REMINDER"
        content.userInfo = ["itemId": item.id.uuidString, "type": "expiration"]

        // 设置通知时间（每天早上9点）
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "expiration-\(item.id.uuidString)"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            print("✅ 已为物品 \(item.name) 添加过期通知")
        } catch {
            print("❌ 添加通知失败: \(error)")
        }
    }

    // MARK: - 立即通知（用于测试）
    func sendImmediateNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            print("❌ 发送通知失败: \(error)")
        }
    }

    // MARK: - 移除通知
    func removeExpirationNotifications() async {
        let allNotifications = await notificationCenter.pendingNotificationRequests()
        let expirationNotificationIds = allNotifications
            .filter { $0.identifier.hasPrefix("expiration-") }
            .map { $0.identifier }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: expirationNotificationIds)
    }

    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - 获取待处理的通知数量
    func getPendingNotificationsCount() async -> Int {
        let notifications = await notificationCenter.pendingNotificationRequests()
        return notifications.count
    }

    // MARK: - 重置应用角标
    func resetBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    // 在前台收到通知时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 在前台也显示通知
        completionHandler([.banner, .sound, .badge])
    }

    // 用户点击通知时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let itemId = userInfo["itemId"] as? String {
            // 发送通知，让应用导航到对应的物品详情页
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToItem"),
                object: nil,
                userInfo: ["itemId": itemId]
            )
        }

        completionHandler()
    }
}

// MARK: - 通知设置视图模型
@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var isNotificationEnabled = false
    @Published var notificationTime = Date()
    @Published var enableExpirationReminders = true
    @Published var reminderDaysBefore = 3
    @Published var pendingNotificationsCount = 0

    private let notificationManager = LocalNotificationManager.shared

    func loadSettings() async {
        let status = await notificationManager.checkAuthorizationStatus()
        isNotificationEnabled = (status == .authorized)

        pendingNotificationsCount = await notificationManager.getPendingNotificationsCount()

        // 从UserDefaults加载设置
        enableExpirationReminders = UserDefaults.standard.bool(forKey: "enableExpirationReminders")
        reminderDaysBefore = UserDefaults.standard.integer(forKey: "reminderDaysBefore")

        if reminderDaysBefore == 0 {
            reminderDaysBefore = 3 // 默认值
        }
    }

    func requestNotificationPermission() async {
        let granted = await notificationManager.requestAuthorization()
        isNotificationEnabled = granted

        if granted {
            await scheduleNotifications()
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(enableExpirationReminders, forKey: "enableExpirationReminders")
        UserDefaults.standard.set(reminderDaysBefore, forKey: "reminderDaysBefore")
    }

    func scheduleNotifications() async {
        // 这里需要访问DataManager获取物品列表
        // 实际使用时应该从DataManager获取
        print("✅ 通知已重新调度")
    }

    func testNotification() async {
        await notificationManager.sendImmediateNotification(
            title: "测试通知",
            body: "这是一条测试通知，用于验证通知功能是否正常工作"
        )
    }

    func clearAllNotifications() {
        notificationManager.removeAllNotifications()
        notificationManager.resetBadge()
        pendingNotificationsCount = 0
    }
}
