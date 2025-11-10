# ThingZ iOS API集成使用指南

## 目录

- [概述](#概述)
- [项目结构](#项目结构)
- [环境配置](#环境配置)
- [API服务模块](#api服务模块)
- [使用示例](#使用示例)
- [错误处理](#错误处理)
- [最佳实践](#最佳实践)

---

## 概述

ThingZ iOS项目已完成后端API的完整对接，包括以下功能模块：

1. **用户认证** - 登录、注册、退出、密码管理
2. **用户管理** - 用户信息查询和更新
3. **容器管理** - 容器的增删改查
4. **物品管理** - 物品的完整CRUD操作
5. **文件上传** - 图片和文件上传服务

---

## 项目结构

```
ThingZ/ThingZ/Models/
├── APIService.swift           # API基础服务层
├── AuthManager.swift          # 认证管理（已更新）
├── UserAPIService.swift       # 用户API服务
├── ContainerAPIService.swift  # 容器API服务
├── ItemAPIService.swift       # 物品API服务
├── FileUploadService.swift    # 文件上传服务
└── DataManager.swift          # 数据管理（已更新）
```

---

## 环境配置

### API基础地址配置

在 `APIService.swift` 中配置：

```swift
struct APIConfig {
    static let devBaseURL = "http://192.168.3.118:8080/thingz/api/v1"
    static let prodBaseURL = "https://api.epicfish.cn/thingz/api/v1"

    static var baseURL: String {
        #if DEBUG
        return devBaseURL  // 开发环境
        #else
        return prodBaseURL  // 生产环境
        #endif
    }
}
```

### 切换环境

- **开发环境**: 使用本地服务器 `http://192.168.3.118:8080`
- **生产环境**: 使用线上服务器 `https://api.epicfish.cn`

通过 Xcode 的 Build Configuration 自动切换。

---

## API服务模块

### 1. 认证服务 (AuthManager)

#### 登录

```swift
// 账号密码登录
Task {
    let result = await AuthManager.shared.loginWithUsername("13800138000", password: "123456")
    switch result {
    case .success(let user):
        print("登录成功: \(user.username)")
    case .failure(let error):
        print("登录失败: \(error)")
    case .needsProfileSetup(let phone):
        print("需要完善个人信息")
    }
}

// 短信验证码登录
Task {
    // 先发送验证码
    let sent = await AuthManager.shared.sendVerificationCode(to: "13800138000")
    if sent {
        // 使用验证码登录
        let result = await AuthManager.shared.loginWithPhone("13800138000", verificationCode: "123456")
    }
}
```

#### 注册

```swift
Task {
    do {
        let user = try await AuthManager.shared.register(
            phone: "13800138000",
            password: "123456",
            code: "验证码"
        )
        print("注册成功: \(user.username)")
    } catch {
        print("注册失败: \(error.localizedDescription)")
    }
}
```

#### 退出登录

```swift
// 本地退出
AuthManager.shared.logout()

// 调用API退出
Task {
    try? await AuthManager.shared.logoutFromServer()
}
```

### 2. 用户管理服务 (UserAPIService)

#### 获取用户信息

```swift
Task {
    do {
        // 获取当前用户信息
        let userInfo = try await UserAPIService.shared.getCurrentUserInfo()
        print("用户名: \(userInfo.username ?? "")")
        print("手机号: \(userInfo.phone)")
        print("邮箱: \(userInfo.email ?? "")")

        // 刷新AuthManager中的用户信息
        try await AuthManager.shared.refreshUserInfo()
    } catch {
        print("获取用户信息失败: \(error.localizedDescription)")
    }
}
```

#### 更新用户信息

```swift
Task {
    do {
        // 更新昵称
        try await AuthManager.shared.updateNickname(nick: "新昵称")

        // 更新头像
        try await AuthManager.shared.updateAvatar(avatarUrl: "https://...")

        // 修改密码
        try await AuthManager.shared.changePassword(
            oldPassword: "旧密码",
            newPassword: "新密码"
        )
    } catch {
        print("更新失败: \(error.localizedDescription)")
    }
}
```

### 3. 容器管理服务 (ContainerAPIService)

#### 获取容器列表

```swift
Task {
    do {
        let containers = try await ContainerAPIService.shared.getContainers()
        print("获取到 \(containers.count) 个容器")

        // 转换为本地模型
        let localContainers = containers.map { Container.from(apiContainer: $0) }
    } catch {
        print("获取容器列表失败: \(error.localizedDescription)")
    }
}
```

#### 创建容器

```swift
Task {
    do {
        let request = CreateContainerRequest(
            name: "我的衣柜",
            category: "衣柜",
            location: "卧室",
            description: "主卧大衣柜",
            capacity: 50,
            room: "主卧",
            floor: "2楼",
            isShareable: false,
            isExpirationReminder: true,
            imageUrl: nil
        )

        let container = try await ContainerAPIService.shared.createContainer(request: request)
        print("创建成功: \(container.name)")
    } catch {
        print("创建失败: \(error.localizedDescription)")
    }
}
```

#### 更新容器

```swift
Task {
    do {
        let request = UpdateContainerAPIRequest(
            name: "更新后的名称",
            category: "衣柜",
            location: "主卧",
            description: nil,
            capacity: 60,
            room: nil,
            floor: nil,
            isShareable: nil,
            isExpirationReminder: nil,
            imageUrl: nil
        )

        let updated = try await ContainerAPIService.shared.updateContainer(
            containerId: "容器ID",
            request: request
        )
        print("更新成功")
    } catch {
        print("更新失败: \(error.localizedDescription)")
    }
}
```

#### 删除容器

```swift
Task {
    do {
        try await ContainerAPIService.shared.deleteContainer(containerId: "容器ID")
        print("删除成功")
    } catch {
        print("删除失败: \(error.localizedDescription)")
    }
}
```

#### 生成二维码

```swift
Task {
    do {
        let qrCodeUrl = try await ContainerAPIService.shared.generateQRCode(containerId: "容器ID")
        print("二维码URL: \(qrCodeUrl)")
    } catch {
        print("生成二维码失败: \(error.localizedDescription)")
    }
}
```

### 4. 物品管理服务 (ItemAPIService)

#### 获取物品列表

```swift
Task {
    do {
        // 获取所有物品
        let items = try await ItemAPIService.shared.getItems(page: 0, size: 20)

        // 搜索物品
        let searchResults = try await ItemAPIService.shared.getItems(
            page: 0,
            size: 20,
            keyword: "牛奶"
        )

        // 获取容器中的物品
        let containerItems = try await ItemAPIService.shared.getItemsByContainer(
            containerId: "容器ID"
        )

        // 获取即将过期的物品
        let nearExpiration = try await ItemAPIService.shared.getNearExpirationItems(days: 7)

        // 获取已过期的物品
        let expired = try await ItemAPIService.shared.getExpiredItems()
    } catch {
        print("获取物品失败: \(error.localizedDescription)")
    }
}
```

#### 创建物品

```swift
Task {
    do {
        let request = CreateItemRequest(
            name: "牛奶",
            category: "食品",
            containerId: "容器ID",
            quantity: 2,
            unit: "盒",
            imageUrl: nil,
            description: "全脂牛奶",
            purchaseDate: "2024-01-01",
            expirationDate: "2024-02-01",
            price: 15.5,
            brand: "蒙牛",
            model: nil,
            status: "IN_CONTAINER"
        )

        let item = try await ItemAPIService.shared.createItem(request: request)
        print("创建成功: \(item.name)")
    } catch {
        print("创建失败: \(error.localizedDescription)")
    }
}
```

#### 更新物品

```swift
Task {
    do {
        let request = UpdateItemRequest(
            name: "新名称",
            category: nil,
            containerId: nil,
            quantity: 3,
            unit: nil,
            imageUrl: nil,
            description: "更新描述",
            purchaseDate: nil,
            expirationDate: nil,
            price: nil,
            brand: nil,
            model: nil,
            status: nil
        )

        let updated = try await ItemAPIService.shared.updateItem(
            itemId: "物品ID",
            request: request
        )
        print("更新成功")
    } catch {
        print("更新失败: \(error.localizedDescription)")
    }
}
```

#### 物品状态操作

```swift
Task {
    do {
        // 移动物品到另一个容器
        try await ItemAPIService.shared.moveItem(
            itemId: "物品ID",
            containerId: "目标容器ID"
        )

        // 放入物品
        try await ItemAPIService.shared.putInItem(
            itemId: "物品ID",
            containerId: "容器ID"
        )

        // 取出物品
        try await ItemAPIService.shared.takeOutItem(itemId: "物品ID")

        // 批量更新状态
        try await ItemAPIService.shared.batchUpdateItemStatus(
            request: BatchUpdateStatusRequest(
                itemIds: ["id1", "id2"],
                status: "TAKEN_OUT"
            )
        )
    } catch {
        print("操作失败: \(error.localizedDescription)")
    }
}
```

#### 删除物品

```swift
Task {
    do {
        // 删除单个物品
        try await ItemAPIService.shared.deleteItem(itemId: "物品ID")

        // 批量删除
        try await ItemAPIService.shared.batchDeleteItems(itemIds: ["id1", "id2", "id3"])
    } catch {
        print("删除失败: \(error.localizedDescription)")
    }
}
```

#### 统计查询

```swift
Task {
    do {
        // 按分类统计
        let categoryCount = try await ItemAPIService.shared.getItemCountByCategory()
        print("分类统计: \(categoryCount)")

        // 按状态统计
        let statusCount = try await ItemAPIService.shared.getItemCountByStatus()
        print("状态统计: \(statusCount)")

        // 统计容器物品数量
        let containerCount = try await ItemAPIService.shared.getItemCountByContainer(
            containerId: "容器ID"
        )
        print("容器物品数: \(containerCount)")
    } catch {
        print("统计失败: \(error.localizedDescription)")
    }
}
```

### 5. 文件上传服务 (FileUploadService)

#### 上传图片

```swift
Task {
    do {
        // 方式1: 直接上传UIImage
        let image = UIImage(named: "sample")!
        let imageUrl = try await FileUploadService.shared.uploadImage(
            image,
            type: .image,
            compressionQuality: 0.8
        )
        print("图片URL: \(imageUrl)")

        // 方式2: 处理并上传（自动压缩和调整尺寸）
        let processedUrl = try await FileUploadService.shared.processAndUploadImage(
            image,
            maxSize: CGSize(width: 1024, height: 1024),
            maxSizeKB: 500,
            type: .image
        )

        // 上传头像
        let avatarUrl = try await FileUploadService.shared.uploadImage(
            avatarImage,
            type: .avatar
        )

        // 更新用户头像
        try await AuthManager.shared.updateAvatar(avatarUrl: avatarUrl)
    } catch {
        print("上传失败: \(error.localizedDescription)")
    }
}
```

#### 上传文件数据

```swift
Task {
    do {
        let fileData = Data() // 文件数据
        let fileUrl = try await FileUploadService.shared.uploadFile(
            data: fileData,
            filename: "document.pdf",
            mimeType: "application/pdf",
            type: .general
        )
        print("文件URL: \(fileUrl)")
    } catch {
        print("上传失败: \(error.localizedDescription)")
    }
}
```

#### 图片选择器集成示例

```swift
import PhotosUI

struct ImagePickerView: View {
    @State private var selectedImage: UIImage?
    @State private var uploadedUrl: String?
    @State private var isLoading = false

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }

            Button("选择图片") {
                // 使用PhotosPicker
            }

            if isLoading {
                ProgressView("上传中...")
            }
        }
    }

    func uploadImage(_ image: UIImage) {
        isLoading = true
        Task {
            do {
                let url = try await FileUploadService.shared.processAndUploadImage(
                    image,
                    type: .image
                )
                await MainActor.run {
                    uploadedUrl = url
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("上传失败: \(error.localizedDescription)")
            }
        }
    }
}
```

---

## 错误处理

### API错误类型

```swift
enum APIError: Error, LocalizedError {
    case invalidURL          // 无效URL
    case invalidResponse     // 无效响应
    case networkError(Error) // 网络错误
    case serverError(Int, String) // 服务器错误
    case decodingError(Error)     // 解析错误
    case unauthorized        // 未授权
    case forbidden          // 权限不足
    case notFound           // 资源不存在
}
```

### 错误处理示例

```swift
Task {
    do {
        let items = try await ItemAPIService.shared.getItems()
        // 处理成功结果
    } catch APIError.unauthorized {
        // 未授权，需要重新登录
        AuthManager.shared.logout()
        // 跳转到登录页面
    } catch APIError.networkError(let error) {
        // 网络错误
        print("网络错误: \(error.localizedDescription)")
    } catch APIError.serverError(let code, let message) {
        // 服务器错误
        print("服务器错误 (\(code)): \(message)")
    } catch {
        // 其他错误
        print("未知错误: \(error.localizedDescription)")
    }
}
```

---

## 最佳实践

### 1. Token自动刷新

```swift
// 在API请求失败时自动刷新Token
extension APIService {
    func requestWithAutoRefresh<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil
    ) async throws -> APIResponse<T> {
        do {
            return try await request(
                endpoint: endpoint,
                method: method,
                body: body,
                requiresAuth: true
            )
        } catch APIError.unauthorized {
            // Token过期，尝试刷新
            // 实现刷新逻辑...
            throw APIError.unauthorized
        }
    }
}
```

### 2. 网络请求Loading状态

```swift
struct ContentView: View {
    @State private var isLoading = false
    @State private var items: [APIItem] = []

    var body: some View {
        ZStack {
            List(items, id: \.id) { item in
                Text(item.name)
            }

            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
        .task {
            await loadItems()
        }
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await ItemAPIService.shared.getItems()
        } catch {
            // 处理错误
        }
    }
}
```

### 3. 数据缓存策略

```swift
class DataCache {
    static let shared = DataCache()

    private var containerCache: [APIContainerItem] = []
    private var lastFetchTime: Date?

    func getContainers(forceRefresh: Bool = false) async throws -> [APIContainerItem] {
        // 如果缓存有效且不强制刷新，返回缓存
        if !forceRefresh,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 300, // 5分钟缓存
           !containerCache.isEmpty {
            return containerCache
        }

        // 从API获取最新数据
        let containers = try await ContainerAPIService.shared.getContainers()
        containerCache = containers
        lastFetchTime = Date()
        return containers
    }
}
```

### 4. 下拉刷新集成

```swift
struct ItemListView: View {
    @State private var items: [APIItem] = []

    var body: some View {
        List(items, id: \.id) { item in
            Text(item.name)
        }
        .refreshable {
            await refreshItems()
        }
    }

    func refreshItems() async {
        do {
            items = try await ItemAPIService.shared.getItems()
        } catch {
            print("刷新失败: \(error.localizedDescription)")
        }
    }
}
```

### 5. 分页加载

```swift
class ItemListViewModel: ObservableObject {
    @Published var items: [APIItem] = []
    @Published var isLoading = false
    @Published var hasMore = true

    private var currentPage = 0
    private let pageSize = 20

    func loadMore() async {
        guard !isLoading, hasMore else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let newItems = try await ItemAPIService.shared.getItems(
                page: currentPage,
                size: pageSize
            )

            await MainActor.run {
                items.append(contentsOf: newItems)
                currentPage += 1
                hasMore = newItems.count == pageSize
            }
        } catch {
            print("加载失败: \(error.localizedDescription)")
        }
    }
}
```

---

## 完整集成示例

查看以下文件以了解完整的集成示例：

- `ContainerListView.swift` - 容器列表集成
- `ProfileView.swift` - 用户信息更新集成
- `LoginView.swift` - 登录认证集成

---

## 注意事项

1. **所有API调用都应该在异步上下文中进行**（使用 `async/await`）
2. **UI更新必须在MainActor中执行**
3. **敏感操作（删除、修改）建议添加二次确认**
4. **图片上传前建议进行压缩处理**
5. **网络请求失败时应提供友好的错误提示**
6. **Token过期时应引导用户重新登录**

---

## 下一步

1. 在各个View中集成对应的API调用
2. 实现完整的错误处理和用户提示
3. 添加网络请求的Loading状态
4. 实现数据缓存和离线支持
5. 添加单元测试和集成测试
