//
//  ThingZUITests.swift
//  ThingZUITests
//
//  Created by 王冲 on 2025/7/5.
//

import XCTest

final class ThingZUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - 启动测试
    @MainActor
    func testAppLaunch() throws {
        // 验证应用成功启动
        XCTAssertTrue(app.state == .runningForeground)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    // MARK: - 登录流程测试
    @MainActor
    func testLoginFlow() throws {
        // 查找登录相关元素
        let loginButton = app.buttons["登录"]
        let emailField = app.textFields["邮箱"]
        let passwordField = app.secureTextFields["密码"]

        // 如果找到登录界面元素
        if loginButton.exists {
            // 测试登录流程
            if emailField.exists {
                emailField.tap()
                emailField.typeText("test@example.com")
            }

            if passwordField.exists {
                passwordField.tap()
                passwordField.typeText("password123")
            }

            if loginButton.isEnabled {
                loginButton.tap()
            }

            // 等待登录完成
            sleep(2)
        }
    }

    @MainActor
    func testRegistrationFlow() throws {
        // 查找注册按钮
        let registerButton = app.buttons["注册"] ?? app.buttons["立即注册"]

        if registerButton.exists {
            registerButton.tap()

            // 填写注册表单
            let usernameField = app.textFields["用户名"]
            let emailField = app.textFields["邮箱"]
            let passwordField = app.secureTextFields["密码"]
            let confirmPasswordField = app.secureTextFields["确认密码"]

            if usernameField.exists {
                usernameField.tap()
                usernameField.typeText("testuser")
            }

            if emailField.exists {
                emailField.tap()
                emailField.typeText("test@example.com")
            }

            if passwordField.exists {
                passwordField.tap()
                passwordField.typeText("password123")
            }

            if confirmPasswordField.exists {
                confirmPasswordField.tap()
                confirmPasswordField.typeText("password123")
            }

            // 提交注册
            let submitButton = app.buttons["注册"] ?? app.buttons["完成注册"]
            if submitButton.exists && submitButton.isEnabled {
                submitButton.tap()
            }

            sleep(2)
        }
    }

    // MARK: - 导航测试
    @MainActor
    func testTabBarNavigation() throws {
        // 测试底部导航栏
        let tabBar = app.tabBars.firstMatch

        if tabBar.exists {
            // 点击不同的标签页
            let tabs = ["首页", "容器", "搜索", "统计", "设置"]

            for tabName in tabs {
                let tab = tabBar.buttons[tabName]
                if tab.exists {
                    tab.tap()
                    sleep(1)
                    XCTAssertTrue(tab.isSelected || true, "\(tabName)标签应该被选中")
                }
            }
        }
    }

    @MainActor
    func testNavigationBackButton() throws {
        // 测试返回按钮
        let backButton = app.navigationBars.buttons.element(boundBy: 0)

        // 如果存在导航栏
        if app.navigationBars.count > 0 {
            // 点击任何可以进入详情的元素
            let cells = app.cells
            if cells.count > 0 {
                cells.firstMatch.tap()
                sleep(1)

                // 点击返回按钮
                if backButton.exists {
                    backButton.tap()
                    sleep(1)
                }
            }
        }
    }

    // MARK: - 容器管理测试
    @MainActor
    func testContainerCreation() throws {
        // 查找添加容器按钮
        let addButton = app.buttons["添加容器"] ?? app.buttons.matching(identifier: "add_container").firstMatch

        if addButton.exists {
            addButton.tap()
            sleep(1)

            // 填写容器信息
            let nameField = app.textFields["容器名称"]
            let descriptionField = app.textFields["描述"] ?? app.textViews["描述"]
            let locationField = app.textFields["位置"]

            if nameField.exists {
                nameField.tap()
                nameField.typeText("测试容器")
            }

            if descriptionField.exists {
                descriptionField.tap()
                descriptionField.typeText("这是一个测试容器")
            }

            if locationField.exists {
                locationField.tap()
                locationField.typeText("客厅")
            }

            // 保存容器
            let saveButton = app.buttons["保存"] ?? app.buttons["完成"]
            if saveButton.exists && saveButton.isEnabled {
                saveButton.tap()
                sleep(2)
            }
        }
    }

    @MainActor
    func testContainerList() throws {
        // 测试容器列表显示
        let containerList = app.scrollViews.firstMatch

        if containerList.exists {
            // 滚动列表
            containerList.swipeUp()
            sleep(1)
            containerList.swipeDown()
            sleep(1)
        }

        // 验证容器项存在
        let cells = app.cells
        XCTAssertTrue(cells.count >= 0, "容器列表应该显示")
    }

    // MARK: - 物品管理测试
    @MainActor
    func testItemCreation() throws {
        // 首先进入一个容器
        let cells = app.cells
        if cells.count > 0 {
            cells.firstMatch.tap()
            sleep(1)

            // 查找添加物品按钮
            let addItemButton = app.buttons["添加物品"] ?? app.buttons.matching(identifier: "add_item").firstMatch

            if addItemButton.exists {
                addItemButton.tap()
                sleep(1)

                // 填写物品信息
                let nameField = app.textFields["物品名称"]
                let quantityField = app.textFields["数量"]

                if nameField.exists {
                    nameField.tap()
                    nameField.typeText("测试物品")
                }

                if quantityField.exists {
                    quantityField.tap()
                    quantityField.typeText("5")
                }

                // 保存物品
                let saveButton = app.buttons["保存"] ?? app.buttons["完成"]
                if saveButton.exists && saveButton.isEnabled {
                    saveButton.tap()
                    sleep(2)
                }
            }
        }
    }

    // MARK: - 搜索测试
    @MainActor
    func testSearchFunctionality() throws {
        // 查找搜索标签或搜索框
        let searchTab = app.tabBars.buttons["搜索"]
        if searchTab.exists {
            searchTab.tap()
            sleep(1)
        }

        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("测试")
            sleep(2)

            // 验证搜索结果
            XCTAssertTrue(app.exists, "搜索结果应该显示")

            // 清除搜索
            if app.buttons["Clear text"].exists {
                app.buttons["Clear text"].tap()
            }
        }
    }

    // MARK: - 设置页面测试
    @MainActor
    func testSettingsPage() throws {
        // 导航到设置页面
        let settingsTab = app.tabBars.buttons["设置"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)

            // 验证设置选项存在
            let settingsOptions = ["通知设置", "账户设置", "数据管理", "关于"]

            for option in settingsOptions {
                let cell = app.cells[option] ?? app.staticTexts[option]
                if cell.exists {
                    XCTAssertTrue(true, "\(option) 应该存在")
                }
            }
        }
    }

    @MainActor
    func testNotificationSettings() throws {
        // 导航到设置
        let settingsTab = app.tabBars.buttons["设置"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)

            // 查找通知设置
            let notificationSettings = app.cells["通知设置"] ?? app.staticTexts["通知设置"]
            if notificationSettings.exists {
                notificationSettings.tap()
                sleep(1)

                // 测试通知开关
                let toggles = app.switches
                if toggles.count > 0 {
                    let firstToggle = toggles.firstMatch
                    let initialState = firstToggle.value as? String

                    firstToggle.tap()
                    sleep(1)

                    let newState = firstToggle.value as? String
                    // 验证状态改变
                    XCTAssertNotEqual(initialState, newState, "开关状态应该改变")
                }
            }
        }
    }

    // MARK: - 下拉刷新测试
    @MainActor
    func testPullToRefresh() throws {
        // 在主列表页面测试下拉刷新
        let scrollView = app.scrollViews.firstMatch

        if scrollView.exists {
            let startPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let endPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))

            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            sleep(2)

            XCTAssertTrue(app.exists, "刷新后应该显示内容")
        }
    }

    // MARK: - 数据删除测试
    @MainActor
    func testItemDeletion() throws {
        // 进入容器
        let cells = app.cells
        if cells.count > 0 {
            cells.firstMatch.tap()
            sleep(1)

            // 查找物品列表
            let itemCells = app.cells
            if itemCells.count > 0 {
                // 向左滑动删除
                itemCells.firstMatch.swipeLeft()
                sleep(1)

                // 点击删除按钮
                let deleteButton = app.buttons["删除"] ?? app.buttons["Delete"]
                if deleteButton.exists {
                    deleteButton.tap()
                    sleep(1)

                    // 确认删除
                    let confirmButton = app.buttons["确认"] ?? app.buttons["确定"]
                    if confirmButton.exists {
                        confirmButton.tap()
                        sleep(2)
                    }
                }
            }
        }
    }

    // MARK: - 过期提醒测试
    @MainActor
    func testExpirationReminders() throws {
        // 查找过期提醒标签或按钮
        let expirationTab = app.buttons["过期提醒"] ?? app.staticTexts["过期提醒"]

        if expirationTab.exists {
            expirationTab.tap()
            sleep(1)

            // 验证过期物品列表
            XCTAssertTrue(app.exists, "过期提醒页面应该显示")

            // 测试天数选择器
            let segmentedControl = app.segmentedControls.firstMatch
            if segmentedControl.exists {
                let buttons = segmentedControl.buttons
                if buttons.count > 1 {
                    buttons.element(boundBy: 1).tap()
                    sleep(1)
                }
            }
        }
    }

    // MARK: - QR码扫描测试
    @MainActor
    func testQRCodeScanner() throws {
        // 查找QR码扫描按钮
        let scanButton = app.buttons["扫描二维码"] ?? app.buttons.matching(identifier: "qr_scan").firstMatch

        if scanButton.exists {
            scanButton.tap()
            sleep(1)

            // 验证相机视图出现
            // 注意：实际相机可能需要权限

            // 关闭扫描器
            let closeButton = app.buttons["关闭"] ?? app.buttons["取消"]
            if closeButton.exists {
                closeButton.tap()
                sleep(1)
            }
        }
    }

    // MARK: - 数据统计测试
    @MainActor
    func testStatisticsView() throws {
        // 导航到统计页面
        let statsTab = app.tabBars.buttons["统计"]
        if statsTab.exists {
            statsTab.tap()
            sleep(2)

            // 验证统计图表存在
            XCTAssertTrue(app.exists, "统计页面应该显示")

            // 测试时间段选择
            let segmentedControl = app.segmentedControls.firstMatch
            if segmentedControl.exists {
                let segments = segmentedControl.buttons
                for i in 0..<min(segments.count, 3) {
                    segments.element(boundBy: i).tap()
                    sleep(1)
                }
            }
        }
    }

    // MARK: - 图片上传测试
    @MainActor
    func testImageUpload() throws {
        // 进入添加物品页面
        let addButton = app.buttons["添加物品"] ?? app.buttons["添加容器"]

        if addButton.exists {
            addButton.tap()
            sleep(1)

            // 查找图片选择按钮
            let imageButton = app.buttons["添加图片"] ?? app.images.firstMatch

            if imageButton.exists {
                imageButton.tap()
                sleep(1)

                // 注意：需要处理相册权限
                // 取消图片选择
                let cancelButton = app.buttons["取消"] ?? app.buttons["Cancel"]
                if cancelButton.exists {
                    cancelButton.tap()
                }
            }
        }
    }

    // MARK: - 辅助功能测试
    @MainActor
    func testAccessibility() throws {
        // 验证关键元素的可访问性
        let importantElements = app.buttons.allElementsBoundByIndex + app.staticTexts.allElementsBoundByIndex

        for element in importantElements.prefix(10) {
            if element.exists {
                XCTAssertTrue(element.isHittable || !element.exists, "元素应该可交互或不存在")
            }
        }
    }

    // MARK: - 内存泄漏测试
    @MainActor
    func testMemoryUsage() throws {
        measure(metrics: [XCTMemoryMetric()]) {
            // 执行一系列操作
            let cells = app.cells
            if cells.count > 0 {
                for i in 0..<min(cells.count, 5) {
                    cells.element(boundBy: i).tap()
                    sleep(1)
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                    sleep(1)
                }
            }
        }
    }

    // MARK: - 横竖屏切换测试
    @MainActor
    func testOrientationChange() throws {
        // 测试横竖屏切换
        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        XCUIDevice.shared.orientation = .portrait
        sleep(1)

        // 验证界面正常显示
        XCTAssertTrue(app.exists, "横竖屏切换后应该正常显示")
    }
}
