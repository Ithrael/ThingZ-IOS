# ThingZ iOS API对接待办清单

## 项目概述

本文档记录ThingZ iOS应用所有API接口的对接进度，基于[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)接口文档生成。

**API Base URL**: `https://api.anyongtech.cn` (生产环境) / `http://192.168.3.118:8080/thingz/api/v1` (开发环境)

---

## 1. 用户管理接口 (User APIs)

### 1.1 用户信息查询

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 获取当前用户信息 | GET | `/v1/user/info` | ✅ 已完成 | UserAPIService.getCurrentUserInfo() |
| 根据ID获取用户信息 | GET | `/v1/user/{userId}` | ✅ 已完成 | UserAPIService.getUserInfo(userId:) |

### 1.2 用户信息更新

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 更新当前用户信息 | POST | `/v1/user/modify-info` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 更新当前用户密码 | POST | `/v1/user/change-password` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 更新当前用户头像 | POST | `/v1/user/change-avatar` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 更新当前用户昵称 | POST | `/v1/user/change-nick` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 更新指定用户信息 | POST | `/v1/user/modify/{userId}` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |

**待完善功能**：
- [ ] 调整接口路径和HTTP方法以匹配API文档
- [ ] 完善请求参数模型
- [ ] 添加完整的错误处理

---

## 2. 容器管理接口 (Container APIs)

### 2.1 容器CRUD操作

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 获取容器列表 | GET | `/v1/containers` | ✅ 已完成 | ContainerAPIService.getContainers() |
| 创建容器 | POST | `/v1/containers` | ✅ 已完成 | ContainerAPIService.createContainer() |
| 获取容器详情 | GET | `/v1/containers/{id}` | ✅ 已完成 | ContainerAPIService.getContainerDetail() |
| 更新容器信息 | POST | `/v1/containers/modify/{id}` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 删除容器 | POST | `/v1/containers/remove/{id}` | ⚠️ 需调整 | 需将DELETE改为POST，路径调整 |

### 2.2 容器物品管理

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 获取容器内物品 | GET | `/v1/containers/{id}/items` | ✅ 已完成 | ContainerAPIService.getContainerItems() |

### 2.3 容器功能扩展

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 生成二维码 | POST | `/v1/containers/{id}/qrcode` | ✅ 已完成 | ContainerAPIService.generateQRCode() |
| 绑定NFC标签 | POST | `/v1/containers/{id}/nfc` | ✅ 已完成 | ContainerAPIService.bindNFC() |

**待完善功能**：
- [ ] 调整更新和删除接口的路径和HTTP方法
- [ ] 完善容器分类枚举映射
- [ ] 添加容器共享相关功能

---

## 3. 物品管理接口 (Item APIs)

### 3.1 物品CRUD操作

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 创建物品 | POST | `/v1/items` | ✅ 已完成 | ItemAPIService.createItem() |
| 删除物品 | POST | `/v1/items/remove/{id}` | ⚠️ 需调整 | 需将DELETE改为POST，路径调整 |
| 批量删除物品 | POST | `/v1/items/batch/remove` | ⚠️ 需调整 | 路径需调整 |
| 更新物品 | POST | `/v1/items/modify/{id}` | ⚠️ 需调整 | 需将PUT改为POST，路径调整 |
| 获取物品详情 | GET | `/v1/items/{id}` | ✅ 已完成 | ItemAPIService.getItemDetail() |
| 查询物品列表 | GET | `/v1/items` | ✅ 已完成 | ItemAPIService.getItems()，支持分页和搜索 |

### 3.2 物品查询功能

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 根据容器ID查询物品 | GET | `/v1/items/container/{containerId}` | ✅ 已完成 | ItemAPIService.getItemsByContainer() |
| 根据状态查询物品 | GET | `/v1/items/status/{status}` | ✅ 已完成 | ItemAPIService.getItemsByStatus() |
| 查询即将过期的物品 | GET | `/v1/items/near-expiration` | ✅ 已完成 | ItemAPIService.getNearExpirationItems() |
| 查询已过期的物品 | GET | `/v1/items/expired` | ✅ 已完成 | ItemAPIService.getExpiredItems() |
| 根据分类查询物品 | GET | `/v1/items/category/{category}` | ✅ 已完成 | ItemAPIService.getItemsByCategory() |

### 3.3 物品状态管理

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 批量更新物品状态 | POST | `/v1/items/batch/change-status` | ⚠️ 需调整 | 路径需调整 |
| 移动物品到容器 | POST | `/v1/items/{itemId}/move-to-container` | ⚠️ 需调整 | 路径需调整 |
| 取出物品 | POST | `/v1/items/{itemId}/take-out-item` | ⚠️ 需调整 | 路径需调整 |
| 放入物品 | POST | `/v1/items/{itemId}/put-in-container` | ⚠️ 需调整 | 路径需调整 |

