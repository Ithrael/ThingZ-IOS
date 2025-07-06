import Foundation
import UserNotifications

// 通知管理器
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 请求通知权限
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授权")
            } else {
                print("通知权限被拒绝")
            }
        }
    }
    
    // 安排食品过期提醒
    func scheduleExpirationReminders(for items: [Item]) {
        for item in items {
            if let foodProperties = item.foodProperties {
                // 检查是否有过期日期
                let expirationDate = foodProperties.expirationDate
                let now = Date()
                let timeUntilExpiration = expirationDate.timeIntervalSince(now)
                
                // 如果还没过期，设置提醒
                if timeUntilExpiration > 0 {
                    // 提前1天提醒
                    if timeUntilExpiration > 86400 { // 24小时
                        scheduleNotification(
                            identifier: "food_expiry_\(item.id)",
                            title: "食品即将过期",
                            body: "\(item.name) 将在明天过期，请及时食用",
                            date: Date(timeInterval: timeUntilExpiration - 86400, since: now)
                        )
                    }
                    
                    // 当天提醒
                    scheduleNotification(
                        identifier: "food_expiry_today_\(item.id)",
                        title: "食品今天过期",
                        body: "\(item.name) 今天过期，请尽快食用",
                        date: expirationDate
                    )
                }
            }
        }
    }
    
    // 安排化妆品过期提醒
    func scheduleCosmeticsReminders(for items: [Item]) {
        for item in items {
            if let cosmeticsProperties = item.cosmeticsProperties {
                // 检查是否有开封日期和开封后保质期
                if let openedDate = cosmeticsProperties.openedDate {
                    let shelfLife = cosmeticsProperties.shelfLifeAfterOpening
                    
                    let expirationDate = Calendar.current.date(byAdding: .month, value: shelfLife, to: openedDate)!
                    let now = Date()
                    let timeUntilExpiration = expirationDate.timeIntervalSince(now)
                    
                    // 如果还没过期，设置提醒
                    if timeUntilExpiration > 0 {
                        // 提前1周提醒
                        if timeUntilExpiration > 604800 { // 7天
                            scheduleNotification(
                                identifier: "cosmetics_expiry_\(item.id)",
                                title: "化妆品即将过期",
                                body: "\(item.name) 将在一周后过期，请注意使用期限",
                                date: Date(timeInterval: timeUntilExpiration - 604800, since: now)
                            )
                        }
                        
                        // 当天提醒
                        scheduleNotification(
                            identifier: "cosmetics_expiry_today_\(item.id)",
                            title: "化妆品今天过期",
                            body: "\(item.name) 今天过期，建议停止使用",
                            date: expirationDate
                        )
                    }
                }
            }
        }
    }
    
    // 安排季节性衣物提醒
    func scheduleSeasonalReminders(for items: [Item]) {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        for item in items {
            if let clothingProperties = item.clothingProperties {
                var reminderMonth: Int?
                var reminderTitle: String = ""
                var reminderBody: String = ""
                
                switch clothingProperties.season {
                case .spring:
                    reminderMonth = 3 // 3月
                    reminderTitle = "春季衣物提醒"
                    reminderBody = "春天到了，该换上 \(item.name) 等春季衣物了"
                case .summer:
                    reminderMonth = 6 // 6月
                    reminderTitle = "夏季衣物提醒"
                    reminderBody = "夏天到了，该换上 \(item.name) 等夏季衣物了"
                case .autumn:
                    reminderMonth = 9 // 9月
                    reminderTitle = "秋季衣物提醒"
                    reminderBody = "秋天到了，该换上 \(item.name) 等秋季衣物了"
                case .winter:
                    reminderMonth = 12 // 12月
                    reminderTitle = "冬季衣物提醒"
                    reminderBody = "冬天到了，该换上 \(item.name) 等冬季衣物了"
                case .allSeasons:
                    continue // 全季节衣物不需要提醒
                }
                
                if let month = reminderMonth {
                    // 计算下一个提醒日期
                    var targetYear = currentYear
                    if month < currentMonth {
                        targetYear += 1
                    }
                    
                    var dateComponents = DateComponents()
                    dateComponents.year = targetYear
                    dateComponents.month = month
                    dateComponents.day = 1
                    dateComponents.hour = 9
                    dateComponents.minute = 0
                    
                    if let targetDate = calendar.date(from: dateComponents) {
                        scheduleNotification(
                            identifier: "seasonal_\(item.id)",
                            title: reminderTitle,
                            body: reminderBody,
                            date: targetDate
                        )
                    }
                }
            }
        }
    }
    
    // 安排单个通知
    private func scheduleNotification(identifier: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知安排失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 取消指定物品的所有提醒
    func cancelReminders(for item: Item) {
        let identifiers = [
            "food_expiry_\(item.id)",
            "food_expiry_today_\(item.id)",
            "cosmetics_expiry_\(item.id)",
            "cosmetics_expiry_today_\(item.id)",
            "seasonal_\(item.id)"
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // 取消所有提醒
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 刷新所有物品的提醒
    func refreshAllReminders(for items: [Item]) {
        cancelAllReminders()
        scheduleExpirationReminders(for: items)
        scheduleCosmeticsReminders(for: items)
        scheduleSeasonalReminders(for: items)
    }
    
    // 获取即将过期的物品
    func getExpiringItems(from items: [Item], daysAhead: Int = 7) -> [Item] {
        let calendar = Calendar.current
        let targetDate = calendar.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
        
        return items.filter { item in
            // 检查食品
            if let foodProperties = item.foodProperties {
                let expirationDate = foodProperties.expirationDate
                return expirationDate <= targetDate
            }
            
            // 检查化妆品
            if let cosmeticsProperties = item.cosmeticsProperties,
               let openedDate = cosmeticsProperties.openedDate {
                let shelfLife = cosmeticsProperties.shelfLifeAfterOpening
                let expirationDate = calendar.date(byAdding: .month, value: shelfLife, to: openedDate) ?? Date()
                return expirationDate <= targetDate
            }
            
            return false
        }
    }
}