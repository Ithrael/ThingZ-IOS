# ThingZ 接口文档

## 项目概述

ThingZ 是一个物品管理系统，提供物品、容器、小屋、用户管理和文件存储等功能。

## 基础信息

### Base URL

```
https://api.anyongtech.cn
```

### 认证方式

所有需要认证的接口都需要在请求头中携带用户身份信息。当前系统通过拦截器从请求头 `Authorization: Bearer <token>` 中获取用户ID。

### 通用响应格式

所有接口响应均采用统一格式：

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

- `code`: 状态码，200 表示成功，其他值表示失败
- `message`: 响应消息
- `data`: 响应数据，具体格式根据接口而定

---

## 1. 静态页面

### 1.1 访问应用官网主页

**接口地址**: `/v1/static/index`

**请求方法**: GET

**接口描述**: 提供ThingZ应用的官网主页，包含应用介绍和下载链接

**请求参数**: 无

**响应格式**: HTML页面

---

### 1.2 访问隐私政策页面

**接口地址**: `/v1/static/privacy-policy`

**请求方法**: GET

**接口描述**: 提供ThingZ应用的隐私政策页面

**请求参数**: 无

**响应格式**: HTML页面

---

## 2. 用户管理

### 2.1 获取当前用户信息

**接口地址**: `/v1/user/info`

**请求方法**: GET

**接口描述**: 获取当前登录用户的详细信息

**请求参数**: 无

**响应数据**:

```json
{
  "id": "user123",
  "username": "testuser",
  "nick": "测试用户",
  "email": "test@example.com",
  "phone": "13800138000",
  "avatarUrl": "https://example.com/avatar.jpg",
  "status": "active",
  "createdAt": "2024-01-01T00:00:00",
  "updatedAt": "2024-01-01T00:00:00"
}
```

---

### 2.2 根据ID获取用户信息

**接口地址**: `/v1/user/{userId}`

**请求方法**: GET

**接口描述**: 根据用户ID获取用户详细信息（需要管理员权限或本人）

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | String | 是 | 用户ID |

**响应数据**: 同 2.1

---

### 2.3 更新当前用户信息

**接口地址**: `/v1/user/modify-info`

**请求方法**: POST

**接口描述**: 更新当前登录用户的基本信息

**请求体**:

```json
{
  "nick": "新昵称",
  "avatarUrl": "https://example.com/new-avatar.jpg"
}
```

**响应数据**: 同 2.1

---

### 2.4 更新当前用户密码

**接口地址**: `/v1/user/change-password`

**请求方法**: POST

**接口描述**: 更新当前登录用户的密码

**请求体**:

```json
{
  "password": "newpassword123",
  "confirmPassword": "newpassword123"
}
```

**响应数据**: 同 2.1

---

### 2.5 更新当前用户头像

**接口地址**: `/v1/user/change-avatar`

**请求方法**: POST

**接口描述**: 更新当前登录用户的头像

**请求体**:

```json
{
  "avatarUrl": "https://example.com/new-avatar.jpg"
}
```

**响应数据**: 同 2.1

---

### 2.6 更新当前用户昵称

**接口地址**: `/v1/user/change-nick`

**请求方法**: POST

**接口描述**: 更新当前登录用户的昵称

**请求体**:

```json
{
  "nick": "新昵称"
}
```

**响应数据**: 同 2.1

---

### 2.7 更新指定用户信息

**接口地址**: `/v1/user/modify/{userId}`

**请求方法**: POST

**接口描述**: 更新指定用户的基本信息（需要管理员权限或本人）

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | String | 是 | 用户ID |

**请求体**: 同 2.3

**响应数据**: 同 2.1

---

## 3. 容器管理

### 3.1 获取容器列表

**接口地址**: `/v1/containers`

**请求方法**: GET

**接口描述**: 获取当前用户的所有容器

**请求参数**: 无

**响应数据**:

```json
[
  {
    "id": "container123",
    "name": "卧室抽屉",
    "location": "卧室",
    "description": "放置日常用品",
    "category": "storage",
    "isExpirationReminder": true,
    "room": "卧室",
    "floor": "2楼",
    "status": "active",
    "imageUrl": "https://example.com/container.jpg",
    "userId": "user123",
    "isShareable": false,
    "createdAt": "2024-01-01T00:00:00",
    "updatedAt": "2024-01-01T00:00:00"
  }
]
```

---

### 3.2 创建容器

**接口地址**: `/v1/containers`

**请求方法**: POST

**接口描述**: 创建新的容器

**请求体**:

