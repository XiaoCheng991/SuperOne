# CI/CD 设计文档 (CICD.md)

## 1. 概述

本文档定义个人网站项目的持续集成与持续部署 (CI/CD) 流程，实现自动化测试、构建和部署。

### 1.1 目标

- ✅ 自动化测试：每次提交自动运行测试
- ✅ 自动化构建：通过 Dockerfile 统一构建环境
- ✅ 自动化部署：合并到 main 分支自动部署
- ✅ 环境隔离：开发、预发布、生产环境分离
- ✅ 快速回滚：支持快速回滚到上一版本

### 1.2 CI/CD 流程图

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Developer  │    │   GitHub    │    │  GitHub     │    │  Deploy     │
│   Commit    │───►│   Repository│───►│  Actions    │───►│  Platforms  │
└─────────────┘    └─────────────┘    └──────┬──────┘    └──────┬──────┘
                                              │                  │
                                              ▼                  ▼
                                       ┌─────────────┐    ┌─────────────┐
                                       │   Testing   │    │   Vercel/   │
                                       │   Building  │    │   Railway   │
                                       └─────────────┘    └─────────────┘
```

---

## 2. Git 分支策略

### 2.1 分支模型

采用 **GitHub Flow** 简化模型：

```
main (protected)
  │
  ├── feature/user-auth      ──► PR ──► Merge
  │
  ├── feature/article-crud   ──► PR ──► Merge
  │
  └── hotfix/security-patch  ──► PR ──► Merge
```

### 2.2 分支命名规范

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| 功能分支 | `feature/功能描述` | `feature/user-authentication` |
| 修复分支 | `fix/问题描述` | `fix/login-redirect-bug` |
| 热修复 | `hotfix/问题描述` | `hotfix/security-vulnerability` |
| 文档更新 | `docs/描述` | `docs/api-documentation` |
| 发布分支 | `release/版本号` | `release/v1.0.0` |

### 2.3 提交信息规范

采用 **Conventional Commits** 规范：

```
<类型>(<可选范围>): <描述>

[可选正文]

[可选脚注]
```

**类型说明：**

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(auth): add JWT authentication` |
| `fix` | 修复bug | `fix(api): correct null pointer exception` |
| `docs` | 文档更新 | `docs(readme): update deployment guide` |
| `style` | 代码格式 | `style(css): fix indentation` |
| `refactor` | 重构 | `refactor(service): extract common logic` |
| `test` | 测试相关 | `test(auth): add unit tests` |
| `chore` | 构建/工具 | `chore(deps): update spring boot version` |
| `deploy` | 部署相关 | `deploy(vercel): configure production domain` |

---

## 3. GitHub Actions 工作流

### 3.1 工作流概览

| 工作流 | 触发条件 | 用途 |
|--------|----------|------|
| `ci.yml` | PR 创建/更新 | 运行测试、代码检查 |
| `deploy-backend.yml` | main 分支推送 | 部署后端到 Railway |
| `deploy-frontend.yml` | main 分支推送 | 部署前端到 Vercel |

### 3.2 CI 工作流 (ci.yml)

```yaml
name: CI - Test & Lint

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  # ==========================================
  # Backend CI
  # ==========================================
  backend-test:
    name: Backend Tests
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run tests
        working-directory: ./backend
        run: ./mvnw test -Dspring.profiles.active=test
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/testdb
          SPRING_DATASOURCE_USERNAME: test
          SPRING_DATASOURCE_PASSWORD: test

      - name: Generate test report
        uses: dorny/test-reporter@v1
        if: success() || failure()
        with:
          name: Backend Test Report
          path: backend/target/surefire-reports/*.xml
          reporter: java-junit

  backend-lint:
    name: Backend Code Style
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Check code style
        working-directory: ./backend
        run: ./mvnw spotless:check

  # ==========================================
  # Frontend CI
  # ==========================================
  frontend-test:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run lint
        working-directory: ./frontend
        run: npm run lint

      - name: Run type check
        working-directory: ./frontend
        run: npm run type-check

      - name: Run unit tests
        working-directory: ./frontend
        run: npm run test:unit -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./frontend/coverage/lcov.info
          flags: frontend

  frontend-build:
    name: Frontend Build Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Build test
        working-directory: ./frontend
        run: |
          npm ci
          npm run build

  # ==========================================
  # Docker Build Test
  # ==========================================
  docker-build:
    name: Docker Build Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Build Backend Image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: false
          tags: backend:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Test Docker Compose
        run: |
          docker-compose -f docker-compose.yml config

  # ==========================================
  # Summary
  # ==========================================
  ci-summary:
    name: CI Summary
    needs: [backend-test, frontend-test, docker-build]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Generate Summary
        run: |
          echo "## CI Pipeline Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Job | Status |" >> $GITHUB_STEP_SUMMARY
          echo "|-----|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| Backend Tests | ${{ needs.backend-test.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Frontend Tests | ${{ needs.frontend-test.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Docker Build | ${{ needs.docker-build.result }} |" >> $GITHUB_STEP_SUMMARY
```

### 3.3 后端部署工作流 (deploy-backend.yml)

