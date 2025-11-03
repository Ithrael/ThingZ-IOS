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
    @State private var category = ""
    @State private var capacity = 50
    
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
            do {
                let detail = try await ContainerAPIService.shared.getContainerDetail(containerId: containerId)

                await MainActor.run {
                    self.name = detail.name
                    self.location = detail.location ?? ""
                    self.description = detail.description ?? ""
                    self.room = detail.room ?? ""
                    self.floor = detail.floor ?? ""
                    self.imageUrl = detail.imageUrl ?? ""
                    self.isExpirationReminder = detail.isExpirationReminder
                    self.isShareable = detail.isShareable
                    self.category = detail.category
                    self.capacity = detail.capacity
                    self.isLoading = false

                    print("容器信息加载成功: \(detail.name)")
                    if let imageUrl = detail.imageUrl, !imageUrl.isEmpty {
                        print("容器图片URL: \(imageUrl)")
                    }
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "加载容器信息失败: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isLoading = false
                    print("加载容器信息失败: \(error)")
                }
            }
        }
    }
    
    private func uploadImage() {
        guard let image = selectedImage else { return }

        isUploading = true

        Task {
            do {
                let uploadedUrl = try await FileUploadService.shared.processAndUploadImage(
                    image,
                    type: .image
                )

                await MainActor.run {
                    self.imageUrl = uploadedUrl
                    self.isUploading = false
                    print("图片上传成功: \(uploadedUrl)")
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "图片上传失败: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isUploading = false
                    print("图片上传失败: \(error)")
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

        let request = UpdateContainerAPIRequest(
            name: name,
            category: category.isEmpty ? nil : category,
            location: location.isEmpty ? nil : location,
            description: description.isEmpty ? nil : description,
            capacity: capacity,
            room: room.isEmpty ? nil : room,
            floor: floor.isEmpty ? nil : floor,
            isShareable: isShareable,
            isExpirationReminder: isExpirationReminder,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl
        )

        Task {
            do {
                let _ = try await ContainerAPIService.shared.updateContainer(
                    containerId: containerId,
                    request: request
                )

                await MainActor.run {
                    self.isSaving = false
                    self.alertMessage = "容器信息更新成功！"
                    self.showingAlert = true

                    // 延迟关闭页面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.alertMessage = "更新失败: \(error.localizedDescription)"
                    self.showingAlert = true
                    print("更新容器失败: \(error)")
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
