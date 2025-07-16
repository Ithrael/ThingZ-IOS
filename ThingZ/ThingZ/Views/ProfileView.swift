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
            List {
                // 用户信息区域
                Section {
                    HStack(spacing: 16) {
                        // 头像
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let avatar = authManager.currentUser?.avatar,
                               let imageData = Data(base64Encoded: avatar),
                               let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 用户信息
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.username ?? "未知用户")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let email = authManager.currentUser?.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let phone = authManager.currentUser?.phoneNumber {
                                Text(phone)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: authManager.currentUser?.loginMethod.icon ?? "person.circle")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text(authManager.currentUser?.loginMethod.displayName ?? "未知")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 数据统计
                Section(header: Text("数据统计")) {
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                        Text("容器总数")
                        Spacer()
                        Text("\(dataManager.totalContainers)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.green)
                        Text("物品总数")
                        Spacer()
                        Text("\(dataManager.totalItems)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("即将过期")
                        Spacer()
                        Text("\(dataManager.getExpiringSoonItems().count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("已过期")
                        Spacer()
                        Text("\(dataManager.getExpiredItems().count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 功能设置
                Section(header: Text("功能设置")) {
                    Button(action: {
                        showingNotificationSettings = true
                    }) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.purple)
                            Text("通知设置")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        showingDataManagement = true
                    }) {
                        HStack {
                            Image(systemName: "externaldrive")
                                .foregroundColor(.blue)
                            Text("数据管理")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // 其他设置
                Section(header: Text("其他")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("关于应用")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // 登出
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("登出")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("我的")
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
                    title: Text("确认登出"),
                    message: Text("您确定要登出吗？"),
                    primaryButton: .destructive(Text("登出")) {
                        authManager.logout()
                    },
                    secondaryButton: .cancel()
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

// 使用SettingsView中已有的视图，避免重复声明

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
        .environmentObject(DataManager.shared)
} 