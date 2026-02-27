# 部署架构文档 (DEPLOYMENT.md)

## 1. 环境规划

### 1.1 环境概览

| 环境 | 用途 | 部署平台 | 访问方式 |
|------|------|----------|----------|
| Development | 本地开发调试 | Docker Compose | http://localhost:3000 / 8080 |
| Staging | 预发布测试 | Railway + Vercel Preview | 预览链接 |
| Production | 正式生产环境 | Railway + Vercel | https://yourdomain.com |

### 1.2 技术栈部署矩阵

| 组件 | Development | Production | 备注 |
|------|-------------|------------|------|
| **前端** | Docker (Node 20) | Vercel | 自动部署 |
| **后端** | Docker (Java 17) | Railway | 自动部署 |
| **数据库** | Docker (PostgreSQL 15) | Neon / Supabase | 托管服务 |
| **缓存** | - | - | Phase 2 考虑 Redis |
| **对象存储** | - | Cloudinary/AWS S3 | 图片存储 |

---

## 2. 本地开发环境 (Docker Compose)

### 2.1 服务架构

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                       │
│                      (app-network)                      │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Frontend   │  │   Backend    │  │  PostgreSQL  │  │
│  │   (Vue3)     │◄─┤  (Spring)    │◄─┤   (DB)       │  │
│  │   :3000      │  │   :8080      │  │   :5432      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.2 环境变量配置

创建 `.env` 文件：

```env
# ==========================================
# 应用配置
# ==========================================
APP_NAME=PersonalSite
APP_ENV=development

# ==========================================
# 数据库配置 (PostgreSQL)
# ==========================================
DB_HOST=postgres
DB_PORT=5432
DB_NAME=personalsite
DB_USER=postgres
DB_PASSWORD=devpassword123

# ==========================================
# JWT 配置
# ==========================================
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=86400000

# ==========================================
# 前端 API 配置
# ==========================================
VITE_API_BASE_URL=http://localhost:8080/api
```

---

## 3. 生产环境部署

### 3.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户访问                                │
│                    https://yourdomain.com                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Cloudflare (DNS + CDN)                     │
│                   SSL 证书管理 + DDoS 防护                      │
└─────────────────────────────────────────────────────────────────┘
                                │
            ┌───────────────────┴───────────────────┐
            ▼                                       ▼
┌───────────────────────┐           ┌───────────────────────────────┐
│      Vercel           │           │         Railway             │
│   (Frontend Hosting)  │           │     (Backend Hosting)       │
│                       │           │                             │
│  ┌─────────────────┐  │           │  ┌─────────────────────┐     │
│  │   Vue3 SPA      │  │           │  │   Spring Boot     │     │
│  │   Build Output  │  │◄──────────┼──┤   REST API        │     │
│  └─────────────────┘  │   API Call│  └─────────────────────┘     │
└───────────────────────┘           └──────────────┬──────────────┘
                                                 │
                                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│              Neon / Supabase (PostgreSQL)                       │
│         托管数据库 + 自动备份 + Connection Pooling              │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 平台配置详情

#### 3.2.1 Vercel (前端部署)

**配置步骤：**

1. **导入项目**
   - 登录 Vercel Dashboard
   - 点击 "Add New Project"
   - 导入 GitHub 仓库

2. **构建设置**
   ```
   Framework Preset: Vue.js
   Build Command: cd frontend && npm run build
   Output Directory: frontend/dist
   Install Command: cd frontend && npm install
   ```

3. **环境变量**
   ```
   VITE_API_BASE_URL=https://your-railway-app.up.railway.app/api
   ```

4. **自定义域名**
   - 在 Domain 设置中添加自定义域名
   - 按提示配置 DNS 记录

#### 3.2.2 Railway (后端部署)

**配置步骤：**

1. **创建项目**
   - 登录 Railway Dashboard
   - 点击 "New Project"
   - 选择 "Deploy from GitHub repo"

2. **添加 PostgreSQL**
   - 点击 "New"
   - 选择 "Database" → "Add PostgreSQL"
   - 数据库自动连接为环境变量

3. **服务配置**
   ```
   Build Command: ./mvnw clean package -DskipTests
   Start Command: java -jar target/*.jar
   ```

4. **环境变量**
   ```
   SPRING_PROFILES_ACTIVE=prod
   JWT_SECRET=(随机生成)
   JWT_EXPIRATION=86400000
   ```
   数据库连接信息自动从 PostgreSQL 服务注入。

#### 3.2.3 Neon / Supabase (数据库)

**Neon 配置：**

1. 注册 neon.tech
2. 创建项目，选择 PostgreSQL 15
3. 复制连接字符串：
   ```
   postgresql://user:password@host.neon.tech/dbname?sslmode=require
   ```
4. 在 Railway/Vercel 中配置为环境变量

---

## 4. 域名与 SSL 配置

### 4.1 域名方案

推荐域名注册商：Namecheap / Cloudflare Registrar

### 4.2 DNS 配置

使用 Cloudflare DNS：

```
Type    Name            Value                           TTL
A       @               Vercel IP (Anycast)             Auto
CNAME   www             cname.vercel-dns.com            Auto
CNAME   api             your-railway-app.up.railway.app Auto
```

