import SwiftUI

struct ContainerEditView: View {
    let containerId: String
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var location = ""
    @State private var description = ""
    @State private var room = ""
    @State private var floor = ""
    @State private var imageUrl = ""
    @State private var isExpirationReminder = false
    @State private var isShareable = false
    
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(red: 1.0, green: 0.75, blue: 0.8))
                        
                        Text("加载容器信息中...")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    }
                } else {
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
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                            radius: 15,
                                            x: 0,
                                            y: 8
                                        )
                                    
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(.white)
                                }
                                
                                Text("编辑容器信息")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            }
                            .padding(.top, 20)
                            
                            // 表单区域
                            VStack(spacing: 20) {
                                // 容器名称
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("容器名称 📝")
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
                                        
                                        TextField("请输入容器名称", text: $name)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    }
                                    .frame(height: 50)
                                }
                                
                                // 位置信息
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("位置信息 📍")
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
                                
                                // 房间和楼层
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("房间 🏠")
                                            .font(.subheadline)
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
                                            
                                            TextField("房间", text: $room)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        }
                                        .frame(height: 50)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("楼层 🏢")
                                            .font(.subheadline)
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
                                            
                                            TextField("楼层", text: $floor)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        }
                                        .frame(height: 50)
                                    }
                                }
                                
                                // 描述
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("描述信息 📄")
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
                                        
                                        TextField("容器的详细描述...", text: $description, axis: .vertical)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                            .lineLimit(3...6)
                                    }
                                    .frame(minHeight: 80)
                                }
                                
                                // 图片URL
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("图片链接 🖼️")
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
                                        
                                        TextField("https://...", text: $imageUrl)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                    }
                                    .frame(height: 50)
                                }
                                
                                // 开关设置
                                VStack(spacing: 16) {
                                    // 过期提醒
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("过期提醒 ⏰")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                            
                                            Text("开启后会提醒容器内物品过期")
                                                .font(.caption)
                                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $isExpirationReminder)
                                            .tint(Color(red: 1.0, green: 0.75, blue: 0.8))
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
                                    
                                    // 共享设置
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("允许共享 🤝")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                            
                                            Text("开启后其他人可以查看此容器")
                                                .font(.caption)
                                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $isShareable)
                                            .tint(Color(red: 1.0, green: 0.75, blue: 0.8))
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
                                
                                // 保存按钮
                                Button(action: saveContainer) {
                                    HStack(spacing: 12) {
                                        if isSaving {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title3)
                                        }
                                        
                                        Text(isSaving ? "保存中..." : "保存修改")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 1.0, green: 0.75, blue: 0.8),
                                                        Color(red: 1.0, green: 0.65, blue: 0.7)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                                radius: 12,
                                                x: 0,
                                                y: 6
                                            )
                                    )
                                }
                                .disabled(isSaving || name.isEmpty)
                                .scaleEffect(isSaving || name.isEmpty ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isSaving || name.isEmpty)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("编辑容器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            }
        }
        .onAppear {
            loadContainerDetail()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadContainerDetail() {
        Task {
            // 添加调试信息
            print("AuthManager.shared.isAuthenticated: \(AuthManager.shared.isAuthenticated)")
            print("AuthManager.shared.authToken != nil: \(AuthManager.shared.authToken != nil)")
            if let token = AuthManager.shared.authToken {
                print("Token preview: \(String(token.prefix(20)))...")
            }
            
            if let detail = await dataManager.fetchContainerDetail(containerId: containerId) {
                 await MainActor.run {
                     self.name = detail.name
                     self.location = detail.location ?? ""
                     self.description = detail.description ?? ""
                     self.room = detail.room ?? ""
                     self.floor = detail.floor ?? ""
                     self.imageUrl = detail.imageUrl ?? ""
                     self.isExpirationReminder = detail.isExpirationReminder
                     self.isShareable = detail.isShareable
                     self.isLoading = false
                 }
            } else {
                await MainActor.run {
                    self.alertMessage = "加载容器信息失败，请稍后重试"
                    self.showingAlert = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveContainer() {
        guard !name.isEmpty else {
            alertMessage = "容器名称不能为空"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        let request = UpdateContainerRequest(
            name: name,
            location: location.isEmpty ? nil : location,
            description: description.isEmpty ? nil : description,
            isExpirationReminder: isExpirationReminder,
            room: room.isEmpty ? nil : room,
            floor: floor.isEmpty ? nil : floor,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl,
            isShareable: isShareable
        )
        
        Task {
            let success = await dataManager.updateContainerInfo(containerId: containerId, request: request)
            
            await MainActor.run {
                self.isSaving = false
                
                if success {
                    self.alertMessage = "容器信息更新成功！"
                    self.showingAlert = true
                    
                    // 延迟关闭页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    self.alertMessage = "更新失败，请稍后重试"
                    self.showingAlert = true
                }
            }
        }
    }
}

#Preview {
    ContainerEditView(containerId: "container_8d5668433e4946af8b4415187ceeac51")
        .environmentObject(DataManager.shared)
}