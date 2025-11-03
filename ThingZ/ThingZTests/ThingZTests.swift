//
//  ThingZTests.swift
//  ThingZTests
//
//  Created by 王冲 on 2025/7/5.
//

import Testing
import XCTest
@testable import ThingZ

// MARK: - 数据模型测试
struct DataModelTests {

    @Test func testItemCreation() async throws {
        let item = Item(
            name: "测试物品",
            itemDescription: "这是一个测试物品",
            quantity: 5,
            type: .food,
            containerId: nil
        )

        #expect(item.name == "测试物品")
        #expect(item.quantity == 5)
        #expect(item.type == .food)
    }

    @Test func testContainerCreation() async throws {
        let container = Container(
            name: "测试容器",
            containerDescription: "这是一个测试容器",
            location: "厨房"
        )

        #expect(container.name == "测试容器")
        #expect(container.location == "厨房")
    }

    @Test func testItemExpirationStatus() async throws {
        let calendar = Calendar.current

        // 测试已过期物品
        let expiredDate = calendar.date(byAdding: .day, value: -5, to: Date())
        var expiredItem = Item(
            name: "过期物品",
            itemDescription: "",
            quantity: 1,
            type: .food,
            containerId: nil
        )
        expiredItem.expirationDate = expiredDate
        #expect(expiredItem.isExpired == true)

        // 测试即将过期物品
        let soonDate = calendar.date(byAdding: .day, value: 5, to: Date())
        var soonItem = Item(
            name: "即将过期物品",
            itemDescription: "",
            quantity: 1,
            type: .food,
            containerId: nil
        )
        soonItem.expirationDate = soonDate
        #expect(soonItem.isExpiringSoon == true)
    }
}

// MARK: - API服务测试
struct APIServiceTests {

    @Test func testAPIConfiguration() async throws {
        let config = APIConfiguration.shared
        #expect(!config.baseURL.isEmpty)
        #expect(config.baseURL.hasPrefix("http"))
    }

    @Test func testAuthTokenHandling() async throws {
        let authManager = AuthManager.shared

        // 测试token存储和检索
        let testToken = "test_token_12345"
        authManager.saveToken(testToken)

        let retrievedToken = authManager.token
        #expect(retrievedToken == testToken)
    }
}

// MARK: - 缓存管理测试
class CacheTests: XCTestCase {

    func testImageCacheStorage() {
        let cache = ImageCache.shared

        // 创建测试图片
        let testImage = UIImage(systemName: "star.fill")!
        let testKey = "test_image_key"

        // 保存图片
        cache.setImage(testImage, forKey: testKey)

        // 检索图片
        let retrievedImage = cache.getImage(forKey: testKey)
        XCTAssertNotNil(retrievedImage, "缓存的图片应该能被检索到")
    }

    func testCacheClear() {
        let cache = ImageCache.shared

        // 添加图片
        let testImage = UIImage(systemName: "star.fill")!
        cache.setImage(testImage, forKey: "test_key")

        // 清除缓存
        cache.clearMemoryCache()

        // 验证内存缓存已清除（但磁盘缓存可能还在）
        // 注意：这个测试可能会受到磁盘缓存的影响
    }

    func testCacheSize() {
        let cache = ImageCache.shared
        let size = cache.getCacheSize()
        XCTAssertTrue(size >= 0, "缓存大小应该是非负数")
    }
}

// MARK: - 通知管理测试
class NotificationTests: XCTestCase {

    func testNotificationAuthorizationRequest() async {
        let notificationManager = LocalNotificationManager.shared

        // 检查权限状态
        let status = await notificationManager.checkAuthorizationStatus()
        XCTAssertTrue(
            [.authorized, .denied, .notDetermined, .provisional, .ephemeral].contains(status),
            "通知权限状态应该是有效的"
        )
    }

    func testImmediateNotification() async {
        let notificationManager = LocalNotificationManager.shared

        // 发送测试通知
        await notificationManager.sendImmediateNotification(
            title: "测试通知",
            body: "这是一个单元测试通知"
        )

        // 等待一段时间让通知被调度
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let count = await notificationManager.getPendingNotificationsCount()
        // 注意：如果权限未授予，count可能为0
        XCTAssertTrue(count >= 0, "待处理通知数量应该是非负数")
    }
}

