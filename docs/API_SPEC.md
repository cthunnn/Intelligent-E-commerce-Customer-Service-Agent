# API 接口规范

基础路径: `/api/v1`

## 认证方式

大部分接口支持通过 Authorization 请求头中的 Bearer Token 进行可选认证。面向客户的聊天接口支持未认证访问（匿名会话）。

```
Authorization: Bearer <jwt_token>
```

---

## 对话接口

### 创建会话

```
POST /api/v1/chat/session
```

请求体:
```json
{
  "user_id": null,
  "channel": "web",
  "initial_message": null
}
```

响应:
```json
{
  "session": {
    "session_id": "abc123...",
    "user_id": null,
    "status": "active",
    "channel": "web",
    "message_count": 0,
    "bot_name": "小E"
  },
  "welcome_message": "您好，我是智能客服小E，很高兴为您服务...",
  "quick_replies": ["查询我的订单", "如何退货？", "有什么优惠活动？", "转人工客服"]
}
```

### 发送消息

```
POST /api/v1/chat/send
```

请求体:
```json
{
  "session_id": "abc123...",
  "content": "我的订单到哪了？",
  "user_id": null,
  "content_type": "text"
}
```

响应:
```json
{
  "response": "您的订单...",
  "intent": {
    "intent_code": "order_query",
    "intent_name": "订单查询",
    "confidence": 0.92,
    "entities": [{"type": "order_no", "value": "ORDER20260715001"}],
    "handler_type": "tool",
    "priority": 8
  },
  "sentiment": "neutral",
  "sentiment_score": 0.0,
  "quick_replies": ["查看物流详情", "修改收货地址"],
  "need_transfer": false
}
```

### 获取历史消息

```
GET /api/v1/chat/history?session_id=abc123&page=1&page_size=20
```

### 转人工客服

```
POST /api/v1/chat/transfer
```

请求体:
```json
{
  "session_id": "abc123...",
  "reason": "user_requested"
}
```

### 评价会话

```
POST /api/v1/chat/rate
```

请求体:
```json
{
  "session_id": "abc123...",
  "score": 5,
  "comment": "服务非常好"
}
```

---

## 意图识别接口

### 单条意图分类

```
POST /api/v1/intent/classify
```

请求体:
```json
{
  "text": "我想查一下我的订单状态",
  "user_id": null
}
```

### 批量意图分类

```
POST /api/v1/intent/classify-batch
```

请求体:
```json
{
  "texts": ["查订单", "退货政策是什么？"]
}
```

---

## Agent 接口

### 执行 Agent 任务

```
POST /api/v1/agent/execute
```

### 获取可用工具列表

```
GET /api/v1/agent/tools
```

---

## 认证接口

### 用户注册

```
POST /api/v1/auth/register
```

### 用户登录

```
POST /api/v1/auth/login
```

### 获取当前用户信息

```
GET /api/v1/auth/me
```

---

## 健康检查

```
GET /health
```

响应:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "connected"
}
```
