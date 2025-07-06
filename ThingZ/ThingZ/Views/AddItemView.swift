import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var selectedType = ItemType.clothing
    @State private var selectedContainer: Container?
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    // 衣物属性
    @State private var clothingType = ClothingType.top
    @State private var season = Season.allSeasons
    @State private var color = ""
    @State private var material = ""
    @State private var clothingBrand = ""
    
    // 食品属性
    @State private var expirationDate = Date()
    @State private var quantity = 1
    @State private var unit = ""
    @State private var foodType = FoodType.fresh
    @State private var storageCondition = ""
    
    // 化妆品属性
    @State private var cosmeticsType = CosmeticsType.skincare
    @State private var openedDate: Date?
    @State private var shelfLifeAfterOpening = 12
    @State private var cosmeticsBrand = ""
    @State private var hasOpenedDate = false
    
    // 杂物属性
    @State private var category = ""
    @State private var miscBrand = ""
    @State private var model = ""
    @State private var purchaseDate: Date?
    @State private var hasPurchaseDate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("物品名称", text: $name)
                    
                    Picker("物品类型", selection: $selectedType) {
                        ForEach(ItemType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    
                    Picker("所属容器", selection: $selectedContainer) {
                        Text("请选择容器").tag(nil as Container?)
                        ForEach(dataManager.containers) { container in
                            Text(container.name).tag(container as Container?)
                        }
                    }
                    
                    TextField("备注", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("物品图片")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("点击添加图片")
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 100)
                        }
                    }
                }
                
                // 根据类型显示特有属性
                switch selectedType {
                case .clothing:
                    ClothingPropertiesSection(
                        clothingType: $clothingType,
                        season: $season,
                        color: $color,
                        material: $material,
                        brand: $clothingBrand
                    )
                case .food:
                    FoodPropertiesSection(
                        expirationDate: $expirationDate,
                        quantity: $quantity,
                        unit: $unit,
                        foodType: $foodType,
                        storageCondition: $storageCondition
                    )
                case .cosmetics:
                    CosmeticsPropertiesSection(
                        cosmeticsType: $cosmeticsType,
                        openedDate: $openedDate,
                        shelfLifeAfterOpening: $shelfLifeAfterOpening,
                        brand: $cosmeticsBrand,
                        hasOpenedDate: $hasOpenedDate
                    )
                case .miscellaneous:
                    MiscellaneousPropertiesSection(
                        category: $category,
                        brand: $miscBrand,
                        model: $model,
                        purchaseDate: $purchaseDate,
                        hasPurchaseDate: $hasPurchaseDate
                    )
                }
            }
            .navigationTitle("添加物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || selectedContainer == nil)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveItem() {
        guard let container = selectedContainer else { return }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        var item = Item(
            name: name,
            type: selectedType,
            imageData: imageData,
            notes: notes,
            containerId: container.id
        )
        
        // 根据类型设置特有属性
        switch selectedType {
        case .clothing:
            let properties = ClothingProperties(
                clothingType: clothingType,
                season: season,
                color: color,
                material: material,
                brand: clothingBrand
            )
            item.updateClothingProperties(properties)
            
        case .food:
            let properties = FoodProperties(
                expirationDate: expirationDate,
                quantity: quantity,
                unit: unit,
                foodType: foodType,
                storageCondition: storageCondition
            )
            item.updateFoodProperties(properties)
            
        case .cosmetics:
            let properties = CosmeticsProperties(
                cosmeticsType: cosmeticsType,
                openedDate: hasOpenedDate ? openedDate : nil,
                shelfLifeAfterOpening: shelfLifeAfterOpening,
                brand: cosmeticsBrand
            )
            item.updateCosmeticsProperties(properties)
            
        case .miscellaneous:
            let properties = MiscellaneousProperties(
                category: category,
                brand: miscBrand,
                model: model,
                purchaseDate: hasPurchaseDate ? purchaseDate : nil
            )
            item.updateMiscellaneousProperties(properties)
        }
        
        dataManager.addItem(item)
        presentationMode.wrappedValue.dismiss()
    }
}

// 衣物特有属性部分
struct ClothingPropertiesSection: View {
    @Binding var clothingType: ClothingType
    @Binding var season: Season
    @Binding var color: String
    @Binding var material: String
    @Binding var brand: String
    
    var body: some View {
        Section(header: Text("衣物属性")) {
            Picker("衣物类型", selection: $clothingType) {
                ForEach(ClothingType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            Picker("季节", selection: $season) {
                ForEach(Season.allCases) { season in
                    Text(season.displayName).tag(season)
                }
            }
            
            TextField("颜色", text: $color)
            TextField("材质", text: $material)
            TextField("品牌", text: $brand)
        }
    }
}

// 食品特有属性部分
struct FoodPropertiesSection: View {
    @Binding var expirationDate: Date
    @Binding var quantity: Int
    @Binding var unit: String
    @Binding var foodType: FoodType
    @Binding var storageCondition: String
    
    var body: some View {
        Section(header: Text("食品属性")) {
            DatePicker("保质期", selection: $expirationDate, displayedComponents: .date)
            
            Stepper("数量: \(quantity)", value: $quantity, in: 1...1000)
            
            TextField("单位", text: $unit)
            
            Picker("食品类型", selection: $foodType) {
                ForEach(FoodType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            TextField("存放条件", text: $storageCondition)
        }
    }
}

// 化妆品特有属性部分
struct CosmeticsPropertiesSection: View {
    @Binding var cosmeticsType: CosmeticsType
    @Binding var openedDate: Date?
    @Binding var shelfLifeAfterOpening: Int
    @Binding var brand: String
    @Binding var hasOpenedDate: Bool
    
    var body: some View {
        Section(header: Text("化妆品属性")) {
            Picker("化妆品类型", selection: $cosmeticsType) {
                ForEach(CosmeticsType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            Toggle("已开封", isOn: $hasOpenedDate)
            
            if hasOpenedDate {
                DatePicker("开封日期", selection: Binding(
                    get: { openedDate ?? Date() },
                    set: { openedDate = $0 }
                ), displayedComponents: .date)
                
                Stepper("开封后保质期: \(shelfLifeAfterOpening)个月", value: $shelfLifeAfterOpening, in: 1...36)
            }
            
            TextField("品牌", text: $brand)
        }
    }
}

// 杂物特有属性部分
struct MiscellaneousPropertiesSection: View {
    @Binding var category: String
    @Binding var brand: String
    @Binding var model: String
    @Binding var purchaseDate: Date?
    @Binding var hasPurchaseDate: Bool
    
    var body: some View {
        Section(header: Text("杂物属性")) {
            TextField("类别", text: $category)
            TextField("品牌", text: $brand)
            TextField("型号", text: $model)
            
            Toggle("设置购买日期", isOn: $hasPurchaseDate)
            
            if hasPurchaseDate {
                DatePicker("购买日期", selection: Binding(
                    get: { purchaseDate ?? Date() },
                    set: { purchaseDate = $0 }
                ), displayedComponents: .date)
            }
        }
    }
}



#Preview {
    AddItemView()
        .environmentObject(DataManager.shared)
} 