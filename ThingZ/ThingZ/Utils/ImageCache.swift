import UIKit
import SwiftUI

// MARK: - 图片缓存管理器
class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        // 设置缓存限制
        cache.countLimit = 100 // 最多缓存100张图片
        cache.totalCostLimit = 50 * 1024 * 1024 // 最大50MB

        // 获取缓存目录
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")

        // 创建缓存目录
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // 监听内存警告
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    // MARK: - 获取图片
    func getImage(forKey key: String) -> UIImage? {
        let nsKey = key as NSString

        // 先从内存缓存获取
        if let cachedImage = cache.object(forKey: nsKey) {
            return cachedImage
        }

        // 再从磁盘缓存获取
        if let diskImage = loadImageFromDisk(key: key) {
            cache.setObject(diskImage, forKey: nsKey)
            return diskImage
        }

        return nil
    }

    // MARK: - 保存图片
    func setImage(_ image: UIImage, forKey key: String) {
        let nsKey = key as NSString

        // 保存到内存缓存
        cache.setObject(image, forKey: nsKey)

        // 保存到磁盘缓存
        saveImageToDisk(image, key: key)
    }

    // MARK: - 清除缓存
    @objc func clearMemoryCache() {
        cache.removeAllObjects()
    }

    func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }

    // MARK: - 获取缓存大小
    func getCacheSize() -> Int64 {
        var totalSize: Int64 = 0

        if let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) {
            for fileURL in fileURLs {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }

        return totalSize
    }

    // MARK: - 私有方法
    private func loadImageFromDisk(key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5Hash)

        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    private func saveImageToDisk(_ image: UIImage, key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5Hash)

        DispatchQueue.global(qos: .background).async {
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
            }
        }
    }
}

// MARK: - String MD5 扩展
extension String {
    var md5Hash: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(16))

        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &digest)
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

// 导入CommonCrypto
import CommonCrypto

// MARK: - 缓存图片视图
struct CachedAsyncImage: View {
    let url: URL?
    let placeholder: Image?

    @State private var image: UIImage?
    @State private var isLoading = false

    init(url: URL?, placeholder: Image? = nil) {
        self.url = url
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                ProgressView()
            } else if let placeholder = placeholder {
                placeholder
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        let cacheKey = url.absoluteString

        // 先尝试从缓存获取
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            self.image = cachedImage
            return
        }

        // 从网络加载
        isLoading = true

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                if let downloadedImage = UIImage(data: data) {
                    await MainActor.run {
                        ImageCache.shared.setImage(downloadedImage, forKey: cacheKey)
                        self.image = downloadedImage
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - 性能监控工具
class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var startTimes: [String: Date] = [:]

    func startMeasuring(tag: String) {
        startTimes[tag] = Date()
    }

    func endMeasuring(tag: String) -> TimeInterval? {
        guard let startTime = startTimes[tag] else { return nil }

        let duration = Date().timeIntervalSince(startTime)
        startTimes.removeValue(forKey: tag)

        #if DEBUG
        print("⏱️ Performance - \(tag): \(String(format: "%.2f", duration * 1000))ms")
        #endif

        return duration
    }
}
