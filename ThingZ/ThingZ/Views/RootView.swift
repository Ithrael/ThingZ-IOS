import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // 已登录，显示主界面
                MainTabView()
            } else {
                // 未登录，显示登录页面
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
    }
}

struct MainTabView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var authManager: AuthManager
    
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
            
            // 个人中心
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("我的")
                }
        }
        .environmentObject(dataManager)
        .environmentObject(authManager)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager.shared)
} 