### 3.4 物品统计功能

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 统计容器中的物品数量 | GET | `/v1/items/count/container/{containerId}` | ✅ 已完成 | ItemAPIService.getItemCountByContainer() |
| 统计各状态物品数量 | GET | `/v1/items/count/status` | ✅ 已完成 | ItemAPIService.getItemCountByStatus() |
| 统计各分类物品数量 | GET | `/v1/items/count/category` | ✅ 已完成 | ItemAPIService.getItemCountByCategory() |

**待完善功能**：
- [ ] 调整接口路径和HTTP方法以匹配API文档
- [ ] 完善物品状态枚举
- [ ] 完善物品分类映射
- [ ] 添加物品标签(tags)支持

---

## 4. 小屋管理接口 (Cabin APIs)

### 4.1 小屋CRUD操作

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 获取小屋列表 | GET | `/v1/cabins` | ❌ 未实现 | 需创建CabinAPIService |
| 创建小屋 | POST | `/v1/cabins` | ❌ 未实现 | - |
| 获取小屋详情 | GET | `/v1/cabins/{id}` | ❌ 未实现 | - |
| 更新小屋信息 | POST | `/v1/cabins/modify/{id}` | ❌ 未实现 | - |
| 删除小屋 | POST | `/v1/cabins/remove/{id}` | ❌ 未实现 | - |

### 4.2 小屋成员管理

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 邀请成员 | POST | `/v1/cabins/{id}/invite` | ❌ 未实现 | - |
| 加入小屋 | POST | `/v1/cabins/{id}/join` | ❌ 未实现 | - |
| 移除成员 | POST | `/v1/cabins/{id}/remove-member/{userId}` | ❌ 未实现 | - |
| 更新成员权限 | POST | `/v1/cabins/{id}/change-permission/{userId}` | ❌ 未实现 | - |
| 获取小屋成员列表 | GET | `/v1/cabins/{id}/members` | ❌ 未实现 | - |
| 获取待处理邀请 | GET | `/v1/cabins/invitations/pending` | ❌ 未实现 | - |

**待实现功能**：
- [ ] 创建CabinAPIService类
- [ ] 定义小屋相关的请求和响应模型
- [ ] 实现所有小屋CRUD接口
- [ ] 实现成员管理接口
- [ ] 实现邀请机制
- [ ] 添加权限枚举(owner, admin, write, read)

---

## 5. 存储服务接口 (File Storage APIs)

### 5.1 文件上传

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 头像上传 | POST | `/v1/file/avater/upload` | ✅ 已完成 | FileUploadService.uploadImage(type: .avatar) |
| 图片上传 | POST | `/v1/file/image/upload` | ✅ 已完成 | FileUploadService.uploadImage(type: .image) |
| 文件上传 | POST | `/v1/file/upload` | ✅ 已完成 | FileUploadService.uploadFile() |

### 5.2 文件管理

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 文件下载 | GET | `/v1/file/download` | ✅ 已完成 | FileUploadService.downloadFile() |
| 文件删除 | POST | `/v1/file/remove` | ⚠️ 需调整 | 需将DELETE改为POST，路径调整 |
| 检查文件是否存在 | GET | `/v1/file/exists` | ✅ 已完成 | FileUploadService.checkFileExists() |

### 5.3 高级功能

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 生成签名URL | POST | `/v1/file/signature` | ✅ 已完成 | FileUploadService.getUploadSignature() |
| 生成STS Token | GET | `/v1/file/sts/token` | ✅ 已完成 | FileUploadService.getSTSToken() |
| 获取可用存储策略 | GET | `/v1/file/strategies` | ✅ 已完成 | FileUploadService.getStorageStrategies() |

**待完善功能**：
- [ ] 调整文件删除接口路径和方法
- [ ] 完善文件上传进度回调
- [ ] 添加大文件分片上传支持
- [ ] 优化图片压缩策略

---

## 6. 静态页面接口 (Static Pages)

| 接口 | 方法 | 路径 | 状态 | 说明 |
|------|------|------|------|------|
| 访问应用官网主页 | GET | `/v1/static/index` | ❌ 未实现 | 返回HTML页面，可用于分享 |
| 访问隐私政策页面 | GET | `/v1/static/privacy-policy` | ❌ 未实现 | 返回HTML页面，用于设置页面 |

**待实现功能**：
- [ ] 在应用内添加WebView展示静态页面
- [ ] 在设置页面添加隐私政策入口
- [ ] 在关于页面添加官网链接

---

## 7. ViewModel层集成

### 7.1 用户相关ViewModel

- [ ] **ProfileViewModel** - 集成用户信息查询和更新接口
  - [ ] 加载用户信息
  - [ ] 更新用户昵称
  - [ ] 更新用户头像
  - [ ] 修改密码功能