### 4.3 SSL 证书

- **Vercel**: 自动提供 Let's Encrypt SSL
- **Railway**: 自动提供 SSL
- **Cloudflare**: 可选开启 Full (strict) 模式

---

## 5. 备份与回滚策略

### 5.1 数据备份

| 层级 | 策略 | 保留周期 |
|------|------|----------|
| 数据库 | Neon 自动备份 + 每日手动导出 | 7天 |
| Git 代码 | GitHub 原生 + 本地镜像 | 永久 |
| 环境配置 | 环境变量导出加密存储 | 版本化 |

### 5.2 回滚策略

**代码回滚：**
```bash
# Vercel 回滚
vercel --rollback

# Railway 回滚
railway down
railway up --environment production
```

**数据库回滚：**
- Neon 支持 Point-in-time Recovery
- 手动 SQL 备份恢复

---

## 6. 监控与告警

### 6.1 应用监控

| 工具 | 用途 | 免费额度 |
|------|------|----------|
| Vercel Analytics | 前端性能 | 免费版 |
| Railway 仪表板 | 后端资源 | 内置 |
| UptimeRobot | 可用性监控 | 50 monitors |

### 6.2 告警配置

**UptimeRobot 设置：**
```
Monitor Type: HTTP(s)
URL: https://yourdomain.com/health
Interval: 5 minutes
Alert Contact: Email / Telegram
```

---

## 7. 成本估算

### 7.1 免费层方案

| 服务 | 免费额度 | 预估月费用 |
|------|----------|-----------|
| Vercel (Frontend) | 100GB 带宽/月 | $0 |
| Railway (Backend) | $5/月 免费额度 | $0 ( hobby ) |
| Neon (PostgreSQL) | 3 个项目 / 500MB | $0 |
| Cloudflare | 免费 DNS + SSL | $0 |
| GitHub | 公开仓库 | $0 |
| **总计** | | **$0/月** |

### 7.2 扩展方案

如流量增长，升级路径：
- Railway: $5/月 → $20/月 (更多资源)
- Neon: 按需付费 ($0.000016/计算单元)
- Vercel: Pro 计划 $20/月

---

## 8. 安全策略

### 8.1 生产环境安全清单

- [ ] 所有密码使用随机生成 (32+ 字符)
- [ ] JWT Secret 使用 `openssl rand -base64 64` 生成
- [ ] 数据库使用 SSL 连接
- [ ] 启用 Railway 的 Private Networking (可选)
- [ ] 关闭后端服务的 CORS 通配符，只允许前端域名
- [ ] 敏感信息存储在 Railway/Vercel 的环境变量中，不入 Git
- [ ] 启用 Cloudflare 的 "Always Use HTTPS"
- [ ] 配置 Security Headers (HSTS, X-Frame-Options, etc.)

### 8.2 环境变量模板

`.env.production` (本地加密存储，不上传 Git):
```
# 后端
SPRING_PROFILES_ACTIVE=prod
JWT_SECRET=<random-64-char>
JWT_EXPIRATION=86400000
DATABASE_URL=postgresql://...neon.tech/...?sslmode=require

# 前端
VITE_API_BASE_URL=https://your-api-domain.com/api
```

---

## 9. 部署检查清单 (Go-Live Checklist)

### 部署前检查
- [ ] 所有文档已更新并提交到 GitHub
- [ ] 代码审查完成，所有 PR 已合并
- [ ] 本地 Docker 环境测试通过
- [ ] 环境变量已在 Railway/Vercel 配置
- [ ] 数据库迁移脚本已准备 (Flyway)
- [ ] 健康检查端点 `/health` 可访问

### 部署中步骤
1. 部署后端到 Railway
2. 运行数据库迁移
3. 部署前端到 Vercel
4. 配置自定义域名 DNS
5. 验证 SSL 证书

### 部署后验证
- [ ] 首页可访问
- [ ] API 响应正常
- [ ] 数据库连接正常
- [ ] 登录/注册功能正常
- [ ] 文章 CRUD 正常
- [ ] 移动端响应式正常
- [ ] UptimeRobot 监控启用

---

## 10. 附录

### 10.1 快速命令参考

```bash
# 本地开发启动
docker-compose up -d

# 查看日志
docker-compose logs -f backend
docker-compose logs -f frontend

# 数据库连接
docker-compose exec postgres psql -U postgres -d personalsite

# Railway CLI 部署
railway login
railway link
railway up

# Vercel CLI 部署
vercel
vercel --prod
```

### 10.2 故障排查指南

**问题1: Railway 部署失败**
- 检查 `pom.xml` 配置
- 确认 `Procfile` 或启动命令
- 查看 Railway Logs

**问题2: 数据库连接失败**
- 检查 `DATABASE_URL` 格式
- 确认 SSL 模式配置
- 验证数据库服务状态

**问题3: 前端 API 404**
- 检查 `VITE_API_BASE_URL`
- 确认 CORS 配置
- 验证 API 路径

---

**文档版本**: v1.0  
**最后更新**: 2025-02-27  
**负责人**: @om