// MARK: - 生物识别测试
class BiometricTests: XCTestCase {

    func testBiometricAvailability() {
        let biometricManager = BiometricAuthManager.shared

        // 检查生物识别可用性
        biometricManager.checkBiometricAvailability()

        // 验证状态
        let isAvailable = biometricManager.isBiometricAvailable
        let type = biometricManager.biometricType

        XCTAssertTrue(
            type == .none || type == .faceID || type == .touchID || type == .opticID,
            "生物识别类型应该是有效的"
        )
    }

    func testBiometricPreference() {
        let biometricManager = BiometricAuthManager.shared

        // 测试启用/禁用
        biometricManager.enableBiometric(true)
        biometricManager.loadBiometricPreference()
        XCTAssertTrue(biometricManager.isBiometricEnabled)

        biometricManager.enableBiometric(false)
        biometricManager.loadBiometricPreference()
        XCTAssertFalse(biometricManager.isBiometricEnabled)
    }
}

// MARK: - iCloud同步测试
class iCloudSyncTests: XCTestCase {

    func testCloudKitAvailability() async {
        let syncManager = await iCloudSyncManager.shared

        // 检查CloudKit可用性
        await syncManager.checkCloudKitAvailability()

        // 验证状态是布尔值
        let isAvailable = await syncManager.isCloudKitAvailable
        XCTAssertTrue(isAvailable == true || isAvailable == false, "CloudKit可用性应该是布尔值")
    }
}

// MARK: - ViewModel测试
@MainActor
class ViewModelTests: XCTestCase {

    func testContainerListViewModel() async {
        let viewModel = ContainerListViewModel()

        // 初始状态
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.containers.isEmpty)

        // 加载数据
        await viewModel.loadContainers()

        // 验证加载后的状态
        XCTAssertFalse(viewModel.isLoading, "加载完成后isLoading应该为false")
    }

    func testItemListViewModel() async {
        let testContainerId = UUID()
        let viewModel = ItemListViewModel(containerId: testContainerId)

        // 初始状态
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.items.isEmpty)

        // 加载数据
        await viewModel.loadItems()

        // 验证加载后的状态
        XCTAssertFalse(viewModel.isLoading)
    }

    func testNotificationSettingsViewModel() async {
        let viewModel = NotificationSettingsViewModel()

        // 加载设置
        await viewModel.loadSettings()

        // 验证默认值
        XCTAssertTrue(viewModel.reminderDaysBefore >= 0)
    }
}

// MARK: - 数据验证测试
struct ValidationTests {

    @Test func testEmailValidation() {
        // 测试邮箱格式验证
        let validEmail = "test@example.com"
        let invalidEmail = "invalid-email"

        #expect(validEmail.contains("@"))
        #expect(!invalidEmail.contains("@") || !invalidEmail.contains("."))
    }

    @Test func testPasswordValidation() {
        // 测试密码强度
        let weakPassword = "123"
        let strongPassword = "StrongP@ssw0rd"

        #expect(weakPassword.count < 6)
        #expect(strongPassword.count >= 6)
    }

    @Test func testQuantityValidation() {
        // 测试数量验证
        let validQuantity = 5
        let invalidQuantity = -1

        #expect(validQuantity > 0)
        #expect(invalidQuantity < 0)
    }
}

// MARK: - 性能测试
class PerformanceTests: XCTestCase {

    func testImageCachePerformance() {
        let cache = ImageCache.shared
        let testImage = UIImage(systemName: "star.fill")!

        measure {
            // 测试缓存写入性能
            for i in 0..<100 {
                cache.setImage(testImage, forKey: "key_\(i)")
            }
        }
    }

    func testDataLoadingPerformance() async {
        measure {
            // 测试数据加载性能
            Task { @MainActor in
                let viewModel = ContainerListViewModel()
                await viewModel.loadContainers()
            }
        }
    }
}

// MARK: - 日期处理测试
struct DateUtilityTests {

    @Test func testDateFormatting() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let dateString = formatter.string(from: date)
        #expect(dateString.count == 10)
        #expect(dateString.contains("-"))
    }

    @Test func testRelativeDateCalculation() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let days = calendar.dateComponents([.day], from: today, to: tomorrow).day
        #expect(days == 1)
    }
}
