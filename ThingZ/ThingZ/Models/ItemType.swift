import Foundation

// 物品类型枚举
enum ItemType: String, CaseIterable, Identifiable, Codable {
    case clothing = "clothing"
    case food = "food"
    case cosmetics = "cosmetics"
    case miscellaneous = "miscellaneous"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .clothing: return "衣物"
        case .food: return "食品"
        case .cosmetics: return "化妆品"
        case .miscellaneous: return "杂物"
        }
    }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .food: return "fork.knife"
        case .cosmetics: return "paintbrush"
        case .miscellaneous: return "archivebox"
        }
    }
}

// 容器类型枚举
enum ContainerType: String, CaseIterable, Identifiable, Codable {
    case wardrobe = "wardrobe"
    case refrigerator = "refrigerator"
    case drawer = "drawer"
    case cabinet = "cabinet"
    case box = "box"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .wardrobe: return "衣柜"
        case .refrigerator: return "冰箱"
        case .drawer: return "抽屉"
        case .cabinet: return "储物柜"
        case .box: return "收纳盒"
        }
    }
    
    var icon: String {
        switch self {
        case .wardrobe: return "cabinet"
        case .refrigerator: return "refrigerator"
        case .drawer: return "archivebox"
        case .cabinet: return "cabinet.fill"
        case .box: return "shippingbox"
        }
    }
}

// 衣物子类型
enum ClothingType: String, CaseIterable, Identifiable, Codable {
    case top = "top"
    case bottom = "bottom"
    case dress = "dress"
    case outerwear = "outerwear"
    case underwear = "underwear"
    case shoes = "shoes"
    case accessories = "accessories"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .top: return "上衣"
        case .bottom: return "裤子"
        case .dress: return "裙子"
        case .outerwear: return "外套"
        case .underwear: return "内衣"
        case .shoes: return "鞋子"
        case .accessories: return "配饰"
        }
    }
}

// 季节类型
enum Season: String, CaseIterable, Identifiable, Codable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    case allSeasons = "all_seasons"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .spring: return "春季"
        case .summer: return "夏季"
        case .autumn: return "秋季"
        case .winter: return "冬季"
        case .allSeasons: return "四季"
        }
    }
}

// 食品子类型
enum FoodType: String, CaseIterable, Identifiable, Codable {
    case fresh = "fresh"
    case frozen = "frozen"
    case canned = "canned"
    case snacks = "snacks"
    case beverages = "beverages"
    case condiments = "condiments"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .fresh: return "生鲜"
        case .frozen: return "冷冻"
        case .canned: return "罐头"
        case .snacks: return "零食"
        case .beverages: return "饮料"
        case .condiments: return "调料"
        }
    }
}

// 化妆品子类型
enum CosmeticsType: String, CaseIterable, Identifiable, Codable {
    case skincare = "skincare"
    case makeup = "makeup"
    case fragrance = "fragrance"
    case haircare = "haircare"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .skincare: return "护肤品"
        case .makeup: return "彩妆"
        case .fragrance: return "香水"
        case .haircare: return "护发"
        }
    }
} 