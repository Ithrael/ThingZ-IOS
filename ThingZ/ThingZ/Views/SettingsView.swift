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
            VStack(spacing: 20) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("储物助手")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("版本 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("功能特色")
                        .font(.headline)
                    
                    FeatureRow(icon: "archivebox", title: "容器管理", description: "轻松管理各种储物容器")
                    FeatureRow(icon: "list.bullet", title: "物品分类", description: "智能分类管理物品")
                    FeatureRow(icon: "magnifyingglass", title: "快速搜索", description: "快速找到所需物品")
                    FeatureRow(icon: "bell", title: "智能提醒", description: "过期提醒和季节提醒")
                }
                .padding()
                
                Spacer()
                
                Text("© 2024 储物助手. 保留所有权利.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// 功能特色行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// 数据管理视图
struct DataManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLoadSampleAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("示例数据")) {
                    Button(action: {
                        showingLoadSampleAlert = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                            Text("加载示例数据")
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Section(header: Text("数据导入导出"), footer: Text("未来版本将支持数据导入导出功能")) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                        Text("导出数据")
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.gray)
                        Text("导入数据")
                    }
                    .foregroundColor(.gray)
                }
            }
            .navigationTitle("数据管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingLoadSampleAlert) {
                Alert(
                    title: Text("加载示例数据"),
                    message: Text("这将添加一些示例容器和物品，用于体验应用功能。"),
                    primaryButton: .default(Text("确认")) {
                        dataManager.loadSampleData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
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
            List {
                Section(header: Text("过期提醒")) {
                    Toggle("启用过期提醒", isOn: $expirationReminder)
                    
                    if expirationReminder {
                        HStack {
                            Text("提前提醒天数")
                            Spacer()
                            Picker("天数", selection: $reminderDaysBefore) {
                                ForEach(1...30, id: \.self) { day in
                                    Text("\(day)天").tag(day)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                Section(header: Text("季节提醒")) {
                    Toggle("启用季节提醒", isOn: $seasonalReminder)
                }
                
                Section(footer: Text("通知设置将在未来版本中实现完整功能")) {
                    EmptyView()
                }
            }
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
} 