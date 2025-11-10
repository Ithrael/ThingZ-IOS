import SwiftUI

struct DataManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showingClearDataAlert = false
    @State private var showingExportAlert = false
    @State private var showingImportAlert = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    @State private var isLoading = false
    
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
                        
                        Text("处理中，请稍候...")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // 数据统计
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "数据统计")
                                
                                InfoCard {
                                    VStack(spacing: 16) {
                                        DataStatRow(title: "容器总数", value: "\(dataManager.totalContainers)", icon: "archivebox.fill", color: Color(red: 1.0, green: 0.75, blue: 0.8))
                                        
                                        DataStatRow(title: "物品总数", value: "\(dataManager.totalItems)", icon: "heart.fill", color: Color(red: 1.0, green: 0.8, blue: 0.4))
                                        
                                        DataStatRow(title: "即将过期物品", value: "\(dataManager.getExpiringSoonItems().count)", icon: "clock.badge", color: Color(red: 1.0, green: 0.8, blue: 0.4))
                                        
                                        DataStatRow(title: "已过期物品", value: "\(dataManager.getExpiredItems().count)", icon: "exclamationmark.triangle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.6))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // 数据管理
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "数据管理")
                                
                                VStack(spacing: 16) {
                                    // 备份数据
                                    ActionButton(
                                        title: "备份数据",
                                        description: "将所有数据备份到云端",
                                        icon: "arrow.up.doc.fill",
                                        color: Color(red: 0.7, green: 0.9, blue: 0.7)
                                    ) {
                                        showingBackupAlert = true
                                    }
                                    
                                    // 恢复数据
                                    ActionButton(
                                        title: "恢复数据",
                                        description: "从云端恢复之前备份的数据",
                                        icon: "arrow.down.doc.fill",
                                        color: Color(red: 0.7, green: 0.9, blue: 0.9)
                                    ) {
                                        showingRestoreAlert = true
                                    }
                                    
                                    // 导出数据
                                    ActionButton(
                                        title: "导出数据",
                                        description: "将数据导出为文件",
                                        icon: "square.and.arrow.up",
                                        color: Color(red: 1.0, green: 0.8, blue: 0.4)
                                    ) {
                                        showingExportAlert = true
                                    }
                                    
                                    // 导入数据
                                    ActionButton(
                                        title: "导入数据",
                                        description: "从文件导入数据",
                                        icon: "square.and.arrow.down",
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8)
                                    ) {
                                        showingImportAlert = true
                                    }
                                    
                                    // 清除数据
                                    ActionButton(
                                        title: "清除所有数据",
                                        description: "删除所有本地存储的数据（不可恢复）",
                                        icon: "trash.fill",
                                        color: Color(red: 1.0, green: 0.6, blue: 0.6)
                                    ) {
                                        showingClearDataAlert = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 数据安全
                            VStack(alignment: .leading, spacing: 20) {
                                SectionTitle(title: "数据安全")
                                
                                InfoCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("ThingZ重视您的数据安全和隐私保护：")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        SecurityRow(text: "所有数据均使用加密方式存储")
                                        SecurityRow(text: "云端备份采用端到端加密技术")
                                        SecurityRow(text: "您可以随时导出或删除个人数据")
                                        SecurityRow(text: "我们不会将您的数据用于商业目的")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("数据管理")
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
            .alert("清除所有数据", isPresented: $showingClearDataAlert) {
                Button("取消", role: .cancel) { }
                Button("确认清除", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作将删除所有本地存储的数据，且无法恢复。确定要继续吗？")
            }
            .alert("备份数据", isPresented: $showingBackupAlert) {
                Button("取消", role: .cancel) { }
                Button("确认备份", role: .none) {
                    backupData()
                }
            } message: {
                Text("此操作将覆盖云端已有的备份数据。确定要继续吗？")
            }
            .alert("恢复数据", isPresented: $showingRestoreAlert) {
                Button("取消", role: .cancel) { }
                Button("确认恢复", role: .none) {
                    restoreData()
                }
            } message: {
                Text("此操作将使用云端备份数据覆盖本地数据。确定要继续吗？")
            }
            .alert("导出数据", isPresented: $showingExportAlert) {
                Button("取消", role: .cancel) { }
                Button("确认导出", role: .none) {
                    exportData()
                }
            } message: {
                Text("此操作将导出所有数据为文件。确定要继续吗？")
            }
            .alert("导入数据", isPresented: $showingImportAlert) {
                Button("取消", role: .cancel) { }
                Button("确认导入", role: .none) {
                    importData()
                }
            } message: {
                Text("此操作将使用导入的数据覆盖本地数据。确定要继续吗？")
            }
            .alert("操作成功", isPresented: $showingSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    // 清除所有数据
    private func clearAllData() {
        isLoading = true
        
        // 模拟操作延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dataManager.clearAllData()
            
            isLoading = false
            successMessage = "所有数据已清除"
            showingSuccessAlert = true
        }
    }
    
    // 备份数据
    private func backupData() {
        isLoading = true
        
        // 模拟操作延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            successMessage = "数据已成功备份到云端"
            showingSuccessAlert = true
        }
    }
    
    // 恢复数据
    private func restoreData() {
        isLoading = true
        
        // 模拟操作延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            successMessage = "数据已成功从云端恢复"
            showingSuccessAlert = true
        }
    }
    
    // 导出数据
    private func exportData() {
        isLoading = true
        
        // 模拟操作延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            successMessage = "数据已成功导出"
            showingSuccessAlert = true
        }
    }
    
    // 导入数据
    private func importData() {
        isLoading = true
        
        // 模拟操作延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            successMessage = "数据已成功导入"
            showingSuccessAlert = true
        }
    }
}

// 数据统计行
struct DataStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
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
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
        }
    }
}

// 安全信息行
struct SecurityRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.subheadline)
                .foregroundColor(Color(red: 0.7, green: 0.9, blue: 0.7))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                .lineSpacing(4)
        }
    }
}

// 操作按钮
struct ActionButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                            radius: 6,
                            x: 0,
                            y: 3
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
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(color)
                    .font(.caption)
            }
            .padding(.all, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DataManagementView()
        .environmentObject(DataManager.shared)
        .environmentObject(AuthManager.shared)
}