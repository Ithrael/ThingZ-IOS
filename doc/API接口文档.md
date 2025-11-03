# ThingZ API 接口文档

## 基础信息

**API基础URL**: `http://192.168.3.118:8080/thingz/api/v1`

**生产环境**: `https://api.epicfish.cn/thingz/api/v1`

**认证方式**: Bearer Token (在请求头中添加 `Authorization: Bearer {token}`)

---

## 接口清单

### 1. 用户认证模块 (Auth)

#### 1.1 用户注册
- **接口**: `POST /v1/auth/register`
- **描述**: 用户注册账号
- **请求参数**:
  ```json
  {
    "phone": "string",
    "password": "string",
    "code": "string"
  }
  ```

#### 1.2 账号密码登录
- **接口**: `POST /v1/auth/login`
- **描述**: 使用手机号和密码登录
- **状态**: ✅ 已实现 (AuthManager.swift:210)
- **请求参数**:
  ```json
  {
    "phone": "string",
    "password": "string",
    "rememberMe": true
  }
  ```
- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "string",
    "data": {
      "accessToken": "string",
      "refreshToken": "string",
      "tokenType": "Bearer",
      "expiresIn": 3600,
      "user": {
        "id": "string",
        "username": "string",
        "phone": "string",
        "email": "string",
        "avatarUrl": "string",
        "nick": "string"
      }
    }
  }
  ```

#### 1.3 发送短信验证码
- **接口**: `POST /v1/auth/send-sms-code`
- **描述**: 发送短信验证码
- **状态**: ✅ 已实现 (AuthManager.swift:465)
- **请求参数**:
  ```json
  {
    "phone": "string",
    "type": "login" | "register" | "reset"
  }
  ```

#### 1.4 短信验证码登录
- **接口**: `POST /v1/auth/sms-login`
- **描述**: 使用手机号和验证码登录
- **状态**: ✅ 已实现 (AuthManager.swift:340)
- **请求参数**:
  ```json
  {
    "phone": "string",
    "code": "string",
    "rememberMe": true
  }
  ```

#### 1.5 刷新Token
- **接口**: `POST /v1/auth/refresh`
- **描述**: 使用refreshToken刷新访问令牌
- **状态**: ⚠️ 待实现

#### 1.6 忘记密码
- **接口**: `POST /v1/auth/forgot-password`
- **描述**: 通过验证码重置密码
- **状态**: ⚠️ 待实现

#### 1.7 重置密码
- **接口**: `POST /v1/auth/reset-password`
- **描述**: 重置用户密码
- **状态**: ⚠️ 待实现

#### 1.8 退出登录
- **接口**: `POST /v1/auth/logout`
- **描述**: 用户退出登录
- **状态**: ⚠️ 待实现 (目前只是本地清除)

---

### 2. 用户管理模块 (User)

#### 2.1 获取当前用户信息
- **接口**: `GET /v1/user/info`
- **描述**: 获取当前登录用户的详细信息
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 2.2 更新当前用户信息
- **接口**: `PUT /v1/user/info`
- **描述**: 更新当前登录用户的基本信息
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 2.3 更新用户头像
- **接口**: `PUT /v1/user/avatar`
- **描述**: 更新当前用户头像URL
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **请求参数**:
  ```json
  {
    "avatarUrl": "string"
  }
  ```

#### 2.4 更新用户昵称
- **接口**: `PUT /v1/user/nick`
- **描述**: 更新当前用户昵称
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 2.5 更新用户密码
- **接口**: `PUT /v1/user/password`
- **描述**: 更新当前用户密码
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 2.6 根据ID获取用户信息
- **接口**: `GET /v1/user/{userId}`
- **描述**: 获取指定用户信息（需要管理员权限或本人）
- **认证**: 需要
- **状态**: ⚠️ 待实现

---

### 3. 容器管理模块 (Containers)

#### 3.1 获取容器列表
- **接口**: `GET /v1/containers`
- **描述**: 获取当前用户的所有容器
- **认证**: 需要
- **状态**: ✅ 已实现 (DataManager.swift:309)
- **响应数据**:
  ```json
  {
    "code": 200,
    "data": [
      {
        "id": "string",
        "name": "string",
        "category": "string",
        "location": "string",
        "description": "string",
        "capacity": 0,
        "status": "string",
        "imageUrl": "string",
        "qrCodeUrl": "string",
        "isShareable": false,
        "isExpirationReminder": false,
        "room": "string",
        "floor": "string"
      }
    ]
  }
  ```

#### 3.2 创建容器
- **接口**: `POST /v1/containers`
- **描述**: 创建新容器
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **请求参数**:
  ```json
  {
    "name": "string",
    "category": "string",
    "location": "string",
    "description": "string",
    "capacity": 0,
    "room": "string",
    "floor": "string",
    "isShareable": false,
    "isExpirationReminder": false,
    "imageUrl": "string"
  }
  ```

#### 3.3 获取容器详情
- **接口**: `GET /v1/containers/{id}`
- **描述**: 获取指定容器的详细信息
- **认证**: 需要
- **状态**: ✅ 已实现 (DataManager.swift:396)

#### 3.4 更新容器
- **接口**: `PUT /v1/containers/{id}`
- **描述**: 更新容器信息
- **认证**: 需要
- **状态**: ✅ 已实现 (DataManager.swift:452)

#### 3.5 删除容器
- **接口**: `DELETE /v1/containers/{id}`
- **描述**: 删除指定容器
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 3.6 获取容器中的物品
- **接口**: `GET /v1/containers/{id}/items`
- **描述**: 获取指定容器中的所有物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 3.7 生成容器二维码
- **接口**: `POST /v1/containers/{id}/qrcode`
- **描述**: 为容器生成二维码
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 3.8 绑定NFC标签
- **接口**: `POST /v1/containers/{id}/nfc`
- **描述**: 为容器绑定NFC标签
- **认证**: 需要
- **状态**: ⚠️ 待实现

---

### 4. 物品管理模块 (Items)

#### 4.1 获取物品列表
- **接口**: `GET /v1/items`
- **描述**: 获取当前用户的所有物品
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **查询参数**:
  - `page`: 页码
  - `size`: 每页数量
  - `sort`: 排序字段
  - `keyword`: 搜索关键词

#### 4.2 创建物品
- **接口**: `POST /v1/items`
- **描述**: 创建新物品
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **请求参数**:
  ```json
  {
    "name": "string",
    "category": "string",
    "containerId": "string",
    "quantity": 0,
    "unit": "string",
    "imageUrl": "string",
    "description": "string",
    "purchaseDate": "2024-01-01",
    "expirationDate": "2024-12-31",
    "price": 0,
    "brand": "string",
    "model": "string",
    "status": "IN_CONTAINER"
  }
  ```

#### 4.3 获取物品详情
- **接口**: `GET /v1/items/{id}`
- **描述**: 获取指定物品的详细信息
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.4 更新物品
- **接口**: `PUT /v1/items/{id}`
- **描述**: 更新物品信息
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.5 删除物品
- **接口**: `DELETE /v1/items/{id}`
- **描述**: 删除指定物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.6 批量删除物品
- **接口**: `DELETE /v1/items/batch`
- **描述**: 批量删除多个物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.7 批量更新物品状态
- **接口**: `PUT /v1/items/batch/status`
- **描述**: 批量更新物品状态
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.8 移动物品到容器
- **接口**: `PUT /v1/items/{itemId}/move`
- **描述**: 将物品移动到指定容器
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **查询参数**: `containerId`

#### 4.9 放入物品
- **接口**: `PUT /v1/items/{itemId}/put-in`
- **描述**: 将物品放入指定容器
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **查询参数**: `containerId`

#### 4.10 取出物品
- **接口**: `PUT /v1/items/{itemId}/take-out`
- **描述**: 将物品从容器中取出
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.11 获取容器中的物品
- **接口**: `GET /v1/items/container/{containerId}`
- **描述**: 获取指定容器中的所有物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.12 按分类获取物品
- **接口**: `GET /v1/items/category/{category}`
- **描述**: 获取指定分类的所有物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.13 按状态获取物品
- **接口**: `GET /v1/items/status/{status}`
- **描述**: 获取指定状态的所有物品
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.14 获取即将过期的物品
- **接口**: `GET /v1/items/near-expiration`
- **描述**: 获取即将过期的物品列表
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **查询参数**: `days` (多少天内过期，默认7天)

#### 4.15 获取已过期的物品
- **接口**: `GET /v1/items/expired`
- **描述**: 获取已过期的物品列表
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.16 统计分类物品数量
- **接口**: `GET /v1/items/count/category`
- **描述**: 按分类统计物品数量
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.17 统计状态物品数量
- **接口**: `GET /v1/items/count/status`
- **描述**: 按状态统计物品数量
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 4.18 统计容器物品数量
- **接口**: `GET /v1/items/count/container/{containerId}`
- **描述**: 统计指定容器中的物品数量
- **认证**: 需要
- **状态**: ⚠️ 待实现

---

### 5. 文件上传模块 (File)

#### 5.1 上传图片
- **接口**: `POST /v1/file/image/upload`
- **描述**: 上传物品或容器图片
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **请求**: multipart/form-data
- **参数**: `file` (图片文件)

#### 5.2 上传头像
- **接口**: `POST /v1/file/avater/upload`
- **描述**: 上传用户头像
- **认证**: 需要
- **状态**: ⚠️ 待实现
- **请求**: multipart/form-data
- **参数**: `file` (图片文件)

#### 5.3 通用文件上传
- **接口**: `POST /v1/file/upload`
- **描述**: 通用文件上传接口
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.4 获取STS临时凭证
- **接口**: `GET /v1/file/sts/token`
- **描述**: 获取对象存储临时凭证（用于直传）
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.5 获取上传签名
- **接口**: `POST /v1/file/signature`
- **描述**: 获取文件上传签名
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.6 下载文件
- **接口**: `GET /v1/file/download`
- **描述**: 下载文件
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.7 删除文件
- **接口**: `DELETE /v1/file/delete`
- **描述**: 删除已上传的文件
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.8 检查文件是否存在
- **接口**: `GET /v1/file/exists`
- **描述**: 检查文件是否存在
- **认证**: 需要
- **状态**: ⚠️ 待实现

#### 5.9 获取存储策略
- **接口**: `GET /v1/file/strategies`
- **描述**: 获取可用的文件存储策略列表
- **认证**: 需要
- **状态**: ⚠️ 待实现

---

### 6. 静态页面模块 (Static)

#### 6.1 首页
- **接口**: `GET /v1/static/index`
- **描述**: 获取应用官网首页
- **认证**: 不需要

#### 6.2 隐私政策
- **接口**: `GET /v1/static/privacy-policy`
- **描述**: 获取隐私政策页面
- **认证**: 不需要

---

## 数据模型定义

### 容器分类映射

| API category | iOS ContainerType | 中文名称 |
|--------------|-------------------|---------|
| 冰箱 | refrigerator | 冰箱 |
| 箱子 | box | 箱子 |
| 衣柜 | wardrobe | 衣柜 |
| 抽屉 | drawer | 抽屉 |
| 储物柜 | cabinet | 储物柜 |

### 物品分类映射

| API category | iOS ItemType | 中文名称 |
|--------------|--------------|---------|
| 服饰 | clothing | 服饰 |
| 食品 | food | 食品 |
| 化妆品 | cosmetics | 化妆品 |
| 杂物 | miscellaneous | 杂物 |

### 物品状态

- `IN_CONTAINER`: 在容器中
- `TAKEN_OUT`: 已取出
- `EXPIRED`: 已过期
- `NORMAL`: 正常

---

## 错误码定义

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（未登录或token失效） |
| 403 | 禁止访问（权限不足） |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 开发优先级

### 第一阶段（已完成）
- ✅ 用户认证（登录、短信验证码）
- ✅ 容器列表获取
- ✅ 容器详情获取
- ✅ 容器更新

### 第二阶段（待实现）
- ⚠️ 文件上传（头像、图片）
- ⚠️ 容器创建/删除
- ⚠️ 用户信息管理

### 第三阶段（待实现）
- ⚠️ 物品完整CRUD
- ⚠️ 物品状态管理
- ⚠️ 物品移动/取出/放入

### 第四阶段（待实现）
- ⚠️ 过期提醒
- ⚠️ 统计分析
- ⚠️ 二维码/NFC功能

---

## 注意事项

1. **认证Token**: 所有需要认证的接口都需要在请求头中添加 `Authorization: Bearer {token}`
2. **API地址切换**: 开发环境使用 `http://192.168.3.118:8080`，生产环境使用 `https://api.epicfish.cn`
3. **时间格式**: 统一使用 ISO8601 格式或 Unix 时间戳
4. **分页**: 列表接口支持分页参数 `page` 和 `size`
5. **图片上传**: 支持 multipart/form-data 上传或使用 STS 临时凭证直传到对象存储
