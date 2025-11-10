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
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false

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
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("保存") {
                            Task {
                                await saveItem()
                            }
                        }
                        .disabled(name.isEmpty || selectedContainer == nil)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                SharedImagePicker(selectedImage: $selectedImage)
            }
            .alert("错误", isPresented: $showingError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "未知错误")
            }
        }
    }

    private func saveItem() async {
        guard let container = selectedContainer else { return }

        isLoading = true
        errorMessage = nil

        do {
            // 1. 先上传图片（如果有）
            var imageUrl: String? = nil
            if let image = selectedImage {
                imageUrl = try await FileUploadService.shared.processAndUploadImage(
                    image,
                    type: .image
                )
            }

            // 2. 获取分类字符串
            let categoryString = getCategoryString(for: selectedType)

            // 3. 准备日期字符串
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let expirationDateString: String?
            let purchaseDateString: String?

            switch selectedType {
            case .food:
                expirationDateString = formatter.string(from: expirationDate)
                purchaseDateString = nil
            case .miscellaneous:
                expirationDateString = nil
                purchaseDateString = hasPurchaseDate && purchaseDate != nil ? formatter.string(from: purchaseDate!) : nil
            default:
                expirationDateString = nil
                purchaseDateString = nil
            }

            // 4. 准备品牌和型号
            let brandString: String?
            let modelString: String?
            switch selectedType {
            case .clothing:
                brandString = clothingBrand.isEmpty ? nil : clothingBrand
                modelString = nil
            case .cosmetics:
                brandString = cosmeticsBrand.isEmpty ? nil : cosmeticsBrand
                modelString = nil
            case .miscellaneous:
                brandString = miscBrand.isEmpty ? nil : miscBrand
                modelString = model.isEmpty ? nil : model
            default:
                brandString = nil
                modelString = nil
            }

            // 5. 组装CreateItemRequest
            let request = CreateItemRequest(
                name: name,
                category: categoryString,
                containerId: container.id.uuidString,
                quantity: selectedType == .food ? quantity : nil,
                unit: selectedType == .food && !unit.isEmpty ? unit : nil,
                imageUrl: imageUrl,
                description: notes.isEmpty ? nil : notes,
                purchaseDate: purchaseDateString,
                expirationDate: expirationDateString,
                price: nil,
                brand: brandString,
                model: modelString,
                status: "IN_CONTAINER"
            )

            // 6. 调用API创建物品
            let _ = try await ItemAPIService.shared.createItem(request: request)

            // 7. 成功后关闭页面
            isLoading = false
            presentationMode.wrappedValue.dismiss()

        } catch {
            // 8. 失败显示错误
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
            print("创建物品失败: \(error)")
        }
    }

    private func getCategoryString(for type: ItemType) -> String {
        switch type {
        case .food:
            return "食品"
        case .clothing:
            return "服饰"
        case .cosmetics:
            return "化妆品"
        case .miscellaneous:
            return "杂物"
        }
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