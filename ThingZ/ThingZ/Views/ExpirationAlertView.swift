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
                    VStack(spacing: 20) {
                        // 控制区域
                        VStack(spacing: 16) {
                            // 提前天数选择
                            VStack(alignment: .leading, spacing: 8) {
                                Text("提醒设置 ⚙️")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("提前天数:")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                            Spacer()
                                        }
                                        
                                        HStack(spacing: 8) {
                                            ForEach([3, 7, 14, 30], id: \.self) { days in
                                                Button(action: {
                                                    selectedDaysAhead = days
                                                }) {
                                                    Text("\(days)天")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(selectedDaysAhead == days ? .white : Color(red: 0.6, green: 0.4, blue: 0.3))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .fill(selectedDaysAhead == days ? 
                                                                      Color(red: 1.0, green: 0.75, blue: 0.8) : 
                                                                      Color(red: 1.0, green: 0.9, blue: 0.7))
                                                                .shadow(
                                                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                                                    radius: selectedDaysAhead == days ? 6 : 2,
                                                                    x: 0,
                                                                    y: selectedDaysAhead == days ? 3 : 1
                                                                )
                                                        )
                                                }
                                                .scaleEffect(selectedDaysAhead == days ? 1.05 : 1.0)
                                                .animation(.easeInOut(duration: 0.2), value: selectedDaysAhead)
                                            }
                                            Spacer()
                                        }
                                        
                                        HStack {
                                            Text("只显示已过期")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                            
                                            Spacer()
                                            
                                            Toggle("", isOn: $showingExpiredOnly)
                                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                                                .scaleEffect(0.8)
                                        }
                                    }
                                    .padding(.all, 16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // 已过期物品
                        if !expiredItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("已过期物品 😰")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    
                                    Text("(\(expiredItems.count))")
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(expiredItems) { item in
                                        ExpirationItemRow(item: item, isExpired: true)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // 即将过期物品
                        if !showingExpiredOnly && !expiringItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("即将过期物品 ⏰")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    
                                    Text("(\(expiringItems.count))")
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(expiringItems) { item in
                                        ExpirationItemRow(item: item, isExpired: false)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // 空状态
                        if (showingExpiredOnly && expiredItems.isEmpty) || 
                           (!showingExpiredOnly && expiredItems.isEmpty && expiringItems.isEmpty) {
                            ExpirationEmptyStateView(
                                icon: "checkmark.circle.fill",
                                title: showingExpiredOnly ? "没有过期物品 ✨" : "没有即将过期的物品 🎉",
                                description: showingExpiredOnly ? "所有物品都在有效期内，真棒！" : "所有物品都在安全期内，继续保持～"
                            )
                            .padding(.top, 30)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("过期提醒 ⏰")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("🔄") {
                        NotificationManager.shared.refreshAllReminders(for: dataManager.items)
                    }
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
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
        HStack(spacing: 16) {
            // 物品图标
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isExpired ? Color(red: 1.0, green: 0.7, blue: 0.7) : Color(red: 1.0, green: 0.82, blue: 0.86),
                                isExpired ? Color(red: 1.0, green: 0.6, blue: 0.6) : Color(red: 1.0, green: 0.75, blue: 0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(
                        color: (isExpired ? Color(red: 1.0, green: 0.6, blue: 0.6) : Color(red: 1.0, green: 0.75, blue: 0.8)).opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: item.type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isExpired ? Color(red: 0.6, green: 0.2, blue: 0.2) : Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text("住在：\(containerName) 🏠")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                
                HStack(spacing: 8) {
                    if let expirationDate = expirationInfo.date {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            
                            Text("\(expirationDate, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                        )
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if isExpired {
                    Text("已过期")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.6, blue: 0.6))
                        )
                        .foregroundColor(.white)
                } else {
                    let daysLeft = expirationInfo.daysLeft
                    if daysLeft <= 0 {
                        Text("今天过期")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.7, blue: 0.4))
                            )
                            .foregroundColor(.white)
                    } else {
                        Text("\(daysLeft)天后")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                            )
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.8))
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isExpired ? 
                            Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.3) : 
                            Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct ExpirationEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
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
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: Color.green.opacity(0.3),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text(description)
                    .font(.body)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.all, 30)
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