import SwiftUI

struct ItemListView: View {
    @State private var items: [Item] = []
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var showingItemDetail = false
    @State private var selectedItem: Item?
    @State private var sortBy: SortOption = .name
    @State private var filterBy: FilterOption = .all
    @EnvironmentObject var dataManager: DataManager
    
    var filteredItems: [Item] {
        var filtered = items
        
        // 搜索过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.type.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 类型过滤
        switch filterBy {
        case .food:
            filtered = filtered.filter { $0.type == .food }
        case .clothing:
            filtered = filtered.filter { $0.type == .clothing }
        case .cosmetics:
            filtered = filtered.filter { $0.type == .cosmetics }
        case .miscellaneous:
            filtered = filtered.filter { $0.type == .miscellaneous }
        case .all:
            break
        }
        
        // 排序
        switch sortBy {
        case .name:
            return filtered.sorted(by: { $0.name < $1.name })
        case .type:
            return filtered.sorted(by: { $0.type.displayName < $1.type.displayName })
        case .dateAdded:
            return filtered.sorted(by: { $0.createdAt > $1.createdAt })
        case .expiration:
            return filtered.sorted { item1, item2 in
                // 食品类型的过期比较
                if let props1 = item1.foodProperties, let props2 = item2.foodProperties {
                    return props1.expirationDate < props2.expirationDate
                }
                // 化妆品类型的过期比较
                if let props1 = item1.cosmeticsProperties, let props2 = item2.cosmeticsProperties,
                   let exp1 = props1.expirationDate, let exp2 = props2.expirationDate {
                    return exp1 < exp2
                }
                return false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索物品...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("清除") {
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // 筛选和排序控件
                HStack {
                    Picker("筛选", selection: $filterBy) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                    
                    Picker("排序", selection: $sortBy) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)
                
                // 物品列表
                if filteredItems.isEmpty {
                    ItemEmptyStateView()
                } else {
                    List {
                        ForEach(filteredItems, id: \.id) { item in
                            Button(action: {
                                selectedItem = item
                                showingItemDetail = true
                            }) {
                                ItemRowView(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("物品列表")
            .navigationBarItems(trailing: Button(action: {
                showingAddItem = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showingItemDetail) {
                if let selectedItem = selectedItem {
                    ItemDetailView(item: selectedItem)
                }
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func loadItems() {
        items = dataManager.items
    }
}

// 物品行视图
struct ItemRowView: View {
    let item: Item
    @EnvironmentObject var dataManager: DataManager
    
    // 判断是否是衣柜中的衣服
    private var isClothingInWardrobe: Bool {
        guard item.type == .clothing,
              let containerId = item.containerId,
              let container = dataManager.getContainer(withId: containerId) else {
            return false
        }
        return container.type == .wardrobe
    }
    
    var body: some View {
        HStack {
            // 物品图片或图标
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(isClothingInWardrobe ? Color.purple.opacity(0.2) : Color.clear)
            } else {
                Image(systemName: item.type.icon)
                    .font(.title2)
                    .foregroundColor(isClothingInWardrobe ? .purple : .blue)
                    .frame(width: 50, height: 50)
                    .background(isClothingInWardrobe ? Color.purple.opacity(0.1) : Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(isClothingInWardrobe ? .purple : .primary)
                    .fontWeight(isClothingInWardrobe ? .semibold : .regular)
                
                // 显示容器信息
                if let containerId = item.containerId,
                   let container = dataManager.getContainer(withId: containerId) {
                    Text("位于：\(container.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(item.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isClothingInWardrobe ? Color.purple.opacity(0.3) : Color.blue.opacity(0.2))
                        .cornerRadius(4)
                        .foregroundColor(isClothingInWardrobe ? .white : .blue)
                    
                    Spacer()
                    
                    // 过期状态
                    if item.isExpired {
                        Text("已过期")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    } else if item.isExpiringSoon {
                        Text("即将过期")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                // 显示特有信息
                if let info = getItemSpecificInfo() {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 衣柜中的衣服显示特殊图标
            if isClothingInWardrobe {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.caption)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .background(
            Group {
                if isClothingInWardrobe {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    Rectangle()
                        .fill(Color.clear)
                }
            }
        )
    }
    
    private func getItemSpecificInfo() -> String? {
        switch item.type {
        case .food:
            if let properties = item.foodProperties {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "到期：\(formatter.string(from: properties.expirationDate))"
            }
        case .clothing:
            if let properties = item.clothingProperties {
                return "\(properties.season.displayName) | \(properties.color)"
            }
        case .cosmetics:
            if let properties = item.cosmeticsProperties {
                return properties.brand
            }
        case .miscellaneous:
            if let properties = item.miscellaneousProperties {
                return properties.category
            }
        }
        return nil
    }
}

// 空状态视图
struct ItemEmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("暂无物品")
                .font(.headline)
                .foregroundColor(.gray)
            Text("点击添加按钮来创建第一个物品")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// 排序选项
enum SortOption: String, CaseIterable {
    case name = "名称"
    case type = "类型"
    case dateAdded = "添加日期"
    case expiration = "过期时间"
    
    var displayName: String {
        return self.rawValue
    }
}

// 筛选选项
enum FilterOption: String, CaseIterable {
    case all = "全部"
    case food = "食品"
    case clothing = "衣物"
    case cosmetics = "化妆品"
    case miscellaneous = "杂物"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
            .environmentObject(DataManager.shared)
    }
} 