# 部署指南

## 环境要求

- Docker Engine 24+ 和 Docker Compose v2
- Python 3.11+（本地开发时使用）
- Node.js 20+（本地开发时使用）
- Git

## 环境变量配置

1. 复制环境变量模板:
```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，填写必要配置:
   - 将 `SECRET_KEY` 和 `JWT_SECRET_KEY` 设置为随机字符串（至少 32 字符）
   - 填入 `LLM_API_KEY`（OpenAI 或 Anthropic 的 API 密钥）
   - 根据需要修改数据库密码

## Docker 部署（推荐方式）

### 快速启动

```bash
# 构建并启动所有服务
docker compose up -d

# 查看服务运行状态
docker compose ps

# 查看后端日志
docker compose logs -f backend

# 初始化数据库表结构
docker compose exec backend python scripts/init_db.py

# 导入知识库样本数据
docker compose exec backend python scripts/import_knowledge.py
```

### 服务访问地址

| 服务 | 地址 |
|------|------|
| 前端页面 | http://localhost:3000 |
| 后端 API | http://localhost:8000 |
| Swagger 文档 | http://localhost:8000/docs |
| 健康检查 | http://localhost:8000/health |

### 停止服务

```bash
# 停止所有服务（保留数据卷）
docker compose down

# 停止并删除数据卷（重置所有数据）
docker compose down -v
```

## 本地开发

### 后端开发环境

```bash
cd backend

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 启动开发服务器（热重载模式）
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 前端开发环境

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端开发服务器运行在 http://localhost:5173，自动代理 API 请求到后端 8000 端口。

### 运行测试

```bash
cd backend

# 运行全部测试
pytest

# 运行测试并生成覆盖率报告
pytest --cov=app --cov-report=html

# 运行特定测试文件
pytest tests/services/test_chat_service.py
```

## 生产环境注意事项

### 安全加固
- 修改所有默认密码和密钥为强随机值
- 配置 HTTPS 证书以启用加密传输
- 正确设置 CORS 允许域名（不要使用通配符）
- 配置防火墙规则限制直接访问内部服务端口
- 使用密钥管理服务管理 API 密钥

### 水平扩展
- 在负载均衡器后方部署多个后端实例
- 使用托管 MySQL 服务（如 AWS RDS），配置读写分离
- 使用托管 Redis 服务（如 AWS ElastiCache）
- 使用 CDN 加速前端静态资源

### 监控告警
- 为所有服务配置健康检查监控
- 搭建日志聚合平台
- 设置错误率和响应延迟告警阈值
- 监控 LLM API 调用次数和费用
- 跟踪对话质量指标

### 数据备份
- MySQL 定期备份（建议每日全量 + 每小时增量）
- Redis AOF 持久化已默认开启
- 定期导出知识库备份
