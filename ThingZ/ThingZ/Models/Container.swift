import Foundation
import SwiftUI

// 容器数据模型
struct Container: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var type: ContainerType
    var location: String
    var capacity: Int
    var coverImageData: Data?
    var items: [Item] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 实现Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 实现Equatable协议（Hashable依赖）
    static func == (lhs: Container, rhs: Container) -> Bool {
        lhs.id == rhs.id
    }
    
    // 计算属性
    var currentItemCount: Int {
        items.count
    }
    
    var capacityUtilization: Double {
        guard capacity > 0 else { return 0 }
        return Double(currentItemCount) / Double(capacity)
    }
    
    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }
    
    // 构造函数
    init(name: String, type: ContainerType, location: String, capacity: Int = 50, coverImageData: Data? = nil) {
        self.name = name
        self.type = type
        self.location = location
        self.capacity = capacity
        self.coverImageData = coverImageData
    }
    
    // 更新方法
    mutating func updateInfo(name: String? = nil, location: String? = nil, capacity: Int? = nil, coverImageData: Data? = nil) {
        if let name = name { self.name = name }
        if let location = location { self.location = location }
        if let capacity = capacity { self.capacity = capacity }
        if let coverImageData = coverImageData { self.coverImageData = coverImageData }
        self.updatedAt = Date()
    }
    
    // 添加物品
    mutating func addItem(_ item: Item) {
        items.append(item)
        updatedAt = Date()
    }
    
    // 移除物品
    mutating func removeItem(withId id: UUID) {
        items.removeAll { $0.id == id }
        updatedAt = Date()
    }
    
    // 更新物品
    mutating func updateItem(_ updatedItem: Item) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            updatedAt = Date()
        }
    }
    
    // 获取特定类型的物品
    func getItems(ofType type: ItemType) -> [Item] {
        return items.filter { $0.type == type }
    }
} 