import Foundation
import UIKit
import CoreImage

class QRCodeGenerator {
    static func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        // 创建二维码滤镜
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        // 设置二维码内容
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // 高纠错级别
        
        // 获取生成的二维码图像
        guard let ciImage = filter.outputImage else { return nil }
        
        // 计算缩放比例
        let scale = min(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        
        // 创建变换
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // 应用变换
        let scaledCIImage = ciImage.transformed(by: transform)
        
        // 转换为UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    static func generateQRCodeWithLogo(from string: String, logo: UIImage? = nil, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        // 生成基础二维码
        guard let qrCodeImage = generateQRCode(from: string, size: size) else { return nil }
        
        // 如果没有提供logo，直接返回二维码
        guard let logo = logo else { return qrCodeImage }
        
        // 开始绘制
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // 绘制二维码
        qrCodeImage.draw(in: CGRect(origin: .zero, size: size))
        
        // 计算logo大小和位置（居中，大小为二维码的1/4）
        let logoSize = CGSize(width: size.width * 0.25, height: size.height * 0.25)
        let logoOrigin = CGPoint(
            x: (size.width - logoSize.width) / 2,
            y: (size.height - logoSize.height) / 2
        )
        
        // 绘制白色背景
        let logoBackgroundRect = CGRect(origin: logoOrigin, size: logoSize)
        UIColor.white.setFill()
        UIBezierPath(roundedRect: logoBackgroundRect, cornerRadius: 5).fill()
        
        // 绘制logo
        let logoRect = logoBackgroundRect.insetBy(dx: 5, dy: 5)
        logo.draw(in: logoRect)
        
        // 获取最终图像
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func generateContainerQRCode(container: Container) -> UIImage? {
        // 创建包含容器信息的JSON字符串
        let containerInfo: [String: Any] = [
            "id": container.id.uuidString,
            "name": container.name,
            "type": container.type.rawValue,
            "location": container.location
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: containerInfo),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        // 生成带应用logo的二维码
        // 这里可以使用应用的logo，暂时使用默认图标
        let logoImage = UIImage(systemName: container.type.icon)?.withTintColor(.systemPink)
        
        return generateQRCodeWithLogo(from: jsonString, logo: logoImage)
    }
}