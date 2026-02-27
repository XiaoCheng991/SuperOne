# 🚀 SuperOne - 个人网站系统

<p align="center">
  <img src="https://img.shields.io/badge/Java-17-blue?logo=openjdk&logoColor=white" alt="Java 17">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen?logo=spring&logoColor=white" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Vue-3-42b883?logo=vue.js&logoColor=white" alt="Vue 3">
  <img src="https://img.shields.io/badge/TypeScript-5.0-blue?logo=typescript&logoColor=white" alt="TypeScript">
  <img src="https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql&logoColor=white" alt="PostgreSQL">
</p>

<p align="center">
  <b>一个现代化的个人展示网站</b><br>
  采用 Java + Vue3 + PostgreSQL 技术栈，前后端分离架构
</p>

<p align="center">
  <a href="https://github.com/XiaoCheng991/SuperOne"><img src="https://img.shields.io/badge/GitHub-SuperOne-181717?logo=github" alt="GitHub"></a>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
</p>

---

## 📸 项目预览

> 🚧 项目正在开发中，预览图将在 Phase 4 部署完成后添加

---

## ✨ 核心特性

| 特性 | 描述 |
|------|------|
| 🎨 **现代化UI** | 基于 Vue3 + Element Plus 的响应式设计 |
| 🔒 **安全可靠** | JWT 认证 + Spring Security 权限控制 |
| 📝 **内容管理** | 支持 Markdown 的文章编辑器 |
| 🚀 **高性能** | 页面加载速度 < 2s，SEO 友好 |
| 📱 **多端适配** | 完美支持 PC、平板、手机访问 |
| 🔄 **持续集成** | GitHub Actions 自动化部署 |

---

## 🛠️ 技术栈

### 后端 (Backend)

