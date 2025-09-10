import SwiftUI
import UIKit
import PhotosUI

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
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingImageSourceOptions = false
    @State private var isUploading = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
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
                                    
                                    // 容器图片区域
                                    Button(action: {
                                        showingImageSourceOptions = true
                                    }) {
                                        ZStack {
                                            if isUploading {
                                                VStack(spacing: 8) {
                                                    ProgressView()
                                                        .scaleEffect(0.8)
                                                        .tint(.white)
                                                    Text("上传中")
                                                        .font(.caption2)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.white)
                                                }
                                            } else if let image = selectedImage {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(Circle())
                                            } else if !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                            .scaleEffect(0.8)
                                                            .tint(.white)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 80, height: 80)
                                                            .clipShape(Circle())
                                                    case .failure:
                                                        Image(systemName: "photo.badge.plus")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(.white)
                                                    @unknown default:
                                                        Image(systemName: "pencil.circle.fill")
                                                            .font(.system(size: 35))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            } else {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Text("编辑容器信息")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            }
                            
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
                                    Text("位置信息 �")
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
                                        Text("楼层 �")
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                }
            })
        }
        .onAppear {
            loadContainerDetail()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ContainerImagePicker(selectedImage: $selectedImage, sourceType: imageSource)
                .onDisappear {
                    if let _ = selectedImage {
                        uploadImage()
                    }
                }
        }
        .confirmationDialog("选择图片来源", isPresented: $showingImageSourceOptions, titleVisibility: .visible) {
            Button("相机") {
                imageSource = .camera
                showingImagePicker = true
            }
            Button("相册") {
                imageSource = .photoLibrary
                showingImagePicker = true
            }
            Button("取消", role: .cancel) {}
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
                     
                     // 如果有图片URL，尝试预加载图片
                     if let imageUrl = detail.imageUrl, !imageUrl.isEmpty {
                         print("容器图片URL: \(imageUrl)")
                     }
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
    
    private func uploadImage() {
        guard let image = selectedImage else { return }
        
        // 显示上传中状态
        isUploading = true
        
        // 压缩图片
        let maxSize: CGFloat = 800
        let scale = min(maxSize / image.size.width, maxSize / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let compressedImage = resizedImage,
              let imageData = compressedImage.jpegData(compressionQuality: 0.7) else {
            isUploading = false
            alertMessage = "图片处理失败"
            showingAlert = true
            return
        }
        
        // 准备上传请求
        let authManager = AuthManager.shared
        guard let token = authManager.authToken else {
            isUploading = false
            alertMessage = "未登录，请先登录"
            showingAlert = true
            return
        }
        
        // 创建multipart/form-data请求
        let boundary = UUID().uuidString
        let url = URL(string: "https://api.epicfish.cn/thingz/api/v1/file/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 构建请求体
        var body = Data()
        
        // 添加文件数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 结束标记
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // 执行上传请求
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "HTTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "无效的HTTP响应"])
                }
                
                if httpResponse.statusCode == 200 {
                    // 解析响应
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("上传响应: \(responseString)")
                    }
                    
                    // 尝试解析JSON响应
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let data = json["data"] as? [String: Any],
                       let fileUrlCDN = data["fileUrlCDN"] as? String {
                        
                        await MainActor.run {
                            self.imageUrl = fileUrlCDN
                            self.isUploading = false
                        }
                        return
                    }
                    
                    throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])
                } else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP错误: \(httpResponse.statusCode)"])
                }
            } catch {
                print("上传错误: \(error.localizedDescription)")
                await MainActor.run {
                    self.alertMessage = "图片上传失败: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isUploading = false
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

// 修改后的ImagePicker，支持指定图片来源
struct ContainerImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ContainerImagePicker
        
        init(_ parent: ContainerImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContainerEditView(containerId: "container_8d5668433e4946af8b4415187ceeac51")
        .environmentObject(DataManager.shared)
}
