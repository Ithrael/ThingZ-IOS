import Foundation
import SwiftUI

// 衣物特有属性
struct ClothingProperties: Codable {
    var clothingType: ClothingType
    var season: Season
    var color: String
    var material: String
    var brand: String
    
    init(clothingType: ClothingType = .top, season: Season = .allSeasons, color: String = "", material: String = "", brand: String = "") {
        self.clothingType = clothingType
        self.season = season
        self.color = color
        self.material = material
        self.brand = brand
    }
}

// 食品特有属性
struct FoodProperties: Codable {
    var expirationDate: Date
    var quantity: Int
    var unit: String
    var foodType: FoodType
    var storageCondition: String
    
    init(expirationDate: Date = Date(), quantity: Int = 1, unit: String = "", foodType: FoodType = .fresh, storageCondition: String = "") {
        self.expirationDate = expirationDate
        self.quantity = quantity
        self.unit = unit
        self.foodType = foodType
        self.storageCondition = storageCondition
    }
    
    var daysUntilExpiration: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: expirationDate)
        return components.day ?? 0
    }
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
    
    var isExpiringSoon: Bool {
        return daysUntilExpiration <= 7 && !isExpired
    }
}

// 化妆品特有属性
struct CosmeticsProperties: Codable {
    var cosmeticsType: CosmeticsType
    var openedDate: Date?
    var shelfLifeAfterOpening: Int // 开封后保质期（月）
    var brand: String
    
    init(cosmeticsType: CosmeticsType = .skincare, openedDate: Date? = nil, shelfLifeAfterOpening: Int = 12, brand: String = "") {
        self.cosmeticsType = cosmeticsType
        self.openedDate = openedDate
        self.shelfLifeAfterOpening = shelfLifeAfterOpening
        self.brand = brand
    }
    
    var expirationDate: Date? {
        guard let openedDate = openedDate else { return nil }
        return Calendar.current.date(byAdding: .month, value: shelfLifeAfterOpening, to: openedDate)
    }
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
    
    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: expirationDate)
        let daysUntilExpiration = components.day ?? 0
        return daysUntilExpiration <= 30 && !isExpired
    }
}

// 杂物特有属性
struct MiscellaneousProperties: Codable {
    var category: String
    var brand: String
    var model: String
    var purchaseDate: Date?
    
    init(category: String = "", brand: String = "", model: String = "", purchaseDate: Date? = nil) {
        self.category = category
        self.brand = brand
        self.model = model
        self.purchaseDate = purchaseDate
    }
}

// 物品数据模型
struct Item: Identifiable, Codable {
    let id = UUID()
    var name: String
    var type: ItemType
    var imageData: Data?
    var notes: String
    var containerId: UUID?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 特有属性
    var clothingProperties: ClothingProperties?
    var foodProperties: FoodProperties?
    var cosmeticsProperties: CosmeticsProperties?
    var miscellaneousProperties: MiscellaneousProperties?
    
    // 计算属性
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    var isExpired: Bool {
        switch type {
        case .food:
            return foodProperties?.isExpired ?? false
        case .cosmetics:
            return cosmeticsProperties?.isExpired ?? false
        default:
            return false
        }
    }
    
    var isExpiringSoon: Bool {
        switch type {
        case .food:
            return foodProperties?.isExpiringSoon ?? false
        case .cosmetics:
            return cosmeticsProperties?.isExpiringSoon ?? false
        default:
            return false
        }
    }
    
    // 构造函数
    init(name: String, type: ItemType, imageData: Data? = nil, notes: String = "", containerId: UUID? = nil) {
        self.name = name
        self.type = type
        self.imageData = imageData
        self.notes = notes
        self.containerId = containerId
        
        // 根据类型初始化特有属性
        switch type {
        case .clothing:
            self.clothingProperties = ClothingProperties()
        case .food:
            self.foodProperties = FoodProperties()
        case .cosmetics:
            self.cosmeticsProperties = CosmeticsProperties()
        case .miscellaneous:
            self.miscellaneousProperties = MiscellaneousProperties()
        }
    }
    
    // 更新方法
    mutating func updateInfo(name: String? = nil, notes: String? = nil, imageData: Data? = nil, containerId: UUID? = nil) {
        if let name = name { self.name = name }
        if let notes = notes { self.notes = notes }
        if let imageData = imageData { self.imageData = imageData }
        if let containerId = containerId { self.containerId = containerId }
        self.updatedAt = Date()
    }
    
    // 更新特有属性
    mutating func updateClothingProperties(_ properties: ClothingProperties) {
        self.clothingProperties = properties
        self.updatedAt = Date()
    }
    
    mutating func updateFoodProperties(_ properties: FoodProperties) {
        self.foodProperties = properties
        self.updatedAt = Date()
    }
    
    mutating func updateCosmeticsProperties(_ properties: CosmeticsProperties) {
        self.cosmeticsProperties = properties
        self.updatedAt = Date()
    }
    
    mutating func updateMiscellaneousProperties(_ properties: MiscellaneousProperties) {
        self.miscellaneousProperties = properties
        self.updatedAt = Date()
    }
} 