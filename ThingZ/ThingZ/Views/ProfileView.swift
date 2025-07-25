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
                                showingImagePicker = true
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
                                    
                                    if let avatar = authManager.currentUser?.avatar,
                                       let imageData = Data(base64Encoded: avatar),
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
                            
                            // 用户信息
                            VStack(spacing: 8) {
                                Text(authManager.currentUser?.username ?? "可爱的用户")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                if let email = authManager.currentUser?.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                }
                                
                                if let phone = authManager.currentUser?.phoneNumber {
                                    Text(phone)
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
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
                ImagePicker(selectedImage: $selectedImage)
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
            .onChange(of: selectedImage) { image in
                if let image = image {
                    updateUserAvatar(image)
                }
            }
        }
    }
    
    private func updateUserAvatar(_ image: UIImage) {
        // 压缩图片
        let maxSize: CGFloat = 300
        let scale = min(maxSize / image.size.width, maxSize / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 转换为base64字符串
        if let resizedImage = resizedImage,
           let imageData = resizedImage.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            
            // 更新用户头像
            if var user = authManager.currentUser {
                user.avatar = base64String
                authManager.currentUser = user
                
                // 保存到UserDefaults
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "ThingZ_CurrentUser")
                }
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

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
        .environmentObject(DataManager.shared)
} 