```json
{
  "name": "卧室抽屉",
  "location": "卧室",
  "description": "放置日常用品",
  "category": "storage",
  "isExpirationReminder": true,
  "room": "卧室",
  "floor": "2楼",
  "status": "active",
  "imageUrl": "https://example.com/container.jpg"
}
```

**响应数据**: 同 3.1 单个容器对象

---

### 3.3 获取容器详情

**接口地址**: `/v1/containers/{id}`

**请求方法**: GET

**接口描述**: 根据ID获取容器详细信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**响应数据**: 同 3.1 单个容器对象

---

### 3.4 更新容器信息

**接口地址**: `/v1/containers/modify/{id}`

**请求方法**: POST

**接口描述**: 更新指定容器的信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**请求体**:

```json
{
  "name": "卧室抽屉",
  "location": "卧室",
  "description": "放置日常用品",
  "isExpirationReminder": true,
  "floor": "2楼",
  "room": "卧室",
  "imageUrl": "https://example.com/container.jpg",
  "isShareable": false
}
```

**响应数据**: 同 3.1 单个容器对象

---

### 3.5 删除容器

**接口地址**: `/v1/containers/remove/{id}`

**请求方法**: POST

**接口描述**: 删除指定的容器

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**响应数据**: 无

---

### 3.6 获取容器内物品

**接口地址**: `/v1/containers/{id}/items`

**请求方法**: GET

**接口描述**: 获取指定容器内的所有物品

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**响应数据**: 物品列表

---

### 3.7 生成二维码

**接口地址**: `/v1/containers/{id}/qrcode`

**请求方法**: POST

**接口描述**: 为容器生成二维码

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**响应数据**: 二维码URL字符串

---

### 3.8 绑定NFC标签

**接口地址**: `/v1/containers/{id}/nfc`

**请求方法**: POST

**接口描述**: 为容器绑定NFC标签

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 容器ID |

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| nfcTagId | String | 是 | NFC标签ID |

**响应数据**: 绑定结果字符串

---

## 4. 物品管理

### 4.1 创建物品

**接口地址**: `/v1/items`

**请求方法**: POST

**接口描述**: 添加新的物品到容器中

**请求体**:

```json
{
  "name": "蓝牙耳机",
  "description": "索尼WH-1000XM4",
  "category": "electronics",
  "quantity": 1,
  "unit": "个",
  "purchaseDate": "2024-01-01",
  "expirationDate": null,
  "price": 2499.00,
  "brand": "Sony",
  "model": "WH-1000XM4",
  "color": "黑色",
  "status": "in_use",
  "imageUrl": "https://example.com/item.jpg",
  "containerId": "container123",
  "tags": ["电子产品", "耳机"]
}
```

**响应数据**:

```json
{
  "id": "item123",
  "name": "蓝牙耳机",
  "description": "索尼WH-1000XM4",
  "category": "electronics",
  "quantity": 1,
  "unit": "个",
  "purchaseDate": "2024-01-01",
  "expirationDate": null,
  "price": 2499.00,
  "brand": "Sony",
  "model": "WH-1000XM4",
  "color": "黑色",
  "status": "in_use",
  "imageUrl": "https://example.com/item.jpg",
  "containerId": "container123",
  "userId": "user123",
  "tags": ["电子产品", "耳机"],
  "createdAt": "2024-01-01T00:00:00",
  "updatedAt": "2024-01-01T00:00:00"
}
```

---

### 4.2 删除物品

**接口地址**: `/v1/items/remove/{id}`

**请求方法**: POST

**接口描述**: 根据ID删除物品

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 物品ID |

**响应数据**: 无

---

### 4.3 批量删除物品

**接口地址**: `/v1/items/batch/remove`

**请求方法**: POST

**接口描述**: 根据ID列表批量删除物品

**请求体**:

```json
["item123", "item456", "item789"]
```

**响应数据**: 无

---

### 4.4 更新物品

**接口地址**: `/v1/items/modify/{id}`

**请求方法**: POST

**接口描述**: 根据ID更新物品信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 物品ID |

**请求体**: 同 4.1（字段可选）

**响应数据**: 同 4.1

---

### 4.5 获取物品详情

**接口地址**: `/v1/items/{id}`

**请求方法**: GET

**接口描述**: 根据ID获取物品详细信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 物品ID |

**响应数据**: 同 4.1

---

### 4.6 查询物品列表

**接口地址**: `/v1/items`

**请求方法**: GET

