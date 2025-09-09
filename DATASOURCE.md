# 数据源配置详细文档

本文档详细说明如何配置和管理 MCP MySQL Server 的数据源。

## 配置文件位置

### 默认配置文件

应用默认使用以下配置文件：
```
src/main/resources/datasource.yml
```

### 自定义配置文件

用户可以通过命令行参数指定自定义数据源配置文件：

#### Maven Wrapper 启动方式

```bash
./mvnw spring-boot:run -Dspring-boot.run.arguments=--datasource.config=/path/to/your-datasource.yml
```

#### JAR 包启动方式

```bash
java -jar target/mcp-mysql-server-0.0.1-SNAPSHOT.jar --datasource.config=/path/to/your-datasource.yml
```

## 配置文件格式

数据源配置文件采用 YAML 格式，基本结构如下：

```yaml
datasource:
  datasources:
    # 数据源配置项
    datasource_name:
      url: jdbc:mysql://host:port/database
      username: your_username
      password: your_password
      default: true  # 可选，标记为默认数据源
```

## 配置参数详解

### 必需参数

| 参数       | 类型     | 描述                                    | 示例                                      |
|:---------|:-------|:--------------------------------------|:----------------------------------------|
| `url`    | String | JDBC连接字符串                            | `jdbc:mysql://localhost:3306/mydb`     |
| `username` | String | 数据库用户名                              | `root`                                  |
| `password` | String | 数据库密码                               | `password123`                           |

### 可选参数

| 参数       | 类型      | 描述                                    | 默认值   | 示例    |
|:---------|:--------|:--------------------------------------|:------|:------|
| `default` | Boolean | 是否设为默认数据源。如果未指定，第一个数据源将被设为默认       | false | true  |
| `readonly` | Boolean | 是否设为只读数据源。启用后连接将设置为只读模式，且SQL安全控制将被禁用 | false | true  |

## 配置示例

### 单数据源配置

```yaml
datasource:
  datasources:
    production:
      url: jdbc:mysql://prod-server:3306/production_db
      username: prod_user
      password: prod_password
      default: true
```

### 多数据源配置

```yaml
datasource:
  # 全局配置
  readonly: false  # 全局只读设置，可被单个数据源覆盖
  
  datasources:
    # 生产环境数据库
    production:
      url: jdbc:mysql://prod-server:3306/production_db
      username: prod_user
      password: prod_password
      default: true  # 设为默认数据源

    # 只读分析数据库
    analytics:
      url: jdbc:mysql://analytics-server:3306/analytics_db
      username: analytics_user
      password: analytics_password
      readonly: true  # 只读数据源

    # 测试环境数据库
    testing:
      url: jdbc:mysql://test-server:3306/test_db
      username: test_user
      password: test_password

    # 开发环境数据库
    development:
      url: jdbc:mysql://localhost:3306/dev_db
      username: dev_user
      password: dev_password
```

## 数据源使用

### 默认数据源

- 如果配置中有数据源标记为 `default: true`，该数据源将被设为默认
- 如果没有明确标记默认数据源，第一个数据源将自动成为默认数据源
- 执行 SQL 时，如果不指定数据源，将使用默认数据源

### 指定数据源

在执行 SQL 查询时，可以指定使用特定的数据源：
- 使用 `executeSqlWithDataSource` 工具指定特定数据源
- 使用 `executeSql` 工具在所有数据源上执行
- 使用 `executeSqlOnDefault` 工具仅在默认数据源上执行

## MCP 配置集成

### Maven Wrapper 启动的 MCP 配置

使用自定义数据源配置文件的 MCP JSON 配置：

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "/your-path/mcp-mysql-server/mvnw",
      "args": [
        "-q",
        "-Dspring-boot.run.arguments=--datasource.config=/your-path/your-datasource.yml",
        "-f",
        "/your-path/mcp-mysql-server/pom.xml",
        "spring-boot:run"
      ]
    }
  }
}
```

### JAR 包启动的 MCP 配置

#### 使用默认配置文件

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "java",
      "args": [
        "-jar",
        "/your-path/mcp-mysql-server-0.0.1-SNAPSHOT.jar"
      ]
    }
  }
}
```

