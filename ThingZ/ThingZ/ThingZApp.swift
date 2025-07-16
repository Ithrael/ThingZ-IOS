//
//  ThingZApp.swift
//  ThingZ
//
//  Created by 王冲 on 2025/7/5.
//

import SwiftUI

@main
struct ThingZApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    init() {
        // 应用启动时请求通知权限
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .onAppear {
                    // 检查登录状态
                    authManager.checkAuthStatus()
                    
                    // 应用前台时刷新提醒
                    if authManager.isAuthenticated {
                        NotificationManager.shared.refreshAllReminders(for: DataManager.shared.items)
                    }
                }
        }
    }
}
