import SwiftUI

struct AddContainerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var selectedType = ContainerType.wardrobe
    @State private var location = ""
    @State private var capacity = 50
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
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
                        // 标题区域
                        VStack(spacing: 12) {
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
                                    .frame(width: 80, height: 80)
                                    .shadow(
                                        color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                
                                Image(systemName: "heart.circle.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            Text("创建新的容器")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                        }
                        .padding(.top, 20)
                        
                        // 基本信息部分
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("容器名称 ✨")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    
                                    TextField("给你的容器起个可爱的名字吧～", text: $name)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                }
                                .frame(height: 50)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("容器类型 📦")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                    
                    Picker("容器类型", selection: $selectedType) {
                        ForEach(ContainerType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                Text(type.displayName)
                                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            }
                            .tag(type)
                        }
                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .frame(height: 50)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("存放位置 📍")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    
                                    TextField("比如：卧室、客厅、厨房...", text: $location)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                }
                                .frame(height: 50)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("容量设置 📏")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    
                                    HStack {
                                        Text("最多可放: \(capacity) 件物品")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                if capacity > 1 {
                                                    capacity -= 1
                                                }
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                }
                
                                            Text("\(capacity)")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                                .frame(minWidth: 30)
                                            
                                            Button(action: {
                                                if capacity < 1000 {
                                                    capacity += 1
                                                }
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .frame(height: 50)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 容器图片部分
                        VStack(alignment: .leading, spacing: 12) {
                            Text("容器照片 📷")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                .padding(.horizontal, 20)
                            
                    if let image = selectedImage {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 10,
                                            x: 0,
                                            y: 5
                                        )
                                    
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                                        .cornerRadius(16)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                                }
                                .padding(.horizontal, 20)
                    } else {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.8))
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                                radius: 10,
                                                x: 0,
                                                y: 5
                                            )
                                        
                                        VStack(spacing: 16) {
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
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 25))
                                                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                            }
                                            
                                            Text("点击添加容器照片 ✨")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                        }
                            }
                                    .frame(height: 140)
                        }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                }
            }
                        
                        // 保存按钮
                        VStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await saveContainer()
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                } else {
                                    Text("创建我的容器 🎉")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                }
                            }
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.75, blue: 0.8),
                                        Color(red: 1.0, green: 0.65, blue: 0.75)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                            .disabled(name.isEmpty || location.isEmpty || isLoading)
                            .scaleEffect(name.isEmpty || location.isEmpty ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: name.isEmpty || location.isEmpty)
                            .padding(.horizontal, 20)
                            
                            Button(action: {
                        presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("取消")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.6))
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.1),
                                                radius: 5,
                                                x: 0,
                                                y: 2
                                            )
                                    )
                    }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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

    private func saveContainer() async {
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

            // 2. 构建CreateContainerRequest
            let request = CreateContainerRequest(
                name: name,
                category: selectedType.apiCategory,
                location: location.isEmpty ? nil : location,
                description: nil,
                capacity: capacity,
                room: nil,
                floor: nil,
                isShareable: false,
                isExpirationReminder: true,
                imageUrl: imageUrl
            )

            // 3. 调用API创建容器
            let _ = try await ContainerAPIService.shared.createContainer(request: request)

            // 4. 成功后关闭页面
            isLoading = false
            presentationMode.wrappedValue.dismiss()

        } catch {
            // 5. 失败显示错误
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
            print("创建容器失败: \(error)")
        }
    }
}

#Preview {
    AddContainerView()
        .environmentObject(DataManager.shared)
}