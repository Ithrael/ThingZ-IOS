import SwiftUI

struct ContainerDetailView: View {
    let container: Container
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    
    var items: [Item] {
        dataManager.getItems(inContainer: container.id)
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
                        // 容器基本信息
                        VStack(spacing: 20) {
                            // 容器图标和名称
                            VStack(spacing: 16) {
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
                                        .frame(width: 100, height: 100)
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                            radius: 15,
                                            x: 0,
                                            y: 8
                                        )
                                    
                                    Image(systemName: container.type.icon)
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(spacing: 8) {
                                    Text(container.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    
                                    Text(container.type.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                                        )
                                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                                }
                            }
                            
                            // 基本信息卡片
                            VStack(spacing: 16) {
                                HStack(spacing: 20) {
                                    VStack(spacing: 8) {
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
                                                .frame(width: 50, height: 50)
                                                .shadow(
                                                    color: Color(red: 0.7, green: 0.9, blue: 0.9).opacity(0.3),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                            
                                            Image(systemName: "location.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(container.location)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Text("位置")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 1.0, green: 0.8, blue: 0.4),
                                                            Color(red: 1.0, green: 0.7, blue: 0.3)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 50, height: 50)
                                                .shadow(
                                                    color: Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                            
                                            Image(systemName: "archivebox.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text("\(items.count)/\(container.capacity)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Text("容量")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    }
                                }
                                
                                // 容量进度条
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("容量使用情况")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        Spacer()
                                        let utilization = container.capacity > 0 ? Double(items.count) / Double(container.capacity) : 0
                                        Text("\(Int(utilization * 100))%")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    }
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 1.0, green: 0.9, blue: 0.95))
                                            .frame(height: 12)
                                        
                                        let utilization = container.capacity > 0 ? Double(items.count) / Double(container.capacity) : 0
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        utilization > 0.8 ? Color(red: 1.0, green: 0.6, blue: 0.6) :
                                                        utilization > 0.6 ? Color(red: 1.0, green: 0.8, blue: 0.4) :
                                                        Color(red: 0.7, green: 0.9, blue: 0.7)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: max(0, CGFloat(utilization) * UIScreen.main.bounds.width * 0.8), height: 12)
                                            .animation(.easeInOut(duration: 1.0), value: utilization)
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 容器内物品
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("容器内物品 📦")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("(\(items.count))")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            if items.isEmpty {
                                ContainerEmptyStateView(
                                    title: "小窝还是空的呢 🥺",
                                    message: "快去添加一些宝贝物品吧～",
                                    iconName: "heart.circle"
                                )
                                .padding(.horizontal, 20)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(items) { item in
                                        ContainerItemRowView(item: item)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("小窝详情 🏠")
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
}

// 容器内物品行视图
struct ContainerItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 16) {
            // 物品图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
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
                
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: item.type.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
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
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                if item.isExpired {
                    Text("过期")
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
                    Text("快过期")
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
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .font(.caption)
            }
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

#Preview {
    let sampleContainer = Container(name: "主卧衣柜", type: .wardrobe, location: "主卧", capacity: 50)
    return ContainerDetailView(container: sampleContainer)
        .environmentObject(DataManager.shared)
} 