**接口描述**: 分页查询物品列表，支持多种条件筛选

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| name | String | 否 | 物品名称（模糊查询） |
| category | String | 否 | 分类 |
| status | String | 否 | 状态 |
| containerId | String | 否 | 容器ID |

**响应数据**:

```json
{
  "pageNum": 1,
  "pageSize": 10,
  "total": 100,
  "pages": 10,
  "list": [
    {
      // 物品对象，同 4.1
    }
  ]
}
```

---

### 4.7 根据容器ID查询物品

**接口地址**: `/v1/items/container/{containerId}`

**请求方法**: GET

**接口描述**: 获取指定容器中的所有物品

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| containerId | String | 是 | 容器ID |

**响应数据**: 物品列表（数组），同 4.1

---

### 4.8 根据状态查询物品

**接口地址**: `/v1/items/status/{status}`

**请求方法**: GET

**接口描述**: 获取指定状态的所有物品

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | String | 是 | 物品状态 |

**响应数据**: 物品列表（数组），同 4.1

---

### 4.9 查询即将过期的物品

**接口地址**: `/v1/items/near-expiration`

**请求方法**: GET

**接口描述**: 获取指定天数内即将过期的物品

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| days | Integer | 否 | 天数，默认7 |

**响应数据**: 物品列表（数组），同 4.1

---

### 4.10 查询已过期的物品

**接口地址**: `/v1/items/expired`

**请求方法**: GET

**接口描述**: 获取所有已过期的物品

**请求参数**: 无

**响应数据**: 物品列表（数组），同 4.1

---

### 4.11 根据分类查询物品

**接口地址**: `/v1/items/category/{category}`

**请求方法**: GET

**接口描述**: 获取指定分类的所有物品

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| category | String | 是 | 物品分类 |

**响应数据**: 物品列表（数组），同 4.1

---

### 4.12 批量更新物品状态

**接口地址**: `/v1/items/batch/change-status`

**请求方法**: POST

**接口描述**: 批量更新多个物品的状态

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | String | 是 | 新状态 |

**请求体**:

```json
["item123", "item456", "item789"]
```

**响应数据**: 无

---

### 4.13 移动物品到容器

**接口地址**: `/v1/items/{itemId}/move-to-container`

**请求方法**: POST

**接口描述**: 将物品移动到指定容器

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| itemId | String | 是 | 物品ID |

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| containerId | String | 是 | 目标容器ID |

**响应数据**: 无

---

### 4.14 取出物品

**接口地址**: `/v1/items/{itemId}/take-out-item`

**请求方法**: POST

**接口描述**: 将物品从容器中取出

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| itemId | String | 是 | 物品ID |

**响应数据**: 无

---

### 4.15 放入物品

**接口地址**: `/v1/items/{itemId}/put-in-container`

**请求方法**: POST

**接口描述**: 将物品放入指定容器

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| itemId | String | 是 | 物品ID |

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| containerId | String | 是 | 目标容器ID |

**响应数据**: 无

---

### 4.16 统计容器中的物品数量

**接口地址**: `/v1/items/count/container/{containerId}`

**请求方法**: GET

**接口描述**: 获取指定容器中的物品数量

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| containerId | String | 是 | 容器ID |

**响应数据**: 整数（物品数量）

---

### 4.17 统计各状态物品数量

**接口地址**: `/v1/items/count/status`

**请求方法**: GET

**接口描述**: 获取各状态物品的数量统计

**请求参数**: 无

**响应数据**:

```json
{
  "in_use": 50,
  "stored": 30,
  "damaged": 5,
  "discarded": 2
}
```

---

### 4.18 统计各分类物品数量

**接口地址**: `/v1/items/count/category`

**请求方法**: GET

**接口描述**: 获取各分类物品的数量统计

**请求参数**: 无

**响应数据**:

```json
{
  "electronics": 25,
  "clothing": 40,
  "food": 15,
  "books": 20
}
```

---

## 5. 小屋管理

### 5.1 获取小屋列表

**接口地址**: `/v1/cabins`

**请求方法**: GET

**接口描述**: 获取当前用户加入的所有小屋

**请求参数**: 无

**响应数据**:

```json
[
  {
    "id": "cabin123",
    "name": "我的家",
    "description": "家庭物品管理",
    "ownerId": "user123",
    "ownerNick": "张三",
    "maxMembers": 10,
    "currentMembers": 3,
    "status": "active",
    "createdAt": "2024-01-01T00:00:00",
    "updatedAt": "2024-01-01T00:00:00"
  }
]
```

---

### 5.2 创建小屋

**接口地址**: `/v1/cabins`

**请求方法**: POST

**接口描述**: 创建新的小屋

