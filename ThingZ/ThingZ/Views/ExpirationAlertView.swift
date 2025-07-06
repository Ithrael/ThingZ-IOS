import SwiftUI

struct ExpirationAlertView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedDaysAhead = 7
    @State private var showingExpiredOnly = false
    
    private var expiringItems: [Item] {
        NotificationManager.shared.getExpiringItems(from: dataManager.items, daysAhead: selectedDaysAhead)
    }
    
    private var expiredItems: [Item] {
        dataManager.getExpiredItems()
    }
    
    var body: some View {
        NavigationView {
            List {
                // 控制区域
                Section {
                    HStack {
                        Text("提前天数:")
                            .font(.subheadline)
                        Spacer()
                        Picker("提前天数", selection: $selectedDaysAhead) {
                            Text("3天").tag(3)
                            Text("7天").tag(7)
                            Text("14天").tag(14)
                            Text("30天").tag(30)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Toggle("只显示已过期", isOn: $showingExpiredOnly)
                }
                
                // 已过期物品
                if !expiredItems.isEmpty {
                    Section(header: Text("已过期物品")) {
                        ForEach(expiredItems) { item in
                            ExpirationItemRow(item: item, isExpired: true)
                        }
                    }
                }
                
                // 即将过期物品
                if !showingExpiredOnly && !expiringItems.isEmpty {
                    Section(header: Text("即将过期物品")) {
                        ForEach(expiringItems) { item in
                            ExpirationItemRow(item: item, isExpired: false)
                        }
                    }
                }
                
                // 空状态
                if (showingExpiredOnly && expiredItems.isEmpty) || 
                   (!showingExpiredOnly && expiredItems.isEmpty && expiringItems.isEmpty) {
                    Section {
                        ExpirationEmptyStateView(
                            icon: "checkmark.circle.fill",
                            title: showingExpiredOnly ? "没有过期物品" : "没有即将过期的物品",
                            description: showingExpiredOnly ? "所有物品都在有效期内" : "所有物品都在安全期内"
                        )
                    }
                }
            }
            .navigationTitle("过期提醒")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("刷新提醒") {
                        NotificationManager.shared.refreshAllReminders(for: dataManager.items)
                    }
                }
            }
        }
    }
}

struct ExpirationItemRow: View {
    let item: Item
    let isExpired: Bool
    @ObservedObject var dataManager = DataManager.shared
    
    private var expirationInfo: (date: Date?, daysLeft: Int) {
        if let foodProperties = item.foodProperties {
            let expirationDate = foodProperties.expirationDate
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
            return (expirationDate, daysLeft)
        }
        
        if let cosmeticsProperties = item.cosmeticsProperties,
           let openedDate = cosmeticsProperties.openedDate {
            let shelfLife = cosmeticsProperties.shelfLifeAfterOpening
            let expirationDate = Calendar.current.date(byAdding: .month, value: shelfLife, to: openedDate) ?? Date()
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
            return (expirationDate, daysLeft)
        }
        
        return (nil, 0)
    }
    
    private var containerName: String {
        if let container = dataManager.containers.first(where: { $0.id == item.containerId }) {
            return container.name
        }
        return "未知容器"
    }
    
    var body: some View {
        HStack {
            // 物品图片或类型图标
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: item.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(isExpired ? .red : .primary)
                
                Text(containerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let expirationDate = expirationInfo.date {
                        Text("\(expirationDate, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if isExpired {
                    Text("已过期")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                } else {
                    let daysLeft = expirationInfo.daysLeft
                    if daysLeft <= 0 {
                        Text("今天过期")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else {
                        Text("\(daysLeft)天后")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExpirationEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    ExpirationAlertView()
} 