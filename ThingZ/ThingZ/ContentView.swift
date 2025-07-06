//
//  ContentView.swift
//  ThingZ
//
//  Created by 王冲 on 2025/7/5.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        TabView {
            // 容器管理
            ContainerListView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("容器")
                }
            
            // 物品管理
            ItemListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("物品")
                }
            
            // 搜索
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("搜索")
                }
            
            // 过期提醒
            ExpirationAlertView()
                .tabItem {
                    Image(systemName: "clock.badge.exclamationmark")
                    Text("提醒")
                }
            
            // 设置
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
}
