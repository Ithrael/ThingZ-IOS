import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAbout = false
    @State private var showingDataManagement = false
    @State private var showingNotificationSettings = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 数据统计
                Section(header: Text("数据统计")) {
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                        Text("容器总数")
                        Spacer()
                        Text("\(dataManager.totalContainers)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.green)
                        Text("物品总数")
                        Spacer()
                        Text("\(dataManager.totalItems)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("即将过期")
                        Spacer()
                        Text("\(dataManager.getExpiringSoonItems().count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("已过期")
                        Spacer()
                        Text("\(dataManager.getExpiredItems().count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 应用设置
                Section(header: Text("应用设置")) {
                    Button(action: {
                        showingNotificationSettings = true
                    }) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            Text("通知设置")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        showingDataManagement = true
                    }) {
                        HStack {
                            Image(systemName: "externaldrive")
                                .foregroundColor(.blue)
                            Text("数据管理")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // 关于
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("关于储物助手")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 危险操作
                Section(header: Text("危险操作")) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("清空所有数据")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingDataManagement) {
                DataManagementView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("确认删除"),
                    message: Text("此操作将清空所有容器和物品数据，无法恢复。"),
                    primaryButton: .destructive(Text("确认删除")) {
                        dataManager.clearAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// 关于视图
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.86), // 奶cream色
                        Color(red: 1.0, green: 0.95, blue: 0.9)   // 浅桃色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App图标和标题
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.82, blue: 0.86),
                                                Color(red: 1.0, green: 0.75, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                
                                Image(systemName: "archivebox.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("ThingZ 储物助手")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("版本 1.0.0 💖")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                                    )
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                            }
                        }
                        .padding(.top, 30)
                        
                        // 功能特色
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("功能特色 ✨")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                CuteFeatureRow(icon: "archivebox.fill", title: "容器管理", description: "轻松管理各种储物小窝～", color: Color(red: 1.0, green: 0.75, blue: 0.8))
                                CuteFeatureRow(icon: "heart.fill", title: "物品分类", description: "智能分类管理你的宝贝物品", color: Color(red: 1.0, green: 0.8, blue: 0.4))
                                CuteFeatureRow(icon: "magnifyingglass.circle.fill", title: "快速搜索", description: "快速找到心爱的小物件", color: Color(red: 0.7, green: 0.9, blue: 0.9))
                                CuteFeatureRow(icon: "bell.fill", title: "智能提醒", description: "贴心的过期和季节提醒", color: Color(red: 0.85, green: 0.7, blue: 0.9))
                            }
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // 版权信息
                        VStack(spacing: 8) {
                            Text("用爱制作 💕")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            
                            Text("© 2024 ThingZ. 保留所有权利.")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                        }
                        .padding(.all, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.6))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                    radius: 5,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("关于我们 💫")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// 可爱功能特色行
struct CuteFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
            }
            
            Spacer()
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }
}

// 数据管理视图
struct DataManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLoadSampleAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.86), // 奶cream色
                        Color(red: 1.0, green: 0.95, blue: 0.9)   // 浅桃色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 页面标题区域
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.7, green: 0.9, blue: 0.9),
                                                Color(red: 0.6, green: 0.8, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(
                                        color: Color(red: 0.7, green: 0.9, blue: 0.9).opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                
                                Image(systemName: "externaldrive.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("数据管理中心 📊")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("管理你的数据宝库")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            }
                        }
                        .padding(.top, 30)
                        
                        // 示例数据区域
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("示例数据 🎁")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            
                            DataManagementCard(
                                icon: "square.and.arrow.down.fill",
                                title: "加载示例数据",
                                description: "体验应用功能的示例容器和物品",
                                color: Color(red: 1.0, green: 0.75, blue: 0.8),
                                action: {
                                    showingLoadSampleAlert = true
                                }
                            )
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // 数据导入导出区域
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("数据导入导出 🔄")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                DataManagementCard(
                                    icon: "square.and.arrow.up.fill",
                                    title: "导出数据",
                                    description: "备份你的所有数据",
                                    color: Color(red: 0.7, green: 0.7, blue: 0.7),
                                    isDisabled: true,
                                    action: {}
                                )
                                
                                DataManagementCard(
                                    icon: "square.and.arrow.down.fill",
                                    title: "导入数据",
                                    description: "恢复备份的数据",
                                    color: Color(red: 0.7, green: 0.7, blue: 0.7),
                                    isDisabled: true,
                                    action: {}
                                )
                            }
                            
                            Text("💡 提示：数据导入导出功能将在未来版本中实现")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                .padding(.all, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.3))
                                )
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("数据管理 💾")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .fontWeight(.medium)
                }
            }
            .alert(isPresented: $showingLoadSampleAlert) {
                Alert(
                    title: Text("加载示例数据 🎉"),
                    message: Text("这将添加一些示例容器和物品，用于体验应用功能哦～"),
                    primaryButton: .default(Text("好的！")) {
                        dataManager.loadSampleData()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
    }
}

// 数据管理卡片
struct DataManagementCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(isDisabled ? 0.4 : 0.8),
                                    color.opacity(isDisabled ? 0.3 : 0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(
                            color: color.opacity(isDisabled ? 0.1 : 0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white.opacity(isDisabled ? 0.6 : 1.0))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1).opacity(isDisabled ? 0.5 : 1.0))
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3).opacity(isDisabled ? 0.5 : 1.0))
                }
                
                Spacer()
                
                if !isDisabled {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                        .font(.caption)
                }
            }
            .padding(.all, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isDisabled ? 0.4 : 0.6))
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(isDisabled ? 0.05 : 0.1),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

