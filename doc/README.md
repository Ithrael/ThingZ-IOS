# ThingZ API 对接文档目录

## 📚 文档列表

### 1. [快速开始.md](./快速开始.md) ⭐ **推荐首先阅读**
- 快速上手指南
- 核心功能示例
- 常见问题解答
- 适合：快速了解如何使用API

### 2. [API接口文档.md](./API接口文档.md)
- 完整的42个API接口清单
- 每个接口的详细参数说明
- 数据模型定义
- 错误码说明
- 适合：查询具体接口用法

### 3. [API集成使用指南.md](./API集成使用指南.md)
- 详细的代码示例
- 各模块使用说明
- 最佳实践建议
- 完整的集成案例
- 适合：深入学习和集成开发

### 4. [API对接总结报告.md](./API对接总结报告.md)
- 项目完成情况统计
- 技术架构说明
- 后续工作建议
- 适合：了解整体项目情况

---

## 🚀 快速导航

### 我想...

#### 快速开始使用
👉 阅读 [快速开始.md](./快速开始.md)

#### 查询某个API接口
👉 查看 [API接口文档.md](./API接口文档.md)

#### 查看代码示例
👉 参考 [API集成使用指南.md](./API集成使用指南.md)

#### 了解项目全貌
👉 查看 [API对接总结报告.md](./API对接总结报告.md)

---

## 📦 代码文件位置

```
ThingZ/ThingZ/Models/
├── APIService.swift           # API基础服务
├── UserAPIService.swift       # 用户API服务
├── ContainerAPIService.swift  # 容器API服务
├── ItemAPIService.swift       # 物品API服务
└── FileUploadService.swift    # 文件上传服务
```

---

## 🔗 API基础信息

**开发环境**: `http://192.168.3.118:8080/thingz/api/v1`

**生产环境**: `https://api.epicfish.cn/thingz/api/v1`

**API文档**: http://192.168.3.118:8080/thingz/api/doc.html

---

## ✅ 完成情况

| 模块 | 接口数 | 状态 |
|------|--------|------|
| 用户认证 | 8 | ✅ 完成 |
| 用户管理 | 6 | ✅ 完成 |
| 容器管理 | 8 | ✅ 完成 |
| 物品管理 | 18 | ✅ 完成 |
| 文件上传 | 9 | ✅ 完成 |
| **总计** | **49** | **100%** |

---

## 💡 使用示例

### 登录
```swift
let result = await AuthManager.shared.loginWithUsername("13800138000", password: "123456")
```

### 获取容器
```swift
let containers = try await ContainerAPIService.shared.getContainers()
```

### 上传图片
```swift
let url = try await FileUploadService.shared.uploadImage(image, type: .image)
```

---

## 📞 需要帮助？

1. 查看对应文档的详细说明
2. 参考代码中的注释
3. 查看API在线文档

---

**祝开发顺利！** 🎉
