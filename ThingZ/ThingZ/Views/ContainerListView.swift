import SwiftUI

struct ContainerListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddContainer = false
    @State private var selectedContainer: Container?
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.containers.isEmpty {
                    ContainerEmptyStateView(
                        title: "暂无容器",
                        message: "点击右上角按钮添加第一个容器",
                        iconName: "archivebox"
                    )
                } else {
                    ForEach(dataManager.containers) { container in
                        ContainerRowView(container: container)
                            .onTapGesture {
                                selectedContainer = container
                            }
                    }
                    .onDelete(perform: deleteContainers)
                }
            }
            .navigationTitle("我的容器")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContainer = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContainer) {
                AddContainerView()
            }
            .sheet(item: $selectedContainer) { container in
                ContainerDetailView(container: container)
            }
        }
        .onAppear {
            // 如果是第一次使用，加载示例数据
            if dataManager.containers.isEmpty {
                dataManager.loadSampleData()
            }
        }
    }
    
    private func deleteContainers(offsets: IndexSet) {
        for index in offsets {
            let container = dataManager.containers[index]
            dataManager.deleteContainer(container)
        }
    }
}

// 容器行视图
struct ContainerRowView: View {
    let container: Container
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            // 容器图标
            Image(systemName: container.type.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(container.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(container.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(container.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    let itemCount = dataManager.getItems(inContainer: container.id).count
                    Text("\(itemCount)/\(container.capacity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 容量进度条
            VStack {
                let itemCount = dataManager.getItems(inContainer: container.id).count
                let utilization = container.capacity > 0 ? Double(itemCount) / Double(container.capacity) : 0
                
                CircularProgressView(progress: utilization)
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.vertical, 4)
    }
}

// 圆形进度条
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress > 0.8 ? Color.red : progress > 0.6 ? Color.orange : Color.green,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

// 空状态视图
struct ContainerEmptyStateView: View {
    let title: String
    let message: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContainerListView()
        .environmentObject(DataManager.shared)
} 