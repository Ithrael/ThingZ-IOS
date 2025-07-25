import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    var container: Container? {
        guard let containerId = item.containerId else { return nil }
        return dataManager.getContainer(withId: containerId)
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
                    VStack(spacing: 24) {
                        // 物品图片
                        VStack(spacing: 16) {
                            if let image = item.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .cornerRadius(20)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.9, blue: 0.95),
                                                    Color(red: 1.0, green: 0.85, blue: 0.9)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(height: 200)
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                            radius: 15,
                                            x: 0,
                                            y: 8
                                        )
                                    
                                    Image(systemName: item.type.icon)
                                        .font(.system(size: 60))
                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 基本信息
                        VStack(spacing: 20) {
                            // 标题和状态
                            VStack(spacing: 12) {
                                Text(item.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                HStack(spacing: 12) {
                                    Text(item.type.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                                        )
                                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                                    
                                    // 过期状态
                                    if item.isExpired {
                                        Text("已过期 😢")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color(red: 1.0, green: 0.6, blue: 0.6))
                                            )
                                            .foregroundColor(.white)
                                    } else if item.isExpiringSoon {
                                        Text("快过期啦 ⏰")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                                            )
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            // 位置信息
                            if let container = container {
                                HStack(spacing: 12) {
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
                                            .frame(width: 40, height: 40)
                                            .shadow(
                                                color: Color(red: 0.7, green: 0.9, blue: 0.9).opacity(0.3),
                                                radius: 6,
                                                x: 0,
                                                y: 3
                                            )
                                        
                                        Image(systemName: container.type.icon)
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("住在：\(container.name) 🏠")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Text(container.location)
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // 备注
                            if !item.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("备注 📝")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        Spacer()
                                    }
                                    
                                    Text(item.notes)
                                        .font(.body)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                        .padding(.all, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
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
                        
                        // 特有属性
                        getPropertiesView()
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("宝贝详情 💎")
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
    
    @ViewBuilder
    private func getPropertiesView() -> some View {
        switch item.type {
        case .clothing:
            if let properties = item.clothingProperties {
                ClothingPropertiesDetail(properties: properties)
            }
        case .food:
            if let properties = item.foodProperties {
                FoodPropertiesDetail(properties: properties)
            }
        case .cosmetics:
            if let properties = item.cosmeticsProperties {
                CosmeticsPropertiesDetail(properties: properties)
            }
        case .miscellaneous:
            if let properties = item.miscellaneousProperties {
                MiscellaneousPropertiesDetail(properties: properties)
            }
        }
    }
}

// 衣物属性详情
struct ClothingPropertiesDetail: View {
    let properties: ClothingProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("衣物属性 👔")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DetailPropertyCard(title: "类型", value: properties.clothingType.displayName, icon: "tshirt.fill")
                DetailPropertyCard(title: "季节", value: properties.season.displayName, icon: "sun.max.fill")
                DetailPropertyCard(title: "颜色", value: properties.color.isEmpty ? "未设置" : properties.color, icon: "paintpalette.fill")
                DetailPropertyCard(title: "材质", value: properties.material.isEmpty ? "未设置" : properties.material, icon: "leaf.fill")
                DetailPropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand, icon: "tag.fill")
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
    }
}

// 食品属性详情
struct FoodPropertiesDetail: View {
    let properties: FoodProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("食品属性 🍎")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DetailPropertyCard(title: "保质期", value: DateFormatter.localizedString(from: properties.expirationDate, dateStyle: .medium, timeStyle: .none), icon: "calendar")
                DetailPropertyCard(title: "数量", value: "\(properties.quantity) \(properties.unit)", icon: "number")
                DetailPropertyCard(title: "类型", value: properties.foodType.displayName, icon: "fork.knife")
                DetailPropertyCard(title: "存放条件", value: properties.storageCondition.isEmpty ? "未设置" : properties.storageCondition, icon: "thermometer")
                DetailPropertyCard(title: "剩余天数", value: "\(properties.daysUntilExpiration)天", icon: "clock.fill")
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
    }
}

// 化妆品属性详情
struct CosmeticsPropertiesDetail: View {
    let properties: CosmeticsProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("化妆品属性 💄")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DetailPropertyCard(title: "类型", value: properties.cosmeticsType.displayName, icon: "sparkles")
                DetailPropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand, icon: "tag.fill")
                
                if let openedDate = properties.openedDate {
                    DetailPropertyCard(title: "开封日期", value: DateFormatter.localizedString(from: openedDate, dateStyle: .medium, timeStyle: .none), icon: "calendar")
                    DetailPropertyCard(title: "开封保质期", value: "\(properties.shelfLifeAfterOpening)个月", icon: "clock.fill")
                    
                    if let expirationDate = properties.expirationDate {
                        DetailPropertyCard(title: "过期日期", value: DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none), icon: "exclamationmark.triangle.fill")
                    }
                } else {
                    DetailPropertyCard(title: "开封状态", value: "未开封", icon: "checkmark.seal.fill")
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
    }
}

// 杂物属性详情
struct MiscellaneousPropertiesDetail: View {
    let properties: MiscellaneousProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("杂物属性 📎")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DetailPropertyCard(title: "类别", value: properties.category.isEmpty ? "未设置" : properties.category, icon: "folder.fill")
                DetailPropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand, icon: "tag.fill")
                DetailPropertyCard(title: "型号", value: properties.model.isEmpty ? "未设置" : properties.model, icon: "barcode")
                
                if let purchaseDate = properties.purchaseDate {
                    DetailPropertyCard(title: "购买日期", value: DateFormatter.localizedString(from: purchaseDate, dateStyle: .medium, timeStyle: .none), icon: "calendar")
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
    }
}

// 详情属性卡片
struct DetailPropertyCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.7),
                                Color(red: 1.0, green: 0.8, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 35, height: 35)
                    .shadow(
                        color: Color(red: 1.0, green: 0.8, blue: 0.6).opacity(0.3),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.all, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.6))
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                    radius: 3,
                    x: 0,
                    y: 1
                )
        )
    }
}

#Preview {
    let sampleItem = Item(name: "白色T恤", type: .clothing)
    return ItemDetailView(item: sampleItem)
        .environmentObject(DataManager.shared)
} 