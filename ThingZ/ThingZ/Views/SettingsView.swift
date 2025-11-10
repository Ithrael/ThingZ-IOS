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

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
}
