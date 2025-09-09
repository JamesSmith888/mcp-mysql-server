# MCP MySQL Server

一个基于 Spring AI 的MCP，可执行任意 SQL。
> 关于其他数据库支持，请查看 [mcp-db-server](https://github.com/JamesSmith888/mcp-db-server)

[中文文档](README.md) | [English Documentation](README_EN.md)

## 快速上手

### 1. MCP JSON 配置

#### 方式一：Maven Wrapper 启动

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "/Users/xin.y/IdeaProjects/mcp-mysql-server/mvnw",
      "args": [
        "-q",
        "-f",
        "/Users/xin.y/IdeaProjects/mcp-mysql-server/pom.xml",
        "spring-boot:run"
      ]
    }
  }
}
```

#### 方式二：JAR 包启动

构建jar

```bash
./mvnw clean package
```

配置MCP服务器

```json
{
  "mcpServers": {
    "mcp-mysql-server": {
      "command": "java",
      "args": [
        "-Dloader.path=/Users/xin.y/IdeaProjects/mcp-mysql-server/src/main/resources/groovy",
        "-jar",
        "/Users/xin.y/IdeaProjects/mcp-mysql-server/target/mcp-mysql-server-0.0.1-SNAPSHOT.jar"
      ]
    }
  }
}
```

**注意：** `-Dloader.path` 参数为可选，仅在需要运行扩展功能时才需要指定。

### 2. 数据源配置

修改 `mcp-mysql-server/src/main/resources/datasource.yml` 文件：

```yaml
datasource:
  datasources:
    your_db1_name:
      url: jdbc:mysql://localhost:3306/db1
      username: root
      password: password
      default: true  # 标记为默认数据源
```

---

## 功能特点

- **多数据源支持** - 配置和管理多个数据库数据源
- **动态数据源切换** - 运行时动态切换不同的数据源
- **扩展功能** - 通过 Groovy 脚本扩展功能
- **SQL 安全控制** - 防止 AI 模型执行危险 SQL 操作

## 详细文档

| 文档                            | 描述                    |
|:------------------------------|:----------------------|
| [扩展功能文档](EXTENSIONS.md)       | Groovy 脚本扩展的详细配置和开发指南 |
| [数据源配置文档](DATASOURCE.md)      | 数据源的详细配置、多环境管理和最佳实践   |
| [SQL 安全控制文档](SQL_SECURITY.md) | SQL 安全策略的配置和管理        |

## 环境要求

- **JDK 21+**
- **Maven 3.6+**
