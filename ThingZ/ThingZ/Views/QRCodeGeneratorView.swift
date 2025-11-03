import SwiftUI
import Photos

struct QRCodeGeneratorView: View {
    let container: Container
    @State private var qrCodeImage: UIImage?
    @State private var showingShareSheet = false
    @State private var showingSaveSuccess = false
    @State private var showingPermissionAlert = false
    @State private var errorMessage: String?
    @State private var isGenerating = false
    @State private var isSaving = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
            
            VStack(spacing: 24) {
                // 标题
                Text("容器二维码")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    .padding(.top, 20)
                
                // 容器信息卡片
                VStack(spacing: 12) {
                    // 容器图标
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
                            .frame(width: 60, height: 60)
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        
                        if let imageUrl = container.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: container.type.icon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: container.type.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // 容器名称
                    Text(container.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    
                    // 容器位置
                    Text(container.location)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    
                    // 容器类型标签
                    Text(container.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                        )
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                }
                .padding(.all, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .padding(.horizontal, 20)
                
                // 二维码显示
                if let qrCodeImage = qrCodeImage {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(.all, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(
                                    color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                } else {
                    // 加载中
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.75, blue: 0.8)))
                            .scaleEffect(1.5)
                        
                        Text("生成二维码中...")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            .padding(.top, 10)
                    }
                    .frame(width: 250, height: 250)
                    .padding(.all, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(
                                color: Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.2),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    )
                }
                
                // 说明文字
                Text("扫描此二维码可以快速查看容器内容")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 16) {
                    // 保存按钮
                    Button(action: saveQRCodeToPhotos) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.headline)
                            }
                            Text(isSaving ? "保存中..." : "保存")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
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
                        .cornerRadius(20)
                        .shadow(
                            color: Color.green.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(qrCodeImage == nil || isSaving)
                    
                    // 分享按钮
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                            Text("分享")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.75, blue: 0.8),
                                    Color(red: 1.0, green: 0.65, blue: 0.7)
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
                    }
                    .disabled(qrCodeImage == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("容器二维码")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateQRCode()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let qrCodeImage = qrCodeImage {
                let shareText = "容器二维码 - \(container.name)\n位置: \(container.location)\n类型: \(container.type.displayName)"
                ShareSheet(items: [shareText, qrCodeImage])
            }
        }
        .alert("保存成功", isPresented: $showingSaveSuccess) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("二维码已保存到相册")
        }
        .alert("需要相册权限", isPresented: $showingPermissionAlert) {
            Button("去设置", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("请在设置中允许访问相册以保存二维码")
        }
        .errorAlert($errorMessage)
    }
    
    private func generateQRCode() {
        guard let apiId = container.apiId else {
            // 如果没有API ID，使用本地ID生成
            DispatchQueue.global(qos: .userInitiated).async {
                let generatedQRCode = QRCodeGenerator.generateContainerQRCode(container: container)

                DispatchQueue.main.async {
                    self.qrCodeImage = generatedQRCode
                }
            }
            return
        }

        isGenerating = true

        Task {
            do {
                // 调用API生成二维码
                let qrCodeUrl = try await ContainerAPIService.shared.generateQRCode(containerId: apiId)

                // 使用返回的URL或containerId生成本地二维码
                let qrCodeString = qrCodeUrl.isEmpty ? apiId : qrCodeUrl

                await MainActor.run {
                    if let data = qrCodeString.data(using: .utf8),
                       let filter = CIFilter(name: "CIQRCodeGenerator") {
                        filter.setValue(data, forKey: "inputMessage")
                        filter.setValue("H", forKey: "inputCorrectionLevel")

                        if let outputImage = filter.outputImage {
                            let transform = CGAffineTransform(scaleX: 10, y: 10)
                            let scaledImage = outputImage.transformed(by: transform)
                            let context = CIContext()

                            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                                qrCodeImage = UIImage(cgImage: cgImage)
                            }
                        }
                    }
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "生成二维码失败: \(error.localizedDescription)"
                    isGenerating = false

                    // 降级：使用本地方式生成
                    DispatchQueue.global(qos: .userInitiated).async {
                        let generatedQRCode = QRCodeGenerator.generateContainerQRCode(container: container)

                        DispatchQueue.main.async {
                            self.qrCodeImage = generatedQRCode
                        }
                    }
                }
            }
        }
    }
    
    private func saveQRCodeToPhotos() {
        guard let qrCodeImage = qrCodeImage else { return }

        // 检查相册权限
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            // 已授权，直接保存
            performSave(image: qrCodeImage)

        case .notDetermined:
            // 未请求过权限，请求权限
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.performSave(image: qrCodeImage)
                    } else {
                        self.showingPermissionAlert = true
                    }
                }
            }

        case .denied, .restricted:
            // 权限被拒绝或受限
            showingPermissionAlert = true

        @unknown default:
            showingPermissionAlert = true
        }
    }

    private func performSave(image: UIImage) {
        isSaving = true

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                self.isSaving = false

                if success {
                    self.showingSaveSuccess = true
                } else {
                    self.errorMessage = "保存失败: \(error?.localizedDescription ?? "未知错误")"
                }
            }
        }
    }
}

// 分享表单
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    QRCodeGeneratorView(container: Container(
        name: "厨房调料柜",
        type: .cabinet,
        location: "厨房",
        capacity: 20
    ))
}