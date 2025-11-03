import Foundation
import UIKit
import SwiftUI

// MARK: - 文件上传类型
enum UploadFileType {
    case avatar      // 头像
    case image       // 普通图片
    case general     // 通用文件

    var endpoint: String {
        switch self {
        case .avatar:
            return "/file/avater/upload"  // 注意：API中拼写为avater
        case .image:
            return "/file/image/upload"
        case .general:
            return "/file/upload"
        }
    }
}

// MARK: - STS临时凭证响应
struct STSTokenResponse: Codable {
    let accessKeyId: String
    let accessKeySecret: String
    let securityToken: String
    let expiration: String
    let bucket: String
    let region: String
}

// MARK: - 上传签名响应
struct UploadSignatureResponse: Codable {
    let signature: String
    let policy: String
    let accessKeyId: String
    let dir: String
    let host: String
    let expire: Int64
}

// MARK: - 存储策略响应
struct StorageStrategy: Codable {
    let id: String
    let name: String
    let type: String
    let isDefault: Bool
}

// MARK: - 文件信息
struct FileInfo: Codable {
    let url: String
    let filename: String
    let size: Int?
    let mimeType: String?
}

// MARK: - Base64图片上传请求
struct ImageBase64UploadRequestDto: Codable {
    let base64: String
    let fileName: String
    let fileType: String
}

// MARK: - Base64图片上传响应
struct ImageUploadResponseDto: Codable {
    let url: String
    let fileName: String
}

// MARK: - 文件上传服务
class FileUploadService {
    static let shared = FileUploadService()

    private init() {}

    // MARK: - 图片上传

    /// 上传图片（使用base64方式）
    /// - Parameters:
    ///   - image: UIImage对象
    ///   - compressionQuality: 压缩质量（0.0-1.0），默认0.8
    /// - Returns: 上传后的图片URL
    func uploadImageBase64(
        _ image: UIImage,
        compressionQuality: CGFloat = 0.8
    ) async throws -> String {
        // 将图片转换为JPEG数据
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw APIError.networkError(NSError(
                domain: "FileUploadError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "图片数据转换失败"]
            ))
        }

        // 转换为base64字符串
        let base64String = imageData.base64EncodedString()

        // 生成文件名
        let filename = generateFilename(extension: "jpg")

        // 创建请求对象
        let request = ImageBase64UploadRequestDto(
            base64: base64String,
            fileName: filename,
            fileType: "image/jpeg"
        )

        // 调用API
        let response: APIResponse<ImageUploadResponseDto> = try await APIService.shared.request(
            endpoint: "/api/storage/uploadImg",
            method: .POST,
            body: request,
            requiresAuth: true
        )