**请求体**:

```json
{
  "name": "我的家",
  "description": "家庭物品管理",
  "maxMembers": 10
}
```

**响应数据**: 同 5.1 单个小屋对象

---

### 5.3 获取小屋详情

**接口地址**: `/v1/cabins/{id}`

**请求方法**: GET

**接口描述**: 根据ID获取小屋详细信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**响应数据**: 同 5.1 单个小屋对象

---

### 5.4 更新小屋信息

**接口地址**: `/v1/cabins/modify/{id}`

**请求方法**: POST

**接口描述**: 更新指定小屋的信息

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**请求体**:

```json
{
  "name": "我的家",
  "description": "家庭物品管理",
  "maxMembers": 10,
  "status": "active"
}
```

**响应数据**: 同 5.1 单个小屋对象

---

### 5.5 删除小屋

**接口地址**: `/v1/cabins/remove/{id}`

**请求方法**: POST

**接口描述**: 删除指定的小屋

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**响应数据**: 无

---

### 5.6 邀请成员

**接口地址**: `/v1/cabins/{id}/invite`

**请求方法**: POST

**接口描述**: 邀请新成员加入小屋

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**请求体**:

```json
{
  "inviteeId": "user456",
  "permission": "read"
}
```

**响应数据**:

```json
{
  "id": "invitation123",
  "cabinId": "cabin123",
  "cabinName": "我的家",
  "inviterId": "user123",
  "inviterNick": "张三",
  "inviteeId": "user456",
  "inviteeNick": "李四",
  "permission": "read",
  "inviteCode": "ABC123",
  "status": "pending",
  "expiresAt": "2024-01-08T00:00:00",
  "createdAt": "2024-01-01T00:00:00"
}
```

---

### 5.7 加入小屋

**接口地址**: `/v1/cabins/{id}/join`

**请求方法**: POST

**接口描述**: 通过邀请码加入小屋

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**请求体**:

```json
{
  "inviteCode": "ABC123"
}
```

**响应数据**:

```json
{
  "cabinId": "cabin123",
  "cabinName": "我的家",
  "memberId": "member123",
  "permission": "read",
  "joinedAt": "2024-01-01T00:00:00"
}
```

---

### 5.8 移除成员

**接口地址**: `/v1/cabins/{id}/remove-member/{userId}`

**请求方法**: POST

**接口描述**: 从小屋中移除成员

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |
| userId | String | 是 | 成员ID |

**响应数据**: 无

---

### 5.9 更新成员权限

**接口地址**: `/v1/cabins/{id}/change-permission/{userId}`

**请求方法**: POST

**接口描述**: 更新小屋成员的权限

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |
| userId | String | 是 | 成员ID |

**请求体**:

```json
{
  "permission": "write"
}
```

**响应数据**: 无

---

### 5.10 获取小屋成员列表

**接口地址**: `/v1/cabins/{id}/members`

**请求方法**: GET

**接口描述**: 获取指定小屋的所有成员

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | String | 是 | 小屋ID |

**响应数据**:

```json
[
  {
    "id": "member123",
    "cabinId": "cabin123",
    "userId": "user123",
    "userNick": "张三",
    "avatarUrl": "https://example.com/avatar.jpg",
    "permission": "owner",
    "joinedAt": "2024-01-01T00:00:00"
  }
]
```

---

### 5.11 获取待处理邀请

**接口地址**: `/v1/cabins/invitations/pending`

**请求方法**: GET

**接口描述**: 获取当前用户的待处理邀请列表

**请求参数**: 无

**响应数据**: 邀请列表（数组），同 5.6

---

## 6. 存储服务

### 6.1 头像上传

**接口地址**: `/v1/file/avater/upload`

**请求方法**: POST

**接口描述**: 上传头像图片到指定的存储服务，并更新用户头像信息

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 图片文件（multipart/form-data） |

**响应数据**: 用户信息（同 2.1）

---

### 6.2 图片上传

**接口地址**: `/v1/file/image/upload`

**请求方法**: POST

**接口描述**: 上传图片到指定的存储服务

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 图片文件（multipart/form-data） |

**响应数据**:

```json
{
  "fileName": "example.jpg",
  "fileUrl": "https://oss.example.com/images/2024/01/example.jpg",
  "fileUrlCDN": "https://cdn.example.com/images/2024/01/example.jpg",
  "fileSize": 102400,
  "contentType": "image/jpeg",
  "uploadTime": "2024-01-01T00:00:00"
}
```

---

### 6.3 文件上传

**接口地址**: `/v1/file/upload`

