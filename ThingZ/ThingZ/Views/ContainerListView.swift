import SwiftUI

struct ContainerListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddContainer = false
    @State private var selectedContainer: Container?
    
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
                    LazyVStack(spacing: 16) {
                if dataManager.containers.isEmpty {
                    ContainerEmptyStateView(
                                title: "还没有小容器呢 🥺",
                                message: "点击右上角的小爱心来添加第一个容器吧～",
                                iconName: "heart.circle"
                    )
                            .padding(.top, 50)
                } else {
                    ForEach(dataManager.containers) { container in
                        ContainerRowView(container: container)
                            .onTapGesture {
                                selectedContainer = container
                            }
                                    .contextMenu {
                                        Button(action: {
                                            dataManager.deleteContainer(container)
                                        }) {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("我的小窝 🏠")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContainer = true
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                            .font(.title2)
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
}

// 容器行视图
struct ContainerRowView: View {
    let container: Container
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack(spacing: 16) {
            // 容器图标
            ZStack {
                Circle()
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
                .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(container.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1)) // 深棕色
                
                Text(container.location)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                
                HStack {
                    Text(container.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    Spacer()
                    
                    let itemCount = dataManager.getItems(inContainer: container.id).count
                    Text("\(itemCount)/\(container.capacity)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            }
            
            Spacer()
            
            // 容量进度条
            VStack {
                let itemCount = dataManager.getItems(inContainer: container.id).count
                let utilization = container.capacity > 0 ? Double(itemCount) / Double(container.capacity) : 0
                
                CircularProgressView(progress: utilization)
                    .frame(width: 35, height: 35)
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
    }
}

// 圆形进度条
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 1.0, green: 0.9, blue: 0.95), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            progress > 0.8 ? Color(red: 1.0, green: 0.6, blue: 0.6) : // 温柔的红色
                            progress > 0.6 ? Color(red: 1.0, green: 0.8, blue: 0.4) : // 温暖的橙色
                            Color(red: 0.7, green: 0.9, blue: 0.7) // 清新的绿色
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
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
                
            Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
            }
            
            VStack(spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text(message)
                .font(.body)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.all, 30)
    }
}

#Preview {
    ContainerListView()
        .environmentObject(DataManager.shared)
} 