#### 使用自定义配置文件

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "java",
      "args": [
        "-jar",
        "/your-path/mcp-mysql-server-0.0.1-SNAPSHOT.jar",
        "--datasource.config=/your-path/your-datasource.yml"
      ]
    }
  }
}
```

#### 同时使用扩展和自定义数据源

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "java",
      "args": [
        "-Dloader.path=/your-path/src/main/resources/groovy",
        "-jar",
        "/your-path/mcp-mysql-server-0.0.1-SNAPSHOT.jar",
        "--datasource.config=/your-path/your-datasource.yml"
      ]
    }
  }
}
```

## 连接字符串详解

### 基本格式

```
jdbc:mysql://[host]:[port]/[database]?[parameters]
```

### 常用参数

| 参数                        | 描述                   | 示例值                    |
|:--------------------------|:---------------------|:-----------------------|
| `useSSL`                  | 是否使用SSL连接           | `false` 或 `true`       |
| `serverTimezone`          | 服务器时区               | `UTC` 或 `Asia/Shanghai` |
| `characterEncoding`       | 字符编码                | `utf8mb4`              |
| `useUnicode`              | 是否使用Unicode         | `true`                 |
| `allowPublicKeyRetrieval` | 允许检索公钥              | `true`                 |

### 完整示例

```yaml
datasource:
  datasources:
    mydb:
      url: jdbc:mysql://localhost:3306/mydb?useSSL=false&serverTimezone=UTC&characterEncoding=utf8mb4&useUnicode=true
      username: root
      password: password
      default: true
```

## 安全性考虑

### SQL安全控制

本系统支持SQL安全控制功能，可以防止执行危险的数据库操作。详细配置请参考 [SQL安全控制文档](SQL_SECURITY.md)。

**注意：** 当数据源设置为 `readonly: true` 时，SQL安全控制将自动禁用，因为数据库连接层面已提供只读保护。

### 密码保护

1. **环境变量**：建议将敏感信息如密码存储在环境变量中
2. **文件权限**：确保配置文件具有适当的访问权限
3. **版本控制**：不要将包含敏感信息的配置文件提交到版本控制系统

### 连接安全

1. **SSL 连接**：生产环境建议启用 SSL
2. **网络限制**：限制数据库服务器的网络访问
3. **用户权限**：为应用创建专用数据库用户，授予最小必要权限

## 故障排除

### 常见连接问题

1. **连接超时**
   - 检查网络连接
   - 验证主机和端口
   - 确认防火墙设置

2. **认证失败**
   - 验证用户名和密码
   - 检查用户权限
   - 确认数据库用户账户状态

3. **数据库不存在**
   - 确认数据库名称拼写
   - 验证数据库是否已创建
   - 检查用户是否有访问该数据库的权限

### 配置文件问题

1. **YAML 格式错误**
   - 检查缩进是否正确（使用空格，不使用制表符）
   - 验证 YAML 语法
   - 确认特殊字符是否需要引号

2. **文件路径错误**
   - 使用绝对路径
   - 检查文件是否存在
   - 验证文件权限

### 调试建议

1. **启用详细日志**：在应用启动时启用 DEBUG 级别日志
2. **连接测试**：使用 MySQL 客户端工具测试连接
3. **逐步排查**：从简单配置开始，逐步添加复杂参数

## 最佳实践

1. **环境隔离**：为不同环境（开发、测试、生产）使用不同的配置文件
2. **命名规范**：使用有意义的数据源名称
3. **文档记录**：为每个数据源添加注释说明其用途
4. **定期审查**：定期检查和更新数据源配置
5. **备份配置**：定期备份重要的配置文件