**请求方法**: POST

**接口描述**: 上传文件到指定的存储服务

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 文件（multipart/form-data） |
| path | String | 是 | 存储路径，如 "images/2024/01/" |
| strategy | String | 否 | 存储策略，如 "aliyun-oss" |
| bucketName | String | 否 | 存储桶名称（MinIO专用） |
| userId | String | 否 | 用户ID |

**响应数据**: 同 6.2

---

### 6.4 文件下载

**接口地址**: `/v1/file/download`

**请求方法**: GET

**接口描述**: 从存储服务下载指定文件

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| filePath | String | 是 | 文件路径，如 "images/2024/01/example.jpg" |
| strategy | String | 否 | 存储策略，如 "aliyun-oss" |
| bucketName | String | 否 | 存储桶名称（MinIO专用） |
| userId | String | 否 | 用户ID |

**响应格式**: 文件流

---

### 6.5 文件删除

**接口地址**: `/v1/file/remove`

**请求方法**: POST

**接口描述**: 从存储服务删除指定文件

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| filePath | String | 是 | 文件路径，如 "images/2024/01/example.jpg" |
| strategy | String | 否 | 存储策略，如 "aliyun-oss" |
| bucketName | String | 否 | 存储桶名称（MinIO专用） |
| userId | String | 否 | 用户ID |

**响应数据**: 无

---

### 6.6 生成签名URL

**接口地址**: `/v1/file/signature`

**请求方法**: POST

**接口描述**: 生成文件的签名URL，支持临时访问

**请求体**:

```json
{
  "filePath": "images/2024/01/example.jpg",
  "strategy": "aliyun-oss",
  "bucketName": "my-bucket",
  "expireSeconds": 3600,
  "userId": "user123"
}
```

**响应数据**:

```json
{
  "filePath": "images/2024/01/example.jpg",
  "signedUrl": "https://oss.example.com/images/2024/01/example.jpg?signature=xxx",
  "expiresAt": "2024-01-01T01:00:00"
}
```

---

### 6.7 生成STS Token

**接口地址**: `/v1/file/sts/token`

**请求方法**: GET

**接口描述**: 生成阿里云STS临时凭证，用于前端直传

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | String | 否 | 用户ID |

**响应数据**:

```json
{
  "accessKeyId": "STS.xxx",
  "accessKeySecret": "xxx",
  "securityToken": "xxx",
  "expiration": "2024-01-01T01:00:00",
  "region": "oss-cn-hangzhou",
  "bucket": "my-bucket"
}
```

---

### 6.8 检查文件是否存在

**接口地址**: `/v1/file/exists`

**请求方法**: GET

**接口描述**: 检查指定文件是否存在于存储服务中

**查询参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| filePath | String | 是 | 文件路径，如 "images/2024/01/example.jpg" |
| strategy | String | 否 | 存储策略，如 "aliyun-oss" |
| bucketName | String | 否 | 存储桶名称（MinIO专用） |

**响应数据**: 布尔值（true/false）

---

### 6.9 获取可用存储策略

**接口地址**: `/v1/file/strategies`

**请求方法**: GET

**接口描述**: 获取当前系统支持的所有存储策略

**请求参数**: 无

**响应数据**:

```json
["aliyun-oss", "minio", "local"]
```

---

## 附录

### A. 物品状态枚举

| 状态值 | 说明 |
|--------|------|
| in_use | 使用中 |
| stored | 已存储 |
| borrowed | 已借出 |
| damaged | 已损坏 |
| discarded | 已丢弃 |

### B. 小屋成员权限枚举

| 权限值 | 说明 |
|--------|------|
| owner | 所有者（完全控制权） |
| admin | 管理员（管理成员和内容） |
| write | 写入权限（可编辑内容） |
| read | 只读权限（仅查看） |

### C. 容器分类建议

| 分类值 | 说明 |
|--------|------|
| storage | 普通储物 |
| refrigerator | 冰箱 |
| wardrobe | 衣柜 |
| bookshelf | 书架 |
| toolbox | 工具箱 |
| drawer | 抽屉 |

### D. 物品分类建议

| 分类值 | 说明 |
|--------|------|
| electronics | 电子产品 |
| clothing | 服装 |
| food | 食品 |
| books | 书籍 |
| tools | 工具 |
| toys | 玩具 |
| documents | 文档 |
| medicine | 药品 |

---

## 更新日志

### 版本 1.0.0 (2024-01-01)

- 初始版本发布
- 包含用户、容器、物品、小屋和存储服务等完整功能模块
