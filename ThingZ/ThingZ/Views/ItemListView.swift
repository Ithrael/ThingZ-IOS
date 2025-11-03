import SwiftUI

struct ItemListView: View {
    @StateObject private var viewModel = ItemListViewModel()
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var showingItemDetail = false
    @State private var selectedItem: APIItem?
    @State private var sortBy: SortOption = .name
    @State private var filterBy: FilterOption = .all
    @EnvironmentObject var dataManager: DataManager

    var filteredItems: [APIItem] {
        var filtered = viewModel.items

        // 搜索过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 类型过滤
        switch filterBy {
        case .food:
            filtered = filtered.filter { $0.category == "食品" }
        case .clothing:
            filtered = filtered.filter { $0.category == "服饰" }
        case .cosmetics:
            filtered = filtered.filter { $0.category == "化妆品" }
        case .miscellaneous:
            filtered = filtered.filter { $0.category == "杂物" }
        case .all:
            break
        }

        // 排序
        switch sortBy {
        case .name:
            return filtered.sorted(by: { $0.name < $1.name })
        case .type:
            return filtered.sorted(by: { $0.category < $1.category })
        case .dateAdded:
            return filtered.sorted(by: { $0.createdAt > $1.createdAt })
        case .expiration:
            return filtered.sorted { item1, item2 in
                if let exp1 = item1.expirationDate, let exp2 = item2.expirationDate {
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
                
                // Loading状态
                if viewModel.isLoading && viewModel.items.isEmpty {
                    VStack {
                        ProgressView("加载中...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // 错误状态
                else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
                        Text(errorMessage)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                        Button("重试") {
                            Task {
                                await viewModel.loadItems(keyword: searchText.isEmpty ? nil : searchText)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 1.0, green: 0.75, blue: 0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 50)
                }
                // 物品列表
                else if filteredItems.isEmpty {
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
                                    APIItemRowView(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                                }

                                // 加载更多指示器
                                if viewModel.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                                        Text("加载更多...")
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                        Spacer()
                                    }
                                    .padding()
                                } else if viewModel.hasMore {
                                    // 加载更多触发器
                                    Color.clear
                                        .frame(height: 10)
                                        .onAppear {
                                            Task {
                                                await viewModel.loadMore(keyword: searchText.isEmpty ? nil : searchText)
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                    }
                    .refreshable {
                        await viewModel.refresh(keyword: searchText.isEmpty ? nil : searchText)
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
                    APIItemDetailView(item: selectedItem)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadItems()
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                // 搜索时重新加载
                if newValue.isEmpty || newValue.count >= 2 {
                    await viewModel.loadItems(keyword: newValue.isEmpty ? nil : newValue)
                }
            }
        }
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
                
                // 显示容器信息 (API items use String containerId, not UUID)
                // TODO: Consider using API to fetch container name instead of local lookup
                
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

// API物品行视图
struct APIItemRowView: View {
    let item: APIItem
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        HStack(spacing: 16) {
            // 物品图片或图标
            ZStack {
                if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: categoryIcon(for: item.category))
                                .font(.title2)
                                .foregroundColor(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.82, blue: 0.86),
                                    Color(red: 1.0, green: 0.75, blue: 0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        .overlay(
                            Image(systemName: categoryIcon(for: item.category))
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))

                // 显示容器信息 (API items use String containerId, not UUID)
                // TODO: Consider using API to fetch container name instead of local lookup

                HStack {
                    Text(item.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))

                    Spacer()

                    // 状态显示
                    if item.status == "TAKEN_OUT" {
                        Text("已取出")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.6, green: 0.8, blue: 1.0))
                            )
                    }
                }

                // 显示过期日期
                if let expirationDate = item.expirationDate {
                    Text("到期：\(expirationDate)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                .font(.caption)
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
                            Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "食品":
            return "fork.knife"
        case "服饰":
            return "tshirt"
        case "化妆品":
            return "paintbrush"
        case "杂物":
            return "square.grid.2x2"
        default:
            return "cube.box"
        }
    }
}

// API物品详情视图（临时简化版）
struct APIItemDetailView: View {
    let item: APIItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 图片
                    if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxHeight: 300)
                        .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(item.name)
                            .font(.title)
                            .fontWeight(.bold)

                        if let description = item.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        DetailRow(title: "分类", value: item.category)
                        DetailRow(title: "状态", value: item.status)

                        if let quantity = item.quantity, let unit = item.unit {
                            DetailRow(title: "数量", value: "\(quantity) \(unit)")
                        }

                        if let brand = item.brand {
                            DetailRow(title: "品牌", value: brand)
                        }

                        if let price = item.price {
                            DetailRow(title: "价格", value: String(format: "¥%.2f", price))
                        }

                        if let expirationDate = item.expirationDate {
                            DetailRow(title: "过期日期", value: expirationDate)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("物品详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
            .environmentObject(DataManager.shared)
    }
} 