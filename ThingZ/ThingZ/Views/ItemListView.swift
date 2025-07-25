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
                
                VStack(spacing: 16) {
                // 搜索栏
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                HStack {
                                Image(systemName: "heart.magnifyingglass")
                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                    .font(.title3)
                    
                                TextField("寻找你的宝贝物品...", text: $searchText)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    if !searchText.isEmpty {
                                    Button("✨") {
                            searchText = ""
                        }
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                    }
                }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 16)
                
                // 筛选和排序控件
                    HStack(spacing: 16) {
                        Menu {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                                Button(action: {
                                    filterBy = option
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if filterBy == option {
                                            Image(systemName: "checkmark")
                        }
                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("筛选: \(filterBy.displayName)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                        radius: 5,
                                        x: 0,
                                        y: 2
                                    )
                            )
                        }
                    
                    Spacer()
                    
                        Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    sortBy = option
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if sortBy == option {
                                            Image(systemName: "checkmark")
                        }
                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("排序: \(sortBy.displayName)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                        radius: 5,
                                        x: 0,
                                        y: 2
                                    )
                            )
                        }
                }
                    .padding(.horizontal, 16)
                
                // 物品列表
                if filteredItems.isEmpty {
                    ItemEmptyStateView()
                            .padding(.top, 50)
                } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
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
                            .padding(.horizontal, 16)
                    }
                }
                
                Spacer()
            }
            }
            .navigationTitle("宝贝收藏 💝")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                showingAddItem = true
            }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                            .font(.title2)
                    }
                }
            }
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
        HStack(spacing: 16) {
            // 物品图片或图标
            ZStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isClothingInWardrobe ? Color(red: 0.85, green: 0.7, blue: 0.9) : Color(red: 1.0, green: 0.82, blue: 0.86),
                                    isClothingInWardrobe ? Color(red: 0.75, green: 0.6, blue: 0.85) : Color(red: 1.0, green: 0.75, blue: 0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: (isClothingInWardrobe ? Color.purple : Color(red: 1.0, green: 0.75, blue: 0.8)).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                Image(systemName: item.type.icon)
                    .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isClothingInWardrobe ? Color(red: 0.4, green: 0.2, blue: 0.5) : Color(red: 0.4, green: 0.2, blue: 0.1))
                
                // 显示容器信息
                if let containerId = item.containerId,
                   let container = dataManager.getContainer(withId: containerId) {
                    Text("住在：\(container.name) 🏠")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
                
                HStack {
                    Text(item.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(isClothingInWardrobe ? Color(red: 0.9, green: 0.8, blue: 0.95) : Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(isClothingInWardrobe ? Color(red: 0.6, green: 0.4, blue: 0.7) : Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    Spacer()
                    
                    // 过期状态
                    if item.isExpired {
                        Text("已过期 😢")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.6, blue: 0.6))
                            )
                    } else if item.isExpiringSoon {
                        Text("快过期啦 ⏰")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                            )
                    }
                }
                
                // 显示特有信息
                if let info = getItemSpecificInfo() {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            }
            
            Spacer()
            
            // 衣柜中的衣服显示特殊图标
            if isClothingInWardrobe {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 0.85, green: 0.7, blue: 0.9))
                    .font(.title3)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .font(.caption)
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
                            isClothingInWardrobe ? 
                            Color(red: 0.85, green: 0.7, blue: 0.9).opacity(0.3) : 
                            Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                            lineWidth: 1
                        )
                        )
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
        VStack(spacing: 24) {
            ZStack {
                Circle()
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
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
                
                Image(systemName: "heart.circle")
                .font(.system(size: 50))
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
            }
            
            VStack(spacing: 12) {
                Text("还没有收藏任何宝贝呢 💕")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text("点击右上角的爱心按钮来添加第一个物品吧～")
                    .font(.body)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.all, 30)
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