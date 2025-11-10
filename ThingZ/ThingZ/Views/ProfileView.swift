import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingLogoutAlert = false
    @State private var showingAbout = false
    @State private var showingDataManagement = false
    @State private var showingNotificationSettings = false
    @State private var isEditingNickname = false
    @State private var editingNickname = ""
    @State private var showingNicknameAlert = false
    @State private var nicknameAlertMessage = ""
    @State private var isUpdatingNickname = false
    @State private var isUploadingAvatar = false
    @State private var avatarUpdateId = UUID()
    
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
                        // 用户信息区域
                        VStack(spacing: 20) {
                            // 头像
                            Button(action: {
                                if !isUploadingAvatar {
                                    showingImagePicker = true
                                }
                            }) {
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
                                        .frame(width: 120, height: 120)
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                            radius: 20,
                                            x: 0,
                                            y: 10
                                        )
                                    
                                    if isUploadingAvatar {
                                        // 上传中的加载指示器
                                        VStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.5)
                                            Text("上传中...")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.top, 8)
                                        }
                                    } else if let avatar = authManager.currentUser?.avatar,
                                              !avatar.isEmpty {
                                        // 显示头像（支持URL和base64）
                                        if avatar.hasPrefix("http") {
                                            // 添加缓存破坏参数确保显示最新头像
                                            let avatarUrlWithCacheBuster = "\(avatar)?t=\(avatarUpdateId.uuidString)"
                                            AsyncImage(url: URL(string: avatarUrlWithCacheBuster)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 110)
                                                        .clipShape(Circle())
                                                case .failure(_):
                                                    Image(systemName: "person.circle.fill")
                                                        .font(.system(size: 60))
                                                        .foregroundColor(.white)
                                                case .empty:
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                @unknown default:
                                                    Image(systemName: "person.circle.fill")
                                                        .font(.system(size: 60))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        } else if let imageData = Data(base64Encoded: avatar),
                                                  let image = UIImage(data: imageData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 110, height: 110)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 60))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // 编辑图标
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Image(systemName: "camera.fill")
                                                        .font(.caption)
                                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                                )
                                                .shadow(
                                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                                    radius: 5,
                                                    x: 0,
                                                    y: 2
                                                )
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isUploadingAvatar)
                            
                            // 用户信息
                            VStack(spacing: 8) {
                                if isEditingNickname {
                                    VStack(spacing: 12) {
                                        // 编辑输入框
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.9))
                                                .shadow(
                                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                            
                                            TextField("输入昵称", text: $editingNickname)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .onSubmit {
                                                    Task {
                                                        await saveNickname()
                                                    }
                                                }
                                        }
                                        .frame(height: 50)
                                        .frame(maxWidth: 200)
                                        
                                        // 操作按钮
                                        HStack(spacing: 16) {
                                            // 保存按钮
                                            Button(action: {
                                                Task {
                                                    await saveNickname()
                                                }
                                            }) {
                                                HStack(spacing: 6) {
                                                    if isUpdatingNickname {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                            .scaleEffect(0.7)
                                                    } else {
                                                        Image(systemName: "checkmark")
                                                            .font(.caption)
                                                    }
                                                    Text(isUpdatingNickname ? "保存中..." : "保存")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 0.7, green: 0.9, blue: 0.7),
                                                            Color(red: 0.6, green: 0.8, blue: 0.6)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                                .shadow(
                                                    color: Color.green.opacity(0.3),
                                                    radius: 6,
                                                    x: 0,
                                                    y: 3
                                                )
                                            }
                                            .disabled(isUpdatingNickname)
                                            
                                            // 取消按钮
                                            Button(action: cancelNicknameEdit) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "xmark")
                                                        .font(.caption)
                                                    Text("取消")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 1.0, green: 0.6, blue: 0.6),
                                                            Color(red: 1.0, green: 0.5, blue: 0.5)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                                .shadow(
                                                    color: Color.red.opacity(0.3),
                                                    radius: 6,
                                                    x: 0,
                                                    y: 3
                                                )
                                            }
                                        }
                                    }
                                    .padding(.all, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.9),
                                                        Color(red: 1.0, green: 0.98, blue: 0.95)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(
                                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.4),
                                                radius: 15,
                                                x: 0,
                                                y: 8
                                            )
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: isEditingNickname)
                                } else {
                                    Text(authManager.currentUser?.username ?? "可爱的用户")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                        .onLongPressGesture(minimumDuration: 0.5) {
                                            startNicknameEdit()
                                        }
                                }
                                
                                if let email = authManager.currentUser?.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                }
                                
                                if !isEditingNickname {
                                    Text("长按昵称可编辑 ✏️")
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3).opacity(0.8))
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: authManager.currentUser?.loginMethod.icon ?? "person.circle")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                    
                                    Text(authManager.currentUser?.loginMethod.displayName ?? "未知")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(
                                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                            radius: 4,
                                            x: 0,
                                            y: 2
                                        )
                                )
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 数据统计
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("数据统计 📊")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                                                 ProfileStatCard(
                                     title: "总容器",
                                     value: "\(dataManager.totalContainers)",
                                     icon: "archivebox.fill",
                                     color: Color(red: 1.0, green: 0.75, blue: 0.8)
                                 )
                                 
                                 ProfileStatCard(
                                     title: "总物品",
                                     value: "\(dataManager.totalItems)",
                                     icon: "heart.fill",
                                     color: Color(red: 1.0, green: 0.8, blue: 0.4)
                                 )
                                 
                                 ProfileStatCard(
                                     title: "即将过期",
                                     value: "\(dataManager.getExpiringSoonItems().count)",
                                     icon: "clock.badge",
                                     color: Color(red: 1.0, green: 0.8, blue: 0.4)
                                 )
                                 
                                 ProfileStatCard(
                                     title: "已过期",
                                     value: "\(dataManager.getExpiredItems().count)",
                                     icon: "exclamationmark.triangle.fill",
                                     color: Color(red: 1.0, green: 0.6, blue: 0.6)
                                 )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 功能设置
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("功能设置 ⚙️")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                SettingRow(
                                    icon: "bell.fill",
                                    title: "通知设置",
                                    color: Color(red: 0.85, green: 0.7, blue: 0.9)
                                ) {
                                    showingNotificationSettings = true
                                }
                                
                                SettingRow(
                                    icon: "externaldrive.fill",
                                    title: "数据管理",
                                    color: Color(red: 0.7, green: 0.9, blue: 0.9)
                                ) {
                                    showingDataManagement = true
                                }
                                
                                SettingRow(
                                    icon: "info.circle.fill",
                                    title: "关于应用",
                                    color: Color(red: 0.7, green: 0.9, blue: 0.7)
                                ) {
                                    showingAbout = true
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 登出按钮
                        VStack(spacing: 16) {
                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.right.square.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                    
                                    Text("退出登录")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.6, blue: 0.6),
                                            Color(red: 1.0, green: 0.5, blue: 0.5)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(
                                    color: Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.4),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("我的小屋 🏠")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                SharedImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingDataManagement) {
                DataManagementView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("确认登出 🥺"),
                    message: Text("您确定要离开吗？我们会想念您的～"),
                    primaryButton: .destructive(Text("登出")) {
                        authManager.logout()
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .alert("提示", isPresented: $showingNicknameAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(nicknameAlertMessage)
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                if let image = newValue {
                    Task {
                        await updateUserAvatar(image)
                    }
                }
            }
        }
    }
    
    // 开始编辑昵称
    private func startNicknameEdit() {
        editingNickname = authManager.currentUser?.username ?? ""
        isEditingNickname = true
    }
    
    // 保存昵称
    private func saveNickname() async {
        let trimmedNickname = editingNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 验证昵称
        if trimmedNickname.isEmpty {
            await MainActor.run {
                nicknameAlertMessage = "昵称不能为空哦～"
                showingNicknameAlert = true
            }
            return
        }
        
        if trimmedNickname.count > 20 {
            await MainActor.run {
                nicknameAlertMessage = "昵称不能超过20个字符～"
                showingNicknameAlert = true
            }
            return
        }
        
        // 开始更新
        await MainActor.run {
            isUpdatingNickname = true
        }
        
        do {
            // 调用API更新昵称
            let success = try await updateNicknameToServer(trimmedNickname)
            
            if success {
                // API调用成功，更新本地用户信息
                await MainActor.run {
                    if var user = authManager.currentUser {
                        user.username = trimmedNickname
                        authManager.currentUser = user
                        
                        // 保存到UserDefaults
                        if let encoded = try? JSONEncoder().encode(user) {
                            UserDefaults.standard.set(encoded, forKey: "ThingZ_CurrentUser")
                        }
                    }
                    
                    isEditingNickname = false
                    isUpdatingNickname = false
                    nicknameAlertMessage = "昵称更新成功！✨"
                    showingNicknameAlert = true
                }
            }
        } catch {
            // API调用失败
            await MainActor.run {
                isUpdatingNickname = false
                nicknameAlertMessage = "更新失败：\(error.localizedDescription)"
                showingNicknameAlert = true
            }
        }
    }
    
    // 调用服务器API更新昵称
    private func updateNicknameToServer(_ nickname: String) async throws -> Bool {
        guard let authToken = authManager.authToken else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "未找到认证令牌"
            ])
        }
        
        guard let url = URL(string: "https://api.epicfish.cn/thingz/api/v1/user/nick") else {
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "无效的API地址"
            ])
        }
        
        // 构建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        // 构建请求体
        let requestBody = ["nick": nickname]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        // 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "服务器响应异常"
            ])
        }
        
        // 检查HTTP状态码
        if httpResponse.statusCode == 200 {
            return true
        } else {
            // 尝试解析错误信息
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: message
                ])
            } else {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "更新昵称失败 (HTTP \(httpResponse.statusCode))"
                ])
            }
        }
    }
    
    // 取消编辑昵称
    private func cancelNicknameEdit() {
        isEditingNickname = false
        editingNickname = ""
    }
    
    private func updateUserAvatar(_ image: UIImage) async {
        // 开始上传
        await MainActor.run {
            isUploadingAvatar = true
        }
        
        do {
            print("🖼️ 开始处理图片，原始尺寸: \(image.size)")
            
            // 压缩图片
            let compressedImage = compressImage(image)
            print("🖼️ 压缩后尺寸: \(compressedImage.size)")
            
            guard let imageData = compressedImage.jpegData(compressionQuality: 0.8) else {
                print("❌ 图片转换为JPEG数据失败")
                throw NSError(domain: "ImageError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "图片处理失败"
                ])
            }
            
            print("🖼️ 图片数据大小: \(imageData.count) bytes")
            
            // 上传头像到服务器
            let avatarUrl = try await uploadAvatarToServer(imageData)
            
            // 上传成功，更新用户信息
            await MainActor.run {
                if var user = authManager.currentUser {
                    user.avatar = avatarUrl
                    authManager.currentUser = user
                    
                    // 保存到UserDefaults
                    if let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "ThingZ_CurrentUser")
                    }
                }
                
                // 清除选中的图片状态，确保显示服务器返回的头像
                selectedImage = nil
                
                // 更新头像ID以触发界面刷新
                avatarUpdateId = UUID()
                
                isUploadingAvatar = false
                nicknameAlertMessage = "头像更新成功！✨"
                showingNicknameAlert = true
            }
            
        } catch {
            // 上传失败
            print("❌ 头像上传失败: \(error)")
            print("❌ 错误详情: \(error.localizedDescription)")
            
            await MainActor.run {
                isUploadingAvatar = false
                nicknameAlertMessage = "头像上传失败：\(error.localizedDescription)"
                showingNicknameAlert = true
            }
        }
    }
    
    // 压缩图片
    private func compressImage(_ image: UIImage) -> UIImage {
        let maxSize: CGFloat = 800
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // 上传头像到服务器
    private func uploadAvatarToServer(_ imageData: Data) async throws -> String {
        guard let authToken = authManager.authToken else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "未找到认证令牌"
            ])
        }
        
        guard let url = URL(string: "https://api.epicfish.cn/thingz/api/v1/file/avater/upload") else {
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "无效的API地址"
            ])
        }
        
        // 生成boundary
        let boundary = UUID().uuidString
        
        // 构建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60.0 // 增加超时时间用于文件上传
        
        // 构建multipart/form-data请求体
        var body = Data()
        
        // 添加文件数据
        let boundaryPrefix = "--\(boundary)\r\n"
        let contentDisposition = "Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n"
        let contentType = "Content-Type: image/jpeg\r\n\r\n"
        let boundarySuffix = "\r\n--\(boundary)--\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append(contentDisposition.data(using: .utf8)!)
        body.append(contentType.data(using: .utf8)!)
        body.append(imageData)
        body.append(boundarySuffix.data(using: .utf8)!)
        
        request.httpBody = body
        
        // 发送请求
        print("📤 开始上传头像，文件大小: \(imageData.count) bytes")
        print("📤 请求URL: \(url)")
        print("📤 Authorization: Bearer \(authToken.prefix(20))...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("📥 收到响应，数据大小: \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "服务器响应异常"
            ])
        }
        
        // 检查HTTP状态码
        print("📥 HTTP状态码: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200 {
            // 解析响应获取头像URL
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 响应内容: \(responseString)")
            }
            
            if let responseJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📥 解析的JSON: \(responseJson)")
                
                if let code = responseJson["code"] as? Int, code == 200,
                   let dataObj = responseJson["data"] as? [String: Any] {
                    
                    // 根据实际响应结构，avatarUrl字段名是 "avatarUrl" 而不是 "url"
                    if let avatarUrl = dataObj["avatarUrl"] as? String {
                        print("✅ 成功获取头像URL: \(avatarUrl)")
                        return avatarUrl
                    } else {
                        print("❌ 未找到avatarUrl字段，data内容: \(dataObj)")
                        throw NSError(domain: "APIError", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "响应中未找到头像URL"
                        ])
                    }
                } else if let message = responseJson["message"] as? String {
                    throw NSError(domain: "APIError", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: message
                    ])
                }
            }
            
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "服务器响应格式异常"
            ])
        } else {
            // 尝试解析错误信息
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ 错误响应: \(errorString)")
            }
            
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: message
                ])
            } else {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "头像上传失败 (HTTP \(httpResponse.statusCode))"
                ])
            }
        }
    }
}

// 个人资料统计卡片
struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
        }
        .padding(.all, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.8))
                .shadow(
                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
}

// 设置行
struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 45, height: 45)
                        .shadow(
                            color: color.opacity(0.3),
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.8))
                    .font(.caption)
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
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
        .environmentObject(DataManager.shared)
} 
