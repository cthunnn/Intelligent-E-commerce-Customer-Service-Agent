# 数据库设计文档

## 实体关系

```
users 1---* sessions 1---* messages *---1 intents
users 1---* orders
knowledge（独立表）
products（独立表）
tickets *---1 users
```

## 数据表结构

### users 用户表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| username | VARCHAR(50) UNIQUE | 用户名 |
| email | VARCHAR(100) UNIQUE | 邮箱地址 |
| phone | VARCHAR(20) UNIQUE | 手机号码 |
| password_hash | VARCHAR(255) | bcrypt 密码哈希 |
| user_type | ENUM | 用户角色: customer/agent/admin |
| avatar_url | VARCHAR(500) | 头像地址 |
| is_active | BOOLEAN | 账户启用状态 |
| created_at | DATETIME | 注册时间 |
| updated_at | DATETIME | 最近更新时间 |

### sessions 会话表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| session_id | VARCHAR(64) UNIQUE | 会话 UUID |
| user_id | BIGINT FK | 关联用户 |
| agent_id | BIGINT | 分配的人工客服 ID |
| status | ENUM | 会话状态: active/waiting/transferred/closed |
| channel | VARCHAR(20) | 来源渠道 |
| started_at | DATETIME | 开始时间 |
| ended_at | DATETIME | 结束时间 |
| last_message_at | DATETIME | 最后消息时间 |
| message_count | INT | 消息总数 |
| satisfaction_score | TINYINT | 满意度评分 1-5 |

### messages 消息表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| session_id | BIGINT FK | 关联会话 |
| sender_type | ENUM | 发送者: user/bot/agent |
| sender_id | BIGINT | 发送者 ID |
| content | TEXT | 消息正文 |
| content_type | ENUM | 内容类型: text/image/voice/file/quick_reply |
| intent_id | BIGINT FK | 识别的意图 |
| intent_confidence | DECIMAL(5,4) | 意图置信度 |
| sentiment | ENUM | 情感标签: positive/neutral/negative |
| sentiment_score | DECIMAL(3,2) | 情感得分 -1.0 到 1.0 |
| is_human_transfer | BOOLEAN | 是否触发转人工 |
| is_generated | BOOLEAN | 是否为 AI 生成 |
| metadata | JSON | 扩展元数据 |
| created_at | DATETIME | 消息时间 |

### intents 意图表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| intent_name | VARCHAR(100) | 意图显示名称 |
| intent_code | VARCHAR(50) UNIQUE | 意图编码 |
| description | VARCHAR(255) | 意图说明 |
| handler_type | ENUM | 处理策略: rag/tool/transfer/llm/fallback |
| handler_config | JSON | 处理器配置参数 |
| sample_utterances | TEXT | 训练样本语料 |
| priority | INT | 路由优先级 |
| is_active | BOOLEAN | 是否启用 |

### knowledge 知识库表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| category | VARCHAR(50) | 知识分类 |
| question | TEXT | 问题文本 |
| answer | TEXT | 答案文本 |
| keywords | VARCHAR(500) | 检索关键词 |
| vector_id | VARCHAR(100) | 向量数据库 ID |
| embedding_model | VARCHAR(50) | 向量化模型 |
| hit_count | INT | 检索命中次数 |
| satisfaction_rate | DECIMAL(5,2) | 用户满意度 |

### orders 订单表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| order_no | VARCHAR(32) UNIQUE | 订单编号 |
| user_id | BIGINT FK | 下单用户 |
| status | ENUM | 订单状态 |
| total_amount | DECIMAL(10,2) | 订单总额 |
| pay_amount | DECIMAL(10,2) | 实付金额 |
| shipping_address | JSON | 收货地址 |
| receiver_name | VARCHAR(50) | 收货人 |
| receiver_phone | VARCHAR(20) | 联系电话 |
| tracking_no | VARCHAR(50) | 快递单号 |
| express_company | VARCHAR(50) | 快递公司 |

### products 商品表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| sku | VARCHAR(50) UNIQUE | 商品 SKU |
| name | VARCHAR(200) | 商品名称 |
| category | VARCHAR(50) | 商品分类 |
| brand | VARCHAR(50) | 品牌 |
| price | DECIMAL(10,2) | 售价 |
| original_price | DECIMAL(10,2) | 原价（划线价） |
| stock | INT | 库存数量 |
| sales_count | INT | 累计销量 |
| description | TEXT | 商品描述 |
| specifications | JSON | 规格参数 |
| images | JSON | 图片列表 |
| tags | JSON | 搜索标签 |

### tickets 工单表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 自增主键 |
| ticket_no | VARCHAR(32) UNIQUE | 工单编号 |
| session_id | BIGINT | 关联会话 |
| user_id | BIGINT FK | 提交用户 |
| type | ENUM | 工单类型 |
| title | VARCHAR(200) | 工单标题 |
| content | TEXT | 工单内容 |
| status | ENUM | 处理状态 |
| priority | ENUM | 紧急程度 |
| assigned_to | BIGINT | 处理人 |
| resolution | TEXT | 处理结果 |
| resolved_at | DATETIME | 解决时间 |
