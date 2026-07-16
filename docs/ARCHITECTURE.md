# 架构设计文档

## 概述

电商智能客服系统采用分层微服务化架构，以单体应用形式部署以降低运维复杂度。各层均可独立水平扩展，层间通过明确定义的接口通信。

## 系统分层

```
客户端层
  - Vue 3 单页应用（Web 端、移动 H5）
  - 微信小程序
  - 企业微信集成

网关层
  - Nginx 反向代理
  - SSL/TLS 终止
  - API 限流
  - WebSocket 协议升级

应用层（FastAPI）
  - REST API 接口（/api/v1/）
  - WebSocket 实时通信
  - 业务逻辑服务
  - Agent 编排调度

AI 服务层
  - LLM 提供商抽象（OpenAI / Anthropic / 本地模型）
  - Embedding 向量化服务
  - RAG 检索增强生成管线
  - NLU 意图分类器
  - 情感分析器

数据层
  - MySQL 8.0: 业务数据（用户、会话、消息、订单、商品）
  - Redis 7: 会话缓存、限流计数、Pub/Sub 消息
  - Milvus 2.3: 知识库向量存储与检索
  - MinIO: 文件附件存储
```

## 请求处理流程

1. 客户端通过 HTTP POST 或 WebSocket 发送消息
2. Nginx 将请求路由到 FastAPI 后端，同时执行限流策略
3. ChatService 编排消息处理管线:
   - IntentService 识别用户意图
   - SentimentService 分析用户情绪
   - Agent 根据意图路由到对应处理器（RAG、工具调用、LLM 直接回答或转人工）
4. 响应以流式或 JSON 格式返回客户端
5. 会话和消息数据持久化到 MySQL

## 关键设计决策

### LLM 提供商抽象层
LLM 服务采用提供商抽象模式。通过修改环境变量即可在 OpenAI、Anthropic Claude 和本地 vLLM 部署之间切换，无需修改任何业务代码。

### Agent 工具架构
每个 Agent 工具都是独立的类，实现了 `execute(params) -> dict` 接口。这使得工具可以独立测试，并由 Agent 编排器动态组合调用。

### 无状态服务设计
所有业务逻辑服务均为无状态设计。持久化状态存储在 MySQL 中，临时状态（缓存、会话）存储在 Redis 中。这使得应用层可以无痛水平扩展。

### 多策略 NLU 意图识别
意图识别采用级联策略: 首先使用快速关键词匹配，其次进行语义相似度计算，对于模糊查询最终回退到 LLM 深度理解。这种设计兼顾了响应速度和识别准确率。

## 可扩展性

- 应用层: 无状态设计，可在 Nginx 后方水平扩展任意数量的实例
- MySQL: 读密集型场景可配置读写分离，从库横向扩展
- Redis: 高吞吐场景可切换至集群模式
- Milvus: 大规模知识库可部署分布式版本

## 安全性

- 所有 API 接口支持 JWT Bearer Token 认证
- Nginx 和应用层双重限流保护
- CORS 白名单策略
- 用户密码使用 bcrypt 哈希存储
- SQLAlchemy 参数化查询防止 SQL 注入
