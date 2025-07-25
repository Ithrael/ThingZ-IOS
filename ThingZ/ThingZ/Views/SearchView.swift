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
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
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
            }
            .navigationTitle("寻找宝贝 🔍")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    @Binding var selectedScope: Int
    let scopes: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            // 搜索输入框
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                HStack(spacing: 12) {
                    Image(systemName: "heart.magnifyingglass")
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                        .font(.title3)
                    
                    TextField("搜索你的宝贝物品和小窝...", text: $text)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    if !text.isEmpty {
                        Button("✨") {
                            text = ""
                        }
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 16)
            
            // 搜索范围选择
            HStack(spacing: 12) {
                ForEach(0..<scopes.count, id: \.self) { index in
                    Button(action: {
                        selectedScope = index
                    }) {
                        Text(scopes[index])
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedScope == index ? .white : Color(red: 0.6, green: 0.4, blue: 0.3))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedScope == index ? 
                                          Color(red: 1.0, green: 0.75, blue: 0.8) : 
                                          Color.white.opacity(0.8))
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                        radius: selectedScope == index ? 8 : 4,
                                        x: 0,
                                        y: selectedScope == index ? 4 : 2
                                    )
                            )
                    }
                    .scaleEffect(selectedScope == index ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selectedScope)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
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
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color(red: 0.8, green: 0.6, blue: 0.2) : Color(red: 0.6, green: 0.4, blue: 0.3))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 1.0, green: 0.9, blue: 0.7) : Color.white.opacity(0.8))
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                            radius: isSelected ? 6 : 3,
                            x: 0,
                            y: isSelected ? 3 : 1
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// 空搜索状态
struct EmptySearchView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 搜索提示
                VStack(spacing: 20) {
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
                            .frame(width: 100, height: 100)
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                radius: 15,
                                x: 0,
                                y: 8
                            )
                        
                        Image(systemName: "heart.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    }
                    
                    VStack(spacing: 8) {
                        Text("开始寻找你的宝贝吧 ✨")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                        
                        Text("输入关键词来搜索物品或容器")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 30)
                
                // 统计信息
                VStack(spacing: 16) {
                    Text("数据概览 📊")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "总容器", value: "\(dataManager.totalContainers)", icon: "archivebox.fill", color: Color(red: 1.0, green: 0.75, blue: 0.8))
                        StatCard(title: "总物品", value: "\(dataManager.totalItems)", icon: "heart.fill", color: Color(red: 1.0, green: 0.8, blue: 0.4))
                        StatCard(title: "即将过期", value: "\(dataManager.getExpiringSoonItems().count)", icon: "clock.badge", color: Color(red: 1.0, green: 0.8, blue: 0.4))
                        StatCard(title: "已过期", value: "\(dataManager.getExpiredItems().count)", icon: "exclamationmark.triangle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.6))
                    }
                }
                .padding(.horizontal, 16)
                
                // 最近添加的物品
                if !dataManager.items.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("最近添加 🆕")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Array(dataManager.items.sorted(by: { $0.createdAt > $1.createdAt }).prefix(3)), id: \.id) { item in
                                RecentItemRow(item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
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
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
        }
        .padding(.all, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.8))
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
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
        HStack(spacing: 16) {
            ZStack {
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
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                
                Image(systemName: item.type.icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                if let container = container {
                    Text("住在：\(container.name) 🏠")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
                
                Text(item.type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                    )
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            }
            
            Spacer()
            
            Text(RelativeDateTimeFormatter().localizedString(for: item.createdAt, relativeTo: Date()))
                .font(.caption)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
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
}

// 搜索结果视图
struct SearchResultsView: View {
    let items: [Item]
    let containers: [Container]
    let showContainers: Bool
    let showItems: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if showContainers && !containers.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("容器 (\(containers.count))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        ForEach(containers, id: \.id) { container in
                            NavigationLink(destination: ContainerDetailView(container: container)) {
                                ContainerSearchRow(container: container)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                if showItems && !items.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("物品 (\(items.count))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        ForEach(items, id: \.id) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemSearchRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                if (showContainers && containers.isEmpty) && (showItems && items.isEmpty) {
                    VStack(spacing: 20) {
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
                                .frame(width: 80, height: 80)
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                            
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 35))
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("没有找到相关结果 😢")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            
                            Text("试试换个关键词吧～")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                        }
                    }
                    .padding(.top, 50)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
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
        HStack(spacing: 16) {
            ZStack {
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
                
                Image(systemName: container.type.icon)
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(container.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Text(container.location)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                
                HStack(spacing: 8) {
                    Text(container.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    Text("\(itemCount)/\(container.capacity)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            }
            
            Spacer()
            
            VStack {
                let utilization = container.capacity > 0 ? Double(itemCount) / Double(container.capacity) : 0
                
                ZStack {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.9, blue: 0.95), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: utilization)
                        .stroke(
                            utilization > 0.8 ? Color(red: 1.0, green: 0.6, blue: 0.6) :
                            utilization > 0.6 ? Color(red: 1.0, green: 0.8, blue: 0.4) :
                            Color(red: 0.7, green: 0.9, blue: 0.7),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: utilization)
                }
                .frame(width: 30, height: 30)
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
        )
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
        HStack(spacing: 16) {
            ZStack {
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
                
                Image(systemName: item.type.icon)
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                if let container = container {
                    Text("住在：\(container.name) 🏠")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
                
                HStack(spacing: 8) {
                    Text(item.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    if item.isExpired {
                        Text("已过期 😢")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.6, blue: 0.6))
                            )
                            .foregroundColor(.white)
                    } else if item.isExpiringSoon {
                        Text("快过期啦 ⏰")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                            )
                            .foregroundColor(.white)
                    }
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
        )
    }
}

#Preview {
    SearchView()
        .environmentObject(DataManager.shared)
} 