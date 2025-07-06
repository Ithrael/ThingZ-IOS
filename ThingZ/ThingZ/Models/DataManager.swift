import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var containers: [Container] = []
    @Published var items: [Item] = []
    
    static let shared = DataManager()
    
    private let containersKey = "StorageHelper_Containers"
    private let itemsKey = "StorageHelper_Items"
    
    private init() {
        loadData()
    }
    
    // MARK: - 数据持久化
    
    private func saveData() {
        saveContainers()
        saveItems()
    }
    
    private func loadData() {
        loadContainers()
        loadItems()
        // 数据加载完成后刷新提醒
        NotificationManager.shared.refreshAllReminders(for: items)
    }
    
    private func saveContainers() {
        if let encoded = try? JSONEncoder().encode(containers) {
            UserDefaults.standard.set(encoded, forKey: containersKey)
        }
    }
    
    private func loadContainers() {
        if let data = UserDefaults.standard.data(forKey: containersKey),
           let decoded = try? JSONDecoder().decode([Container].self, from: data) {
            containers = decoded
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
        }
    }
    
    // MARK: - 容器管理
    
    func addContainer(_ container: Container) {
        containers.append(container)
        saveData()
    }
    
    func updateContainer(_ container: Container) {
        if let index = containers.firstIndex(where: { $0.id == container.id }) {
            containers[index] = container
            saveData()
        }
    }
    
    func deleteContainer(_ container: Container) {
        // 取消容器中所有物品的提醒
        let itemsToDelete = items.filter { $0.containerId == container.id }
        for item in itemsToDelete {
            NotificationManager.shared.cancelReminders(for: item)
        }
        
        // 先删除容器中的所有物品
        items.removeAll { $0.containerId == container.id }
        // 再删除容器
        containers.removeAll { $0.id == container.id }
        saveData()
        
        // 刷新剩余物品的提醒
        NotificationManager.shared.refreshAllReminders(for: items)
    }
    
    func getContainer(withId id: UUID) -> Container? {
        return containers.first { $0.id == id }
    }
    
    func getContainers(ofType type: ContainerType) -> [Container] {
        return containers.filter { $0.type == type }
    }
    
    func getContainers(inLocation location: String) -> [Container] {
        return containers.filter { $0.location.lowercased().contains(location.lowercased()) }
    }
    
    // MARK: - 物品管理
    
    func addItem(_ item: Item) {
        items.append(item)
        saveData()
        // 刷新提醒
        NotificationManager.shared.refreshAllReminders(for: items)
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveData()
            // 刷新提醒
            NotificationManager.shared.refreshAllReminders(for: items)
        }
    }
    
    func deleteItem(_ item: Item) {
        // 取消该物品的提醒
        NotificationManager.shared.cancelReminders(for: item)
        items.removeAll { $0.id == item.id }
        saveData()
        // 刷新剩余物品的提醒
        NotificationManager.shared.refreshAllReminders(for: items)
    }
    
    func getItem(withId id: UUID) -> Item? {
        return items.first { $0.id == id }
    }
    
    func getItems(inContainer containerId: UUID) -> [Item] {
        return items.filter { $0.containerId == containerId }
    }
    
    func getItems(ofType type: ItemType) -> [Item] {
        return items.filter { $0.type == type }
    }
    
    func getItems(inContainer containerId: UUID, ofType type: ItemType) -> [Item] {
        return items.filter { $0.containerId == containerId && $0.type == type }
    }
    
    // MARK: - 搜索功能
    
    func searchItems(query: String) -> [Item] {
        guard !query.isEmpty else { return items }
        
        return items.filter { item in
            // 搜索物品名称
            if item.name.lowercased().contains(query.lowercased()) {
                return true
            }
            
            // 搜索备注
            if item.notes.lowercased().contains(query.lowercased()) {
                return true
            }
            
            // 根据类型搜索特有属性
            switch item.type {
            case .clothing:
                if let properties = item.clothingProperties {
                    return properties.color.lowercased().contains(query.lowercased()) ||
                           properties.brand.lowercased().contains(query.lowercased()) ||
                           properties.material.lowercased().contains(query.lowercased())
                }
            case .food:
                if let properties = item.foodProperties {
                    return properties.unit.lowercased().contains(query.lowercased()) ||
                           properties.storageCondition.lowercased().contains(query.lowercased())
                }
            case .cosmetics:
                if let properties = item.cosmeticsProperties {
                    return properties.brand.lowercased().contains(query.lowercased())
                }
            case .miscellaneous:
                if let properties = item.miscellaneousProperties {
                    return properties.category.lowercased().contains(query.lowercased()) ||
                           properties.brand.lowercased().contains(query.lowercased()) ||
                           properties.model.lowercased().contains(query.lowercased())
                }
            }
            
            return false
        }
    }
    
    func searchContainers(query: String) -> [Container] {
        guard !query.isEmpty else { return containers }
        
        return containers.filter { container in
            container.name.lowercased().contains(query.lowercased()) ||
            container.location.lowercased().contains(query.lowercased())
        }
    }
    
    // MARK: - 过期提醒
    
    func getExpiredItems() -> [Item] {
        return items.filter { $0.isExpired }
    }
    
    func getExpiringSoonItems() -> [Item] {
        return items.filter { $0.isExpiringSoon }
    }
    
    func getItemsNeedingReminders() -> [Item] {
        return items.filter { $0.isExpired || $0.isExpiringSoon }
    }
    
    // MARK: - 统计数据
    
    var totalContainers: Int {
        containers.count
    }
    
    var totalItems: Int {
        items.count
    }
    
    func getItemCount(ofType type: ItemType) -> Int {
        return items.filter { $0.type == type }.count
    }
    
    func getContainerCount(ofType type: ContainerType) -> Int {
        return containers.filter { $0.type == type }.count
    }
    
    // MARK: - 数据清理
    
    func clearAllData() {
        containers.removeAll()
        items.removeAll()
        UserDefaults.standard.removeObject(forKey: containersKey)
        UserDefaults.standard.removeObject(forKey: itemsKey)
    }
    
    // MARK: - 示例数据
    
    func loadSampleData() {
        // 创建示例容器
        let wardrobe = Container(name: "主卧衣柜", type: .wardrobe, location: "主卧", capacity: 50)
        let fridge = Container(name: "厨房冰箱", type: .refrigerator, location: "厨房", capacity: 30)
        let drawer = Container(name: "化妆台抽屉", type: .drawer, location: "主卧", capacity: 20)
        
        containers = [wardrobe, fridge, drawer]
        
        // 创建示例物品
        var tshirt = Item(name: "白色T恤", type: .clothing, containerId: wardrobe.id)
        tshirt.updateClothingProperties(ClothingProperties(clothingType: .top, season: .summer, color: "白色", material: "棉质", brand: "优衣库"))
        
        var milk = Item(name: "牛奶", type: .food, containerId: fridge.id)
        milk.updateFoodProperties(FoodProperties(expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(), quantity: 1, unit: "盒", foodType: .fresh, storageCondition: "冷藏"))
        
        var lipstick = Item(name: "口红", type: .cosmetics, containerId: drawer.id)
        lipstick.updateCosmeticsProperties(CosmeticsProperties(cosmeticsType: .makeup, openedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()), shelfLifeAfterOpening: 12, brand: "香奈儿"))
        
        items = [tshirt, milk, lipstick]
        
        saveData()
    }
} 