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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 物品图片
                    if let image = item.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: item.type.icon)
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // 基本信息
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(item.type.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // 过期状态
                            if item.isExpired {
                                Label("已过期", systemImage: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            } else if item.isExpiringSoon {
                                Label("即将过期", systemImage: "clock")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        if let container = container {
                            HStack {
                                Image(systemName: container.type.icon)
                                    .foregroundColor(.blue)
                                Text("位于：\(container.name)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !item.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("备注")
                                    .font(.headline)
                                Text(item.notes)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 特有属性
                    getPropertiesView()
                }
                .padding()
            }
            .navigationTitle("物品详情")
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
            Text("衣物属性")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PropertyCard(title: "类型", value: properties.clothingType.displayName)
                PropertyCard(title: "季节", value: properties.season.displayName)
                PropertyCard(title: "颜色", value: properties.color.isEmpty ? "未设置" : properties.color)
                PropertyCard(title: "材质", value: properties.material.isEmpty ? "未设置" : properties.material)
                PropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 食品属性详情
struct FoodPropertiesDetail: View {
    let properties: FoodProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("食品属性")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PropertyCard(title: "保质期", value: DateFormatter.localizedString(from: properties.expirationDate, dateStyle: .medium, timeStyle: .none))
                PropertyCard(title: "数量", value: "\(properties.quantity) \(properties.unit)")
                PropertyCard(title: "类型", value: properties.foodType.displayName)
                PropertyCard(title: "存放条件", value: properties.storageCondition.isEmpty ? "未设置" : properties.storageCondition)
                PropertyCard(title: "剩余天数", value: "\(properties.daysUntilExpiration)天")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 化妆品属性详情
struct CosmeticsPropertiesDetail: View {
    let properties: CosmeticsProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("化妆品属性")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PropertyCard(title: "类型", value: properties.cosmeticsType.displayName)
                PropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand)
                
                if let openedDate = properties.openedDate {
                    PropertyCard(title: "开封日期", value: DateFormatter.localizedString(from: openedDate, dateStyle: .medium, timeStyle: .none))
                    PropertyCard(title: "开封保质期", value: "\(properties.shelfLifeAfterOpening)个月")
                    
                    if let expirationDate = properties.expirationDate {
                        PropertyCard(title: "过期日期", value: DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none))
                    }
                } else {
                    PropertyCard(title: "开封状态", value: "未开封")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 杂物属性详情
struct MiscellaneousPropertiesDetail: View {
    let properties: MiscellaneousProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("杂物属性")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PropertyCard(title: "类别", value: properties.category.isEmpty ? "未设置" : properties.category)
                PropertyCard(title: "品牌", value: properties.brand.isEmpty ? "未设置" : properties.brand)
                PropertyCard(title: "型号", value: properties.model.isEmpty ? "未设置" : properties.model)
                
                if let purchaseDate = properties.purchaseDate {
                    PropertyCard(title: "购买日期", value: DateFormatter.localizedString(from: purchaseDate, dateStyle: .medium, timeStyle: .none))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 属性卡片
struct PropertyCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

#Preview {
    let sampleItem = Item(name: "白色T恤", type: .clothing)
    return ItemDetailView(item: sampleItem)
        .environmentObject(DataManager.shared)
} 