        guard response.code == 200, let uploadResponse = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return uploadResponse.url
    }

    /// 上传图片（使用multipart/form-data方式）
    /// - Parameters:
    ///   - image: UIImage对象
    ///   - type: 上传类型（头像或普通图片）
    ///   - compressionQuality: 压缩质量（0.0-1.0），默认0.8
    /// - Returns: 上传后的图片URL
    func uploadImage(
        _ image: UIImage,
        type: UploadFileType = .image,
        compressionQuality: CGFloat = 0.8
    ) async throws -> String {
        // 将图片转换为JPEG数据
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw APIError.networkError(NSError(
                domain: "FileUploadError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "图片数据转换失败"]
            ))
        }

        // 生成文件名
        let filename = generateFilename(extension: "jpg")

        // 上传文件
        return try await uploadFile(
            data: imageData,
            filename: filename,
            mimeType: "image/jpeg",
            type: type
        )
    }

    /// 上传文件数据
    /// - Parameters:
    ///   - data: 文件数据
    ///   - filename: 文件名
    ///   - mimeType: MIME类型
    ///   - type: 上传类型
    /// - Returns: 上传后的文件URL
    func uploadFile(
        data: Data,
        filename: String,
        mimeType: String,
        type: UploadFileType = .general
    ) async throws -> String {
        let response: APIResponse<FileUploadResponse> = try await APIService.shared.uploadFile(
            endpoint: type.endpoint,
            fileData: data,
            fileName: filename,
            mimeType: mimeType,
            fieldName: "file"
        )

        guard response.code == 200, let fileInfo = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return fileInfo.url
    }

    // MARK: - STS临时凭证（用于客户端直传）

    /// 获取STS临时凭证
    /// - Returns: STS凭证信息
    func getSTSToken() async throws -> STSTokenResponse {
        let response: APIResponse<STSTokenResponse> = try await APIService.shared.request(
            endpoint: "/file/sts/token",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let stsToken = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return stsToken
    }

    /// 获取上传签名
    /// - Parameters:
    ///   - filename: 文件名
    ///   - mimeType: MIME类型
    /// - Returns: 上传签名信息
    func getUploadSignature(filename: String, mimeType: String) async throws -> UploadSignatureResponse {
        let response: APIResponse<UploadSignatureResponse> = try await APIService.shared.request(
            endpoint: "/file/signature",
            method: .POST,
            body: ["filename": filename, "mimeType": mimeType],
            requiresAuth: true
        )

        guard response.code == 200, let signature = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return signature
    }

    // MARK: - 文件管理

    /// 下载文件
    /// - Parameter fileUrl: 文件URL
    /// - Returns: 文件数据
    func downloadFile(fileUrl: String) async throws -> Data {
        let response: APIResponse<Data> = try await APIService.shared.request(
            endpoint: "/file/download",
            method: .GET,
            parameters: ["url": fileUrl],
            requiresAuth: true
        )

        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return data
    }

    /// 删除文件
    /// - Parameter filePath: 文件路径
    func deleteFile(filePath: String) async throws {
        let response: APIResponse<EmptyResponse> = try await APIService.shared.request(
            endpoint: "/file/remove",
            method: .POST,
            parameters: ["filePath": filePath],
            requiresAuth: true
        )

        guard response.code == 200 else {
            throw APIError.serverError(response.code, response.message)
        }
    }

    /// 检查文件是否存在
    /// - Parameter fileUrl: 文件URL
    /// - Returns: 文件是否存在
    func checkFileExists(fileUrl: String) async throws -> Bool {
        let response: APIResponse<Bool> = try await APIService.shared.request(
            endpoint: "/file/exists",
            method: .GET,
            parameters: ["url": fileUrl],
            requiresAuth: true
        )

        guard response.code == 200, let exists = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return exists
    }

    /// 获取存储策略列表
    /// - Returns: 存储策略列表
    func getStorageStrategies() async throws -> [StorageStrategy] {
        let response: APIResponse<[StorageStrategy]> = try await APIService.shared.request(
            endpoint: "/file/strategies",
            method: .GET,
            requiresAuth: true
        )

        guard response.code == 200, let strategies = response.data else {
            throw APIError.serverError(response.code, response.message)
        }

        return strategies
    }

    // MARK: - 辅助方法

    /// 生成唯一文件名
    /// - Parameter extension: 文件扩展名
    /// - Returns: 文件名
    private func generateFilename(extension fileExtension: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return "\(timestamp)_\(uuid).\(fileExtension)"
    }

    /// 获取图片的MIME类型
    /// - Parameter data: 图片数据
    /// - Returns: MIME类型
    func getMimeType(from data: Data) -> String {
        var byte: UInt8 = 0
        data.copyBytes(to: &byte, count: 1)

        switch byte {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x52 where data.count >= 12:
            let subdata = data.subdata(in: 0..<12)
            if let string = String(data: subdata, encoding: .ascii), string.hasPrefix("RIFF"), string.hasSuffix("WEBP") {
                return "image/webp"
            }
            return "application/octet-stream"
        default:
            return "application/octet-stream"
        }
    }
}

// MARK: - 图片压缩扩展
extension UIImage {
    /// 压缩图片到指定大小
    /// - Parameter maxSizeKB: 最大大小（KB）
    /// - Returns: 压缩后的图片数据
    func compressTo(maxSizeKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    /// 调整图片尺寸
    /// - Parameter targetSize: 目标尺寸
    /// - Returns: 调整后的图片
    func resized(to targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - 图片选择器结果处理
extension FileUploadService {
    /// 处理图片选择器返回的图片
    /// - Parameters:
    ///   - image: 选中的图片
    ///   - maxSize: 最大尺寸（默认1024x1024）
    ///   - maxSizeKB: 最大文件大小（默认500KB）
    ///   - type: 上传类型
    /// - Returns: 上传后的图片URL
    func processAndUploadImage(
        _ image: UIImage,
        maxSize: CGSize = CGSize(width: 1024, height: 1024),
        maxSizeKB: Int = 500,
        type: UploadFileType = .image
    ) async throws -> String {
        // 调整图片尺寸
        let resizedImage = image.resized(to: maxSize) ?? image

        // 压缩图片
        guard let imageData = resizedImage.compressTo(maxSizeKB: maxSizeKB) else {
            throw APIError.networkError(NSError(
                domain: "FileUploadError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "图片压缩失败"]
            ))
        }

        // 生成文件名
        let filename = generateFilename(extension: "jpg")

        // 上传文件
        return try await uploadFile(
            data: imageData,
            filename: filename,
            mimeType: "image/jpeg",
            type: type
        )
    }
}