// 通知设置视图
struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var expirationReminder = true
    @State private var seasonalReminder = true
    @State private var reminderDaysBefore = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.86), // 奶cream色
                        Color(red: 1.0, green: 0.95, blue: 0.9)   // 浅桃色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 页面标题区域
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.8, blue: 0.4),
                                                Color(red: 1.0, green: 0.7, blue: 0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("通知设置中心 🔔")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("贴心提醒，从不错过")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            }
                        }
                        .padding(.top, 30)
                        
                        // 过期提醒区域
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("过期提醒 ⏰")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // 启用过期提醒开关
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 1.0, green: 0.6, blue: 0.6),
                                                        Color(red: 1.0, green: 0.5, blue: 0.5)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 40, height: 40)
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.3),
                                                radius: 6,
                                                x: 0,
                                                y: 3
                                            )
                                        
                                        Image(systemName: "clock.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("启用过期提醒")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Text("物品过期前会收到提醒")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $expirationReminder)
                                        .labelsHidden()
                                        .tint(Color(red: 1.0, green: 0.75, blue: 0.8))
                                }
                                .padding(.all, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.6))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                            radius: 5,
                                            x: 0,
                                            y: 2
                                        )
                                )
                                
                                // 提前提醒天数
                                if expirationReminder {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 1.0, green: 0.8, blue: 0.4),
                                                            Color(red: 1.0, green: 0.7, blue: 0.3)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 40, height: 40)
                                                .shadow(
                                                    color: Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3),
                                                    radius: 6,
                                                    x: 0,
                                                    y: 3
                                                )
                                            
                                            Image(systemName: "calendar")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text("提前提醒天数")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Spacer()
                                        
                                        Menu {
                                            ForEach(1...30, id: \.self) { day in
                                                Button("\(day)天") {
                                                    reminderDaysBefore = day
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Text("\(reminderDaysBefore)天")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                                
                                                Image(systemName: "chevron.down")
                                                    .font(.caption)
                                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                                            )
                                        }
                                    }
                                    .padding(.all, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.6))
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                                radius: 5,
                                                x: 0,
                                                y: 2
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // 季节提醒区域
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("季节提醒 🌸")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.7, green: 0.9, blue: 0.7),
                                                    Color(red: 0.6, green: 0.8, blue: 0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                        .shadow(
                                            color: Color(red: 0.7, green: 0.9, blue: 0.7).opacity(0.3),
                                            radius: 6,
                                            x: 0,
                                            y: 3
                                        )
                                    
                                    Image(systemName: "leaf.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("启用季节提醒")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    
                                    Text("换季时提醒整理衣物")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $seasonalReminder)
                                    .labelsHidden()
                                    .tint(Color(red: 1.0, green: 0.75, blue: 0.8))
                            }
                            .padding(.all, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                        radius: 5,
                                        x: 0,
                                        y: 2
                                    )
                            )
                        }
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // 提示信息
                        VStack(spacing: 8) {
                            Text("💡 小贴士")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            
                            Text("通知功能的完整实现将在未来版本中上线，敬请期待～")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.all, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.3))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                    radius: 5,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("通知设置 📢")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
} 