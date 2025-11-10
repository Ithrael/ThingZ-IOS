import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var expirationEnabled = true
    @State private var expirationDays = 3
    @State private var dailyDigestEnabled = true
    @State private var dailyDigestTime = Date()
    @State private var weeklyReportEnabled = true
    @State private var showingPermissionAlert = false
    @State private var isLoading = false
    @State private var showingSuccessAlert = false
    
    private let expirationDaysOptions = [1, 2, 3, 5, 7, 14]
    
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
                
                if isLoading {
                    // 加载指示器
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                            .scaleEffect(1.5)
                        
                        Text("保存设置中...")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // 通知权限状态
                            NotificationPermissionCard()
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            // 过期提醒设置
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "过期提醒")
                                
                                SettingsCard {
                                    VStack(spacing: 20) {
                                        // 启用过期提醒
                                        ToggleRow(
                                            title: "启用过期提醒",
                                            description: "在物品即将过期时收到通知",
                                            icon: "bell.badge.fill",
                                            color: Color(red: 1.0, green: 0.8, blue: 0.4),
                                            isOn: $expirationEnabled
                                        )
                                        
                                        if expirationEnabled {
                                            Divider()
                                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                            
                                            // 提前天数选择
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text("提前提醒天数")
                                                    .font(.headline)
                                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                                
                                                Text("在物品过期前多少天收到提醒")
                                                    .font(.caption)
                                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                                
                                                // 天数选择器
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 12) {
                                                        ForEach(expirationDaysOptions, id: \.self) { days in
                                                            DaySelectionButton(
                                                                days: days,
                                                                isSelected: expirationDays == days,
                                                                action: {
                                                                    expirationDays = days
                                                                }
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 每日摘要设置
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "每日摘要")
                                
                                SettingsCard {
                                    VStack(spacing: 20) {
                                        // 启用每日摘要
                                        ToggleRow(
                                            title: "启用每日摘要",
                                            description: "每天收到物品状态摘要",
                                            icon: "newspaper.fill",
                                            color: Color(red: 0.7, green: 0.9, blue: 0.7),
                                            isOn: $dailyDigestEnabled
                                        )
                                        
                                        if dailyDigestEnabled {
                                            Divider()
                                                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                            
                                            // 提醒时间选择
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text("提醒时间")
                                                    .font(.headline)
                                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                                
                                                DatePicker(
                                                    "每天发送摘要的时间",
                                                    selection: $dailyDigestTime,
                                                    displayedComponents: .hourAndMinute
                                                )
                                                .datePickerStyle(.wheel)
                                                .labelsHidden()
                                                .frame(maxHeight: 150)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 周报设置
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "周报")
                                
                                SettingsCard {
                                    // 启用周报
                                    ToggleRow(
                                        title: "启用周报",
                                        description: "每周收到物品管理统计报告",
                                        icon: "chart.bar.fill",
                                        color: Color(red: 0.7, green: 0.9, blue: 0.9),
                                        isOn: $weeklyReportEnabled
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 保存按钮
                            Button(action: saveSettings) {
                                Text("保存设置")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.75, blue: 0.8),
                                                Color(red: 1.0, green: 0.65, blue: 0.7)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                        radius: 12,
                                        x: 0,
                                        y: 6
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    }
                }
            }
            .alert("通知权限", isPresented: $showingPermissionAlert) {
                Button("取消", role: .cancel) { }
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("请在设置中允许ThingZ发送通知，以便接收物品过期提醒。")
            }
            .alert("设置已保存", isPresented: $showingSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("您的通知设置已成功保存")
            }
            .onAppear {
                // 加载当前设置
                loadCurrentSettings()
            }
        }
    }
    
    // 加载当前设置
    private func loadCurrentSettings() {
        // 这里应该从UserDefaults或其他存储中加载设置
        // 暂时使用默认值
    }
    
    // 保存设置
    private func saveSettings() {
        isLoading = true
        
        // 检查通知权限
        NotificationManager.shared.checkNotificationAuthorization { authorized in
            if authorized {
                // 有权限，保存设置
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // 这里应该保存设置到UserDefaults或其他存储
                    // 并更新NotificationManager中的设置
                    
                    // 刷新所有提醒
                    NotificationManager.shared.refreshAllReminders(for: dataManager.items)
                    
                    isLoading = false
                    showingSuccessAlert = true
                }
            } else {
                // 无权限，显示提示
                DispatchQueue.main.async {
                    isLoading = false
                    showingPermissionAlert = true
                }
            }
        }
    }
}

// 通知权限卡片
struct NotificationPermissionCard: View {
    @State private var hasPermission = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            hasPermission ?
                            Color(red: 0.7, green: 0.9, blue: 0.7) :
                            Color(red: 1.0, green: 0.6, blue: 0.6)
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: hasPermission ? "checkmark" : "exclamationmark")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hasPermission ? "通知已启用" : "通知未启用")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    Text(hasPermission ? "您将收到物品过期等重要提醒" : "请允许通知权限以接收重要提醒")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
                
                Spacer()
                
                if !hasPermission {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("设置")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.75, blue: 0.8))
                            )
                    }
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
        .onAppear {
            checkNotificationPermission()
        }
    }
    
    // 检查通知权限
    private func checkNotificationPermission() {
        NotificationManager.shared.checkNotificationAuthorization { authorized in
            DispatchQueue.main.async {
                hasPermission = authorized
            }
        }
    }
}

// 设置卡片
struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
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
    }
}

// 开关行
struct ToggleRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
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
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
        }
    }
}

// 天数选择按钮
struct DaySelectionButton: View {
    let days: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("\(days)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text(days == 1 ? "天" : "天")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : Color(red: 0.6, green: 0.4, blue: 0.3))
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        AnyShapeStyle(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.75, blue: 0.8),
                                Color(red: 1.0, green: 0.65, blue: 0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )) :
                        AnyShapeStyle(Color.white.opacity(0.6))
                    )
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(isSelected ? 0.3 : 0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(DataManager.shared)
}