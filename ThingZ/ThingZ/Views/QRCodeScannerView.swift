import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @State private var isScanning = false
    @State private var foundContainer: Container?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var scanHistory: [ScanHistoryItem] = []
    @State private var showingHistory = false

    // 扫描历史项
    struct ScanHistoryItem: Identifiable, Codable {
        let id: String
        let containerName: String
        let containerId: String
        let timestamp: Date

        init(container: Container) {
            self.id = UUID().uuidString
            self.containerName = container.name
            self.containerId = container.apiId ?? container.id.uuidString
            self.timestamp = Date()
        }
    }
    
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
            
            VStack(spacing: 20) {
                // 标题
                Text("扫描二维码 📱")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                    .padding(.top, 20)
                
                // 扫描区域
                ZStack {
                    // 扫描视图
                    QRScannerRepresentable(
                        isScanning: $isScanning,
                        onCodeFound: { code in
                            handleScannedCode(code)
                        }
                    )
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // 扫描框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.75, blue: 0.8),
                                    Color(red: 1.0, green: 0.6, blue: 0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(height: 300)
                        .padding(.horizontal, 20)
                    
                    // 扫描线动画
                    if isScanning {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.0),
                                        Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.8),
                                        Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .offset(y: -50)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: isScanning
                            )
                    }
                }
                
                // 说明文字
                Text("将二维码放入框内，自动扫描")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                    .padding(.top, 10)
                
                Spacer()
                
                // 底部按钮
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("取消")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
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
                .padding(.bottom, 30)
            }

            // 加载指示器覆盖层
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)

                        Text("正在加载...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 1.0, green: 0.75, blue: 0.8))
                            .shadow(radius: 20)
                    )
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            showingHistory = true
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(Theme.Colors.pinkAccent)
        })
        .onAppear {
            isScanning = true
            loadScanHistory()
        }
        .onDisappear {
            isScanning = false
        }
        .sheet(item: $foundContainer) { container in
            NavigationView {
                ContainerDetailView(container: container)
                    .navigationBarItems(trailing: Button("完成") {
                        foundContainer = nil
                    })
            }
        }
        .sheet(isPresented: $showingHistory) {
            ScanHistoryView(history: scanHistory, onSelectItem: { item in
                showingHistory = false
                loadContainerFromHistory(item)
            })
        }
        .alert("扫描结果", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleScannedCode(_ code: String) {
        // 暂停扫描
        isScanning = false
        isLoading = true

        // 触觉反馈
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        Task {
            // 尝试解析JSON
            if let data = code.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let containerId = json["containerId"] as? String {

                // 从API获取容器详情
                do {
                    let apiContainer = try await ContainerAPIService.shared.getContainerDetail(containerId: containerId)
                    let container = Container.from(apiContainer: apiContainer)

                    await MainActor.run {
                        isLoading = false
                        generator.notificationOccurred(.success)
                        addToScanHistory(container: container)
                        foundContainer = container
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        generator.notificationOccurred(.error)
                        alertMessage = "获取容器信息失败: \(error.localizedDescription)"
                        showingAlert = true

                        // 延迟后恢复扫描
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isScanning = true
                        }
                    }
                }
            } else if let idString = code.components(separatedBy: "/").last,
                      !idString.isEmpty {
                // 尝试直接解析为容器ID
                do {
                    let apiContainer = try await ContainerAPIService.shared.getContainerDetail(containerId: idString)
                    let container = Container.from(apiContainer: apiContainer)

                    await MainActor.run {
                        isLoading = false
                        generator.notificationOccurred(.success)
                        addToScanHistory(container: container)
                        foundContainer = container
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        generator.notificationOccurred(.error)
                        alertMessage = "获取容器信息失败: \(error.localizedDescription)"
                        showingAlert = true

                        // 延迟后恢复扫描
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isScanning = true
                        }
                    }
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    generator.notificationOccurred(.error)
                    alertMessage = "无效的二维码格式，请扫描有效的容器二维码"
                    showingAlert = true

                    // 延迟后恢复扫描
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isScanning = true
                    }
                }
            }
        }
    }

    // 加载扫描历史
    private func loadScanHistory() {
        if let data = UserDefaults.standard.data(forKey: "scanHistory"),
           let history = try? JSONDecoder().decode([ScanHistoryItem].self, from: data) {
            scanHistory = history
        }
    }

    // 保存扫描历史
    private func saveScanHistory() {
        if let data = try? JSONEncoder().encode(scanHistory) {
            UserDefaults.standard.set(data, forKey: "scanHistory")
        }
    }

    // 添加到扫描历史
    private func addToScanHistory(container: Container) {
        let newItem = ScanHistoryItem(container: container)
        scanHistory.insert(newItem, at: 0)

        // 只保留最近20条记录
        if scanHistory.count > 20 {
            scanHistory = Array(scanHistory.prefix(20))
        }

        saveScanHistory()
    }

    // 从历史记录加载容器
    private func loadContainerFromHistory(_ item: ScanHistoryItem) {
        isLoading = true

        Task {
            do {
                let apiContainer = try await ContainerAPIService.shared.getContainerDetail(containerId: item.containerId)
                let container = Container.from(apiContainer: apiContainer)

                await MainActor.run {
                    isLoading = false
                    foundContainer = container
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "加载容器失败: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// AVFoundation扫描器
struct QRScannerRepresentable: UIViewRepresentable {
    @Binding var isScanning: Bool
    let onCodeFound: (String) -> Void
    
    func makeUIView(context: Context) -> QRScannerView {
        let scannerView = QRScannerView()
        scannerView.delegate = context.coordinator
        return scannerView
    }
    
    func updateUIView(_ uiView: QRScannerView, context: Context) {
        if isScanning {
            uiView.startScanning()
        } else {
            uiView.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewDelegate {
        let parent: QRScannerRepresentable
        
        init(_ parent: QRScannerRepresentable) {
            self.parent = parent
        }
        
        func qrScannerView(_ scannerView: QRScannerView, didFindCode code: String) {
            parent.onCodeFound(code)
        }
    }
}

// 扫描器代理协议
protocol QRScannerViewDelegate: AnyObject {
    func qrScannerView(_ scannerView: QRScannerView, didFindCode code: String)
}

// 自定义扫描视图
class QRScannerView: UIView {
    weak var delegate: QRScannerViewDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        // 创建会话
        let session = AVCaptureSession()
        
        // 获取后置摄像头
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // 创建输入
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // 添加输入到会话
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return
        }
        
        // 创建元数据输出
        let metadataOutput = AVCaptureMetadataOutput()
        
        // 添加输出到会话
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            // 设置代理和队列
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        // 创建预览层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        // 保存会话和预览层
        self.captureSession = session
        self.previewLayer = previewLayer
    }
    
    func startScanning() {
        if let captureSession = captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = layer.bounds
    }
}

// AVCaptureMetadataOutputObjectsDelegate
extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 检查是否有QR码
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue {
            
            // 通知代理
            delegate?.qrScannerView(self, didFindCode: stringValue)
        }
    }
}

// MARK: - 扫描历史视图
struct ScanHistoryView: View {
    let history: [QRCodeScannerView.ScanHistoryItem]
    let onSelectItem: (QRCodeScannerView.ScanHistoryItem) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.warmGradient.ignoresSafeArea()

                if history.isEmpty {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "暂无扫描记录",
                        message: "扫描容器二维码后，记录将显示在这里"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.medium) {
                            ForEach(history) { item in
                                Button(action: {
                                    onSelectItem(item)
                                }) {
                                    HStack(spacing: Theme.Spacing.medium) {
                                        // 图标
                                        ZStack {
                                            Circle()
                                                .fill(Theme.Colors.pinkAccent.opacity(0.2))
                                                .frame(width: 50, height: 50)

                                            Image(systemName: "cube.box.fill")
                                                .font(.title3)
                                                .foregroundColor(Theme.Colors.pinkAccent)
                                        }

                                        // 信息
                                        VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                                            Text(item.containerName)
                                                .font(Theme.Fonts.bodyBold)
                                                .foregroundColor(Theme.Colors.primaryText)

                                            Text(formatDate(item.timestamp))
                                                .font(Theme.Fonts.caption1)
                                                .foregroundColor(Theme.Colors.secondaryText)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(Theme.Colors.tertiaryText)
                                    }
                                    .padding(Theme.Spacing.medium)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .fill(Theme.Colors.cardBackground)
                                        .shadow(
                                            color: Theme.Shadow.light.color,
                                            radius: Theme.Shadow.light.radius,
                                            x: Theme.Shadow.light.x,
                                            y: Theme.Shadow.light.y
                                        )
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("扫描历史")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    QRCodeScannerView()
        .environmentObject(DataManager.shared)
}