- [ ] **SettingsViewModel** - 集成用户设置相关接口
  - [ ] 账号设置
  - [ ] 隐私设置
  - [ ] 通知设置

### 7.2 容器相关ViewModel

- [ ] **ContainerViewModel** - 集成容器管理接口
  - [ ] 加载容器列表（已有部分实现）
  - [ ] 创建容器
  - [ ] 编辑容器
  - [ ] 删除容器
  - [ ] 下拉刷新容器列表

- [ ] **ContainerDetailViewModel** - 集成容器详情接口
  - [ ] 加载容器详情
  - [ ] 加载容器内物品
  - [ ] 生成二维码
  - [ ] 绑定NFC

### 7.3 物品相关ViewModel

- [ ] **ItemViewModel** - 集成物品管理接口
  - [ ] 创建物品
  - [ ] 编辑物品
  - [ ] 删除物品
  - [ ] 批量操作
  - [ ] 物品搜索

- [ ] **ItemDetailViewModel** - 集成物品详情接口
  - [ ] 加载物品详情
  - [ ] 移动物品
  - [ ] 取出/放入物品
  - [ ] 更新物品状态

- [ ] **ItemListViewModel** - 集成物品列表接口
  - [ ] 分页加载物品
  - [ ] 按分类筛选
  - [ ] 按状态筛选
  - [ ] 物品搜索

### 7.4 小屋相关ViewModel

- [ ] **CabinViewModel** - 创建并集成小屋管理接口
  - [ ] 加载小屋列表
  - [ ] 创建小屋
  - [ ] 编辑小屋
  - [ ] 删除小屋
  - [ ] 成员管理
  - [ ] 邀请处理

### 7.5 数据统计ViewModel

- [ ] **StatisticsViewModel** - 集成统计接口
  - [ ] 物品分类统计
  - [ ] 物品状态统计
  - [ ] 容器物品数量统计
  - [ ] 过期物品提醒

---

## 8. View层集成

### 8.1 用户相关View

- [ ] **ProfileView** - 个人信息页面
  - [ ] 展示用户信息
  - [ ] 编辑昵称
  - [ ] 更换头像

- [ ] **SettingsView** - 设置页面
  - [ ] 账号设置入口
  - [ ] 隐私政策入口
  - [ ] 修改密码入口

### 8.2 容器相关View

- [ ] **ContainerListView** - 容器列表页面（已有基础实现）
  - [x] 展示容器列表
  - [x] 下拉刷新
  - [ ] 创建容器按钮
  - [ ] 删除容器操作

- [ ] **AddContainerView** - 添加容器页面
  - [ ] 调用API创建容器
  - [ ] 图片上传

- [ ] **ContainerEditView** - 编辑容器页面
  - [ ] 调用API更新容器
  - [ ] 图片更新

- [ ] **ContainerDetailView** - 容器详情页面
  - [x] 展示容器详情
  - [x] 展示容器内物品
  - [x] 下拉刷新
  - [ ] 生成二维码功能
  - [ ] NFC绑定功能

### 8.3 物品相关View

- [ ] **ItemListView** - 物品列表页面
  - [ ] 分页加载
  - [ ] 搜索功能
  - [ ] 分类筛选
  - [ ] 状态筛选

- [ ] **AddItemView** - 添加物品页面
  - [ ] 调用API创建物品
  - [ ] 图片上传
  - [ ] 选择容器

- [ ] **ItemDetailView** - 物品详情页面
  - [ ] 展示物品详情
  - [ ] 移动物品功能
  - [ ] 取出/放入功能

- [ ] **SearchView** - 搜索页面
  - [ ] 物品搜索API集成
  - [ ] 搜索结果展示
  - [ ] 搜索历史

### 8.4 小屋相关View

- [ ] **CabinListView** - 创建小屋列表页面
  - [ ] 展示小屋列表
  - [ ] 创建小屋
  - [ ] 加入小屋

- [ ] **CabinDetailView** - 创建小屋详情页面
  - [ ] 展示小屋信息
  - [ ] 成员列表
  - [ ] 邀请成员
  - [ ] 成员权限管理

### 8.5 扫描相关View

- [ ] **QRCodeScannerView** - 二维码扫描页面
  - [ ] 扫描容器二维码
  - [ ] 跳转到容器详情

- [ ] **QRCodeGeneratorView** - 二维码生成页面
  - [ ] 调用API生成二维码
  - [ ] 展示二维码
  - [ ] 保存二维码

### 8.6 通知相关View

- [ ] **NotificationSettingsView** - 通知设置页面
  - [ ] 过期提醒设置
  - [ ] 推送通知设置

---

## 9. 数据模型完善

### 9.1 核心数据模型

- [ ] **User** - 用户模型
  - [ ] 添加更多用户属性（状态、创建时间等）

