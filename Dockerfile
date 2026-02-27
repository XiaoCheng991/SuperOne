# =============================================================================
# Personal Website - Backend Dockerfile
# =============================================================================
# 多阶段构建:
#   - build: 编译 Java 应用
#   - production: 生产环境运行
#   - development: 开发环境（可选）
# =============================================================================

# =============================================================================
# Stage 1: Build
# =============================================================================
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# 安装必要工具
RUN apk add --no-cache git

# 复制 Maven Wrapper 和依赖配置
COPY backend/.mvn .mvn
COPY backend/mvnw backend/pom.xml ./

# 下载依赖（利用 Docker 缓存层）
RUN ./mvnw dependency:go-offline -B

# 复制源代码
COPY backend/src ./src

# 构建应用（跳过测试，测试在 CI 中单独运行）
RUN ./mvnw clean package -DskipTests -B

# =============================================================================
# Stage 2: Production
# =============================================================================
FROM eclipse-temurin:17-jre-alpine AS production

LABEL maintainer="Personal Site Team"
LABEL version="1.0.0"
LABEL description="Personal Website Backend - Spring Boot"

# 创建非 root 用户（安全最佳实践）
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# 安装必要工具（用于健康检查）
RUN apk add --no-cache curl

# 从 build 阶段复制构建产物
COPY --from=build /app/target/*.jar app.jar

# 修改文件所有者
RUN chown -R appuser:appgroup /app

# 切换到非 root 用户
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM 参数优化（容器环境）
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -XX:+UseStringDeduplication \
               -Djava.security.egd=file:/dev/./urandom \
               -Dspring.backgroundpreinitializer.ignore=true \
               -Dspring.jmx.enabled=false"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

# =============================================================================
# Stage 3: Development (Optional - for local dev with hot reload)
# =============================================================================
FROM eclipse-temurin:17-jdk-alpine AS development

WORKDIR /app

# 安装开发工具
RUN apk add --no-cache git curl maven

# 复制项目文件
COPY backend/.mvn .mvn
COPY backend/mvnw backend/pom.xml ./
COPY backend/src ./src

# 下载依赖
RUN ./mvnw dependency:go-offline

EXPOSE 8080

# 开发模式启动（支持热重载）
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"]