```yaml
name: Deploy Backend to Railway

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'
      - '.github/workflows/deploy-backend.yml'
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy to Railway
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven
      
      - name: Build with Maven
        working-directory: ./backend
        run: ./mvnw clean package -DskipTests
      
      - name: Install Railway CLI
        run: npm install -g @railway/cli
      
      - name: Deploy to Railway
        id: deploy
        working-directory: ./backend
        run: |
          railway up --service backend
          echo "url=$(railway domain)" >> $GITHUB_OUTPUT
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Run Database Migrations
        run: |
          # 等待服务启动
          sleep 30
          # 调用迁移端点或使用 Flyway
          curl -f ${{ steps.deploy.outputs.url }}/api/health || true
      
      - name: Notify Deployment
        if: success()
        run: |
          echo "✅ Backend deployed successfully!"
          echo "URL: ${{ steps.deploy.outputs.url }}"
          # 可选: 发送到 Slack/Telegram
      
      - name: Rollback on Failure
        if: failure()
        run: |
          echo "❌ Deployment failed. Rolling back..."
          railway rollback --service backend
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

### 3.4 前端部署工作流 (deploy-frontend.yml)

```yaml
name: Deploy Frontend to Vercel

on:
  push:
    branches: [main]
    paths:
      - 'frontend/**'
      - '.github/workflows/deploy-frontend.yml'
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy to Vercel
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Build application
        working-directory: ./frontend
        run: npm run build
        env:
          VITE_API_BASE_URL: ${{ secrets.VITE_API_BASE_URL }}
      
      - name: Install Vercel CLI
        run: npm install -g vercel@latest
      
      - name: Deploy to Vercel
        id: deploy
        working-directory: ./frontend
        run: |
          vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }} --confirm
          echo "url=$(vercel --token=${{ secrets.VERCEL_TOKEN }} inspect --confirm 2>/dev/null | grep 'Production' | awk '{print $2}')" >> $GITHUB_OUTPUT
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
      
      - name: Verify Deployment
        run: |
          echo "Verifying deployment..."
          sleep 10
          curl -f "${{ steps.deploy.outputs.url }}" || true
      
      - name: Notify Success
        if: success()
        run: |
          echo "✅ Frontend deployed successfully!"
          echo "URL: ${{ steps.deploy.outputs.url }}"
      
      - name: Notify Failure
        if: failure()
        run: |
          echo "❌ Frontend deployment failed!"
```

---

## 4. 数据库迁移自动化

### 4.1 Flyway 配置

**后端 `application.yml`:**

```yaml
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
    validate-on-migrate: true
    
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/personalsite}
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD:password}
```

### 4.2 迁移脚本命名规范

```
db/migration/
├── V1__Initial_schema.sql
├── V2__Add_user_table.sql
├── V3__Add_article_table.sql
└── V4__Add_category_tags.sql
```

**命名规则:** `V{版本号}__{描述}.sql`

### 4.3 CI/CD 中的迁移

迁移在部署流程中自动执行：

1. 后端部署启动
2. Spring Boot 启动
3. Flyway 自动检测并执行新迁移
4. 应用启动完成

---

## 5. 部署通知机制

### 5.1 GitHub Actions 通知

添加通知步骤到工作流：

```yaml
- name: Notify Telegram
  if: always()
  uses: appleboy/telegram-action@master
  with:
    to: ${{ secrets.TELEGRAM_CHAT_ID }}
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    message: |
      🚀 Deployment Status: ${{ job.status }}
      
      Project: Personal Website
      Branch: ${{ github.ref }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}
      
      ${{ job.status == 'success' && '✅ Deployed successfully!' || '❌ Deployment failed!' }}
```

### 5.2 部署状态徽章

添加到 `README.md`:

```markdown
## Deployment Status

![Backend Deploy](https://github.com/username/repo/actions/workflows/deploy-backend.yml/badge.svg)
![Frontend Deploy](https://github.com/username/repo/actions/workflows/deploy-frontend.yml/badge.svg)
```

---

## 6. 附录

### 6.1 Secrets 配置清单

在 GitHub Repository Settings → Secrets and variables → Actions 中配置：

| Secret Name | 用途 | 获取方式 |
|-------------|------|----------|
| `RAILWAY_TOKEN` | Railway CLI 认证 | Railway Dashboard → Tokens |
| `VERCEL_TOKEN` | Vercel CLI 认证 | Vercel Settings → Tokens |
| `VERCEL_ORG_ID` | Vercel 组织 ID | Vercel Project Settings |
| `VERCEL_PROJECT_ID` | Vercel 项目 ID | Vercel Project Settings |
| `VITE_API_BASE_URL` | 生产环境 API 地址 | Railway 部署后的域名 |
| `TELEGRAM_BOT_TOKEN` | Telegram 通知 | BotFather 创建 |
| `TELEGRAM_CHAT_ID` | Telegram 群组 ID | 群组中获取 |

### 6.2 本地 CI 测试

使用 `act` 工具本地测试 GitHub Actions:

```bash
# 安装 act
brew install act

# 运行 CI 工作流
act -j backend-test

# 运行完整工作流
act push
```

---

**文档版本**: v1.0  
**最后更新**: 2025-02-27  
**负责人**: @om