- [ ] **Container** - 容器模型
  - [ ] 完善容器属性（房间、楼层、共享状态等）
  - [ ] 添加二维码URL
  - [ ] 添加NFC标签ID

- [ ] **Item** - 物品模型
  - [ ] 完善物品属性（品牌、型号、颜色、标签等）
  - [ ] 添加购买日期和过期日期
  - [ ] 添加价格信息

- [ ] **Cabin** - 小屋模型（新增）
  - [ ] 创建Cabin数据模型
  - [ ] 创建CabinMember成员模型
  - [ ] 创建CabinInvitation邀请模型

### 9.2 枚举类型完善

- [ ] **ItemStatus** - 物品状态枚举
  - [x] 基础状态（in_use, stored等）
  - [ ] 完善状态映射

- [ ] **ContainerType** - 容器类型枚举
  - [x] 基础类型
  - [ ] 完善类型映射

- [ ] **ItemCategory** - 物品分类枚举
  - [ ] 与API文档分类对齐

- [ ] **CabinPermission** - 小屋权限枚举（新增）
  - [ ] owner, admin, write, read

---

## 10. 错误处理和用户体验优化

- [ ] **统一错误处理**
  - [ ] 完善APIError错误类型
  - [ ] 添加错误提示UI组件
  - [ ] 网络异常处理

- [ ] **加载状态管理**
  - [ ] 添加Loading指示器
  - [ ] 空状态展示
  - [ ] 错误状态展示

- [ ] **数据缓存**
  - [ ] 容器列表缓存
  - [ ] 物品列表缓存
  - [ ] 用户信息缓存

- [ ] **网络优化**
  - [ ] 请求防抖
  - [ ] 请求去重
  - [ ] 超时重试机制

---

## 11. 测试和文档

- [ ] **单元测试**
  - [ ] APIService测试
  - [ ] UserAPIService测试
  - [ ] ContainerAPIService测试
  - [ ] ItemAPIService测试
  - [ ] CabinAPIService测试
  - [ ] FileUploadService测试

- [ ] **集成测试**
  - [ ] API端到端测试
  - [ ] 文件上传测试
  - [ ] 认证流程测试

- [ ] **文档完善**
  - [ ] 代码注释
  - [ ] API使用示例
  - [ ] 错误码说明

---

## 总体进度统计

### 接口实现进度

- **用户管理**: 2/7 (28.6%)
  - ✅ 已完成: 2个查询接口
  - ⚠️ 需调整: 5个更新接口

- **容器管理**: 6/8 (75%)
  - ✅ 已完成: 6个接口
  - ⚠️ 需调整: 2个接口

- **物品管理**: 14/18 (77.8%)
  - ✅ 已完成: 14个接口
  - ⚠️ 需调整: 4个接口

- **小屋管理**: 0/11 (0%)
  - ❌ 未实现: 11个接口

- **存储服务**: 8/9 (88.9%)
  - ✅ 已完成: 8个接口
  - ⚠️ 需调整: 1个接口

- **静态页面**: 0/2 (0%)
  - ❌ 未实现: 2个接口

### 总体完成率

- **接口总数**: 55个
- **已完成**: 30个 (54.5%)
- **需调整**: 12个 (21.8%)
- **未实现**: 13个 (23.6%)

---

## 优先级建议

### P0 - 核心功能（必须完成）

1. 调整现有接口以匹配API文档规范
2. 完善容器和物品的CRUD操作
3. 集成文件上传到容器和物品创建流程
4. 完善用户信息更新功能

### P1 - 重要功能（高优先级）

1. 实现小屋管理完整功能
2. 实现物品过期提醒
3. 实现二维码生成和扫描
4. 完善数据统计功能

### P2 - 增强功能（中优先级）

1. NFC标签绑定
2. 小屋成员管理和权限控制
3. 数据缓存和离线支持
4. 批量操作优化

### P3 - 锦上添花（低优先级）

1. 静态页面展示
2. STS直传优化
3. 高级搜索和筛选
4. 数据导出功能

---

## 注意事项

1. **接口规范差异**:
   - 现有代码使用RESTful风格(PUT/DELETE)
   - API文档使用POST统一方法
   - **需要调整为POST方法以匹配后端实现**

2. **认证机制**:
   - 所有需要认证的接口使用Bearer Token
   - Token刷新机制已实现
   - 需要处理401错误并重新登录

3. **图片上传**:
   - 支持头像、普通图片和通用文件上传
   - 图片需要压缩处理
   - 建议最大尺寸1024x1024，最大500KB

4. **错误处理**:
   - 统一使用APIError
   - 友好的错误提示
   - 网络异常重试

5. **数据同步**:
   - 创建/更新后需要刷新列表
   - 考虑使用本地缓存
   - 下拉刷新功能

---

## 更新日志

- **2025-10-29**: 初始版本，基于API文档生成完整待办清单
