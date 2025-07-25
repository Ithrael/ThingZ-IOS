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
                    Image(systemName: "archivebox.fill")
                    Text("容器")
                }
            
            // 物品管理
            ItemListView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("物品")
                }
            
            // 搜索
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle.fill")
                    Text("搜索")
                }
            
            // 过期提醒
            ExpirationAlertView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("提醒")
                }
            
            // 个人中心
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("我的")
                }
        }
        .environmentObject(dataManager)
        .environmentObject(authManager)
        .accentColor(Color(red: 1.0, green: 0.75, blue: 0.8)) // 温馨的粉色
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.86), // 奶油色
                    Color(red: 1.0, green: 0.95, blue: 0.9)   // 浅桃色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager.shared)
} 