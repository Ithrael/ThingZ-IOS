//
//  ThingZApp.swift
//  ThingZ
//
//  Created by 王冲 on 2025/7/5.
//

import SwiftUI

@main
struct ThingZApp: App {
    
    init() {
        // 应用启动时请求通知权限
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 应用前台时刷新提醒
                    NotificationManager.shared.refreshAllReminders(for: DataManager.shared.items)
                }
        }
    }
}
