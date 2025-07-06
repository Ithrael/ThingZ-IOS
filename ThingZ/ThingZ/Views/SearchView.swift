import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedScope = 0
    @State private var selectedItemType: ItemType? = nil
    
    let scopes = ["全部", "物品", "容器"]
    
    var searchResults: (items: [Item], containers: [Container]) {
        let filteredItems: [Item]
        let filteredContainers: [Container]
        
        if searchText.isEmpty {
            filteredItems = selectedItemType == nil ? dataManager.items : dataManager.getItems(ofType: selectedItemType!)
            filteredContainers = dataManager.containers
        } else {
            filteredItems = dataManager.searchItems(query: searchText)
            filteredContainers = dataManager.searchContainers(query: searchText)
        }
        
        return (
            items: selectedItemType == nil ? filteredItems : filteredItems.filter { $0.type == selectedItemType! },
            containers: filteredContainers
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText, selectedScope: $selectedScope, scopes: scopes)
                
                // 物品类型筛选
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "全部", isSelected: selectedItemType == nil) {
                            selectedItemType = nil
                        }
                        
                        ForEach(ItemType.allCases, id: \.self) { type in
                            FilterChip(title: type.displayName, isSelected: selectedItemType == type) {
                                selectedItemType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // 搜索结果
                if searchText.isEmpty && selectedItemType == nil {
                    EmptySearchView()
                } else {
                    SearchResultsView(
                        items: searchResults.items,
                        containers: searchResults.containers,
                        showContainers: selectedScope == 0 || selectedScope == 2,
                        showItems: selectedScope == 0 || selectedScope == 1
                    )
                }
                
                Spacer()
            }
            .navigationTitle("搜索")
        }
    }
}

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    @Binding var selectedScope: Int
    let scopes: [String]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("搜索物品或容器", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !text.isEmpty {
                    Button("清除") {
                        text = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            Picker("搜索范围", selection: $selectedScope) {
                ForEach(0..<scopes.count, id: \.self) { index in
                    Text(scopes[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

// 筛选标签
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// 空搜索状态
struct EmptySearchView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 搜索提示
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("输入关键词开始搜索")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("可以搜索物品名称、备注、属性等信息")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // 统计信息
                VStack(spacing: 16) {
                    Text("数据概览")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "总容器", value: "\(dataManager.totalContainers)", icon: "archivebox")
                        StatCard(title: "总物品", value: "\(dataManager.totalItems)", icon: "list.bullet")
                        StatCard(title: "即将过期", value: "\(dataManager.getExpiringSoonItems().count)", icon: "clock")
                        StatCard(title: "已过期", value: "\(dataManager.getExpiredItems().count)", icon: "exclamationmark.triangle")
                    }
                }
                .padding()
                
                // 最近添加的物品
                if !dataManager.items.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("最近添加")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(Array(dataManager.items.sorted(by: { $0.createdAt > $1.createdAt }).prefix(5)), id: \.id) { item in
                                RecentItemRow(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 最近物品行
struct RecentItemRow: View {
    let item: Item
    @EnvironmentObject var dataManager: DataManager
    
    var container: Container? {
        guard let containerId = item.containerId else { return nil }
        return dataManager.getContainer(withId: containerId)
    }
    
    var body: some View {
        HStack {
            Image(systemName: item.type.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let container = container {
                    Text("位于：\(container.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(RelativeDateTimeFormatter().localizedString(for: item.createdAt, relativeTo: Date()))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// 搜索结果视图
struct SearchResultsView: View {
    let items: [Item]
    let containers: [Container]
    let showContainers: Bool
    let showItems: Bool
    
    var body: some View {
        List {
            if showContainers && !containers.isEmpty {
                Section("容器 (\(containers.count))") {
                    ForEach(containers, id: \.id) { container in
                        NavigationLink(destination: ContainerDetailView(container: container)) {
                            ContainerSearchRow(container: container)
                        }
                    }
                }
            }
            
            if showItems && !items.isEmpty {
                Section("物品 (\(items.count))") {
                    ForEach(items, id: \.id) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            ItemSearchRow(item: item)
                        }
                    }
                }
            }
            
            if (showContainers && containers.isEmpty) && (showItems && items.isEmpty) {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("未找到相关结果")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

// 容器搜索行
struct ContainerSearchRow: View {
    let container: Container
    @EnvironmentObject var dataManager: DataManager
    
    var itemCount: Int {
        dataManager.getItems(inContainer: container.id).count
    }
    
    var body: some View {
        HStack {
            Image(systemName: container.type.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(container.name)
                    .font(.headline)
                
                Text("\(container.type.displayName) · \(container.location)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(itemCount)/\(container.capacity) 物品")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if container.capacityUtilization > 0.8 {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
            }
        }
    }
}

// 物品搜索行
struct ItemSearchRow: View {
    let item: Item
    @EnvironmentObject var dataManager: DataManager
    
    var container: Container? {
        guard let containerId = item.containerId else { return nil }
        return dataManager.getContainer(withId: containerId)
    }
    
    var body: some View {
        HStack {
            Image(systemName: item.type.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let container = container {
                    Text("位于：\(container.name)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                if item.isExpired {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                } else if item.isExpiringSoon {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(DataManager.shared)
} 