| 技术 | 版本 | 说明 |
|------|------|------|
| [Java](https://www.oracle.com/java/) | 17 LTS | 编程语言 |
| [Spring Boot](https://spring.io/projects/spring-boot) | 3.2.x | 应用框架 |
| [Spring Data JPA](https://spring.io/projects/spring-data-jpa) | 3.2.x | 数据访问 |
| [Spring Security](https://spring.io/projects/spring-security) | 6.x | 安全框架 |
| [PostgreSQL](https://www.postgresql.org/) | 15 | 数据库 |
| [Flyway](https://flywaydb.org/) | 10.x | 数据库迁移 |
| [JWT](https://jwt.io/) | 0.12.x | 认证机制 |
| [Maven](https://maven.apache.org/) | 3.9.x | 构建工具 |

### 前端 (Frontend)

| 技术 | 版本 | 说明 |
|------|------|------|
| [Vue.js](https://vuejs.org/) | 3.4.x | 前端框架 |
| [TypeScript](https://www.typescriptlang.org/) | 5.x | 类型系统 |
| [Vite](https://vitejs.dev/) | 5.x | 构建工具 |
| [Element Plus](https://element-plus.org/) | 2.5.x | UI 组件库 |
| [Pinia](https://pinia.vuejs.org/) | 2.1.x | 状态管理 |
| [Vue Router](https://router.vuejs.org/) | 4.2.x | 路由管理 |
| [Axios](https://axios-http.com/) | 1.6.x | HTTP 客户端 |
| [pnpm](https://pnpm.io/) | 8.x | 包管理器 |

### 部署 (DevOps)

| 技术 | 说明 |
|------|------|
| [Vercel](https://vercel.com/) | 前端托管（Serverless） |
| [Railway](https://railway.app/) / [Render](https://render.com/) | 后端托管 |
| [Neon](https://neon.tech/) / [Supabase](https://supabase.com/) | PostgreSQL 托管 |
| [GitHub Actions](https://github.com/features/actions) | CI/CD 自动化 |
| [Docker](https://www.docker.com/) | 容器化 |
| [Docker Compose](https://docs.docker.com/compose/) | 本地开发环境 |

---

## 📁 项目结构

```
SuperOne/
├── 📄 README.md                 # 项目说明（本文件）
├── 📄 LICENSE                     # MIT 许可证
├── 📄 CHANGELOG.md                # 变更日志
├── 📄 .gitignore                  # Git 忽略配置
│
├── 📁 docs/                       # 📚 设计文档
│   ├── 📄 PRD.md                 # 需求规格说明书 (Idea)
│   ├── 📄 CONTENT.md             # 内容策略文档 (Idea)
│   ├── 📄 DATA_DICT.md           # 数据库字典 (Idea + Code)
│   │
│   ├── 📁 tech/                  # 🔧 技术文档 (Code)
│   │   ├── 📄 ARCHITECTURE.md    # 技术架构文档
│   │   └── 📄 CODING_STANDARDS.md # 开发规范
│   │
│   └── 📁 ops/                   # 🚀 运维文档 (OM)
│       ├── 📄 DEPLOYMENT.md      # 部署架构文档
│       └── 📄 CICD.md            # CI/CD设计文档
│
├── 📁 backend/                    # ☕ 后端代码 (Java Spring Boot)
│   ├── 📁 src/main/java/com/superone/
│   │   ├── 📁 controller/         # 控制器层
│   │   ├── 📁 service/            # 业务逻辑层
│   │   ├── 📁 entity/           # 实体类
│   │   ├── 📁 repository/       # 数据访问层
│   │   └── 📁 config/           # 配置类
│   ├── 📁 src/main/resources/
│   ├── 📄 pom.xml                 # Maven 配置
│   └── 📄 Dockerfile              # Docker 构建
│
├── 📁 frontend/                   # 🎨 前端代码 (Vue3)
│   ├── 📁 src/
│   │   ├── 📁 views/              # 页面视图
│   │   ├── 📁 components/         # 组件
│   │   ├── 📁 stores/             # Pinia 状态管理
│   │   ├── 📁 api/                # API 接口
│   │   ├── 📁 utils/              # 工具函数
│   │   ├── 📁 assets/             # 静态资源
│   │   ├── 📄 App.vue             # 根组件
│   │   └── 📄 main.ts             # 入口文件
│   ├── 📄 package.json            # 依赖配置
│   ├── 📄 vite.config.ts          # Vite 配置
│   └── 📄 Dockerfile              # Docker 构建
│
├── 📁 configs/                    # ⚙️ 配置文件
│   ├── 📄 docker-compose.yml      # Docker Compose 配置
│   ├── 📄 .env.example            # 环境变量示例
│   └── 📁 .github/workflows/      # GitHub Actions
│       ├── 📄 ci.yml              # CI 工作流
│       ├── 📄 deploy-backend.yml  # 后端部署
│       └── 📄 deploy-frontend.yml # 前端部署
│
└── 📁 scripts/                    # 🛠️ 工具脚本
    ├── 📄 dev-start.sh            # 开发环境启动
    └── 📄 deploy.sh               # 部署脚本
```

---

## 🎯 项目里程碑

| Phase | 时间 | 目标 | 交付物 | 状态 |
|-------|------|------|--------|------|
| **Phase 1** | Day 1-2 | 📚 设计文档 | `docs/` 目录下所有设计文档 | 🚧 进行中 |
| **Phase 2** | Day 3 | 🏗️ 项目脚手架 | 初始化代码、数据库迁移 | ⏳ 待开始 |
| **Phase 3** | Day 4-10 | 💻 核心功能开发 | 用户模块、文章模块、前端页面 | ⏳ 待开始 |
| **Phase 4** | Day 11-12 | 🚀 集成与部署 | CI/CD、测试、上线 | ⏳ 待开始 |

---

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/XiaoCheng991/SuperOne.git
cd SuperOne
```

### 2. 本地开发环境

```bash
# 使用 Docker Compose 启动本地环境
docker-compose up -d

# 或者分别启动前后端
cd backend && ./mvnw spring-boot:run
cd frontend && pnpm dev
```

### 3. 查看文档

```bash
# 设计文档
cd docs && ls -la
```

---

## 🤝 开发流程

1. **Fork** 本仓库
2. **Clone** 到本地
3. **Create Branch**: `git checkout -b feature/your-feature`
4. **Commit**: `git commit -m 'feat: add some feature'`
5. **Push**: `git push origin feature/your-feature`
6. **Open Pull Request**

---

## 📝 提交规范

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能）|
| `refactor` | 重构 |
| `test` | 测试 |
| `chore` | 构建/工具 |

---

## 👥 团队

本项目由 **OpenClaw 多智能体协作开发**：

| 角色 | Agent | 职责 | 负责内容 |
|------|-------|------|----------|
| 👔 **项目总负责** | Jarvis (Boss) | 团队协调、任务分配、进度监督、质量把关 | README.md、项目统筹 |
| 💡 **创意文案** | Idea | 文档编写、内容创作、需求分析 | PRD.md、CONTENT.md、DATA_DICT.md |
| 💻 **全栈开发** | Code | 技术架构、代码开发、技术规范 | ARCHITECTURE.md、CODING_STANDARDS.md |
| 🛡️ **运维DevOps** | OM | 部署架构、CI/CD、基础设施 | DEPLOYMENT.md、CICD.md、配置文件 |

---

## 📄 许可证

[MIT](LICENSE) © 2024 XiaoCheng991

---

## 🙏 致谢

特别感谢 **老程（程永强）** 发起和支持本项目！

---

<p align="center">
  <img src="https://img.shields.io/badge/Built%20with-OpenClaw-orange?logo=robot" alt="Built with OpenClaw">
</p>

<p align="center">
  <b>🦞 SuperOne - 打造属于你的个人网站</b>
</p>

<p align="center">
  <i>Built with ❤️ by OpenClaw Multi-Agent Team</i>
</p>