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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 容器基本信息
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: container.type.icon)
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(container.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(container.type.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Label(container.location, systemImage: "location")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Label("容量: \(items.count)/\(container.capacity)", systemImage: "archivebox")
                                .foregroundColor(.secondary)
                        }
                        
                        // 容量进度条
                        ProgressView(value: Double(items.count), total: Double(container.capacity))
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 容器内物品
                    VStack(alignment: .leading, spacing: 12) {
                        Text("容器内物品 (\(items.count))")
                            .font(.headline)
                        
                        if items.isEmpty {
                            ContainerEmptyStateView(
                                title: "容器为空",
                                message: "还没有物品放入这个容器",
                                iconName: "archivebox"
                            )
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(items) { item in
                                    ItemRowView(item: item)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("容器详情")
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
}

#Preview {
    let sampleContainer = Container(name: "主卧衣柜", type: .wardrobe, location: "主卧", capacity: 50)
    return ContainerDetailView(container: sampleContainer)
        .environmentObject(DataManager.shared)
} 