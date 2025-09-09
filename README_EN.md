# MCP MySQL Server

A Spring AI-based MCP capable of executing any SQL query.
> For support of other databases, see [mcp-db-server](https://github.com/JamesSmith888/mcp-db-server)

[中文文档](README.md) | [English Documentation](README_EN.md)

## Quick Start

### 1. MCP JSON Configuration

#### Method 1: Maven Wrapper Startup

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

#### Method 2: JAR Package Startup

Build the JAR package

```bash
./mvnw clean package
```

Configure the MCP server

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

**Note:** The `-Dloader.path` parameter is optional and only needed when running extensions.

### 2. Data Source Configuration (Minimal Configuration)

Modify the `mcp-mysql-server/src/main/resources/datasource.yml` file:

```yaml
datasource:
  datasources:
    your_db1_name:
      url: jdbc:mysql://localhost:3306/db1
      username: root
      password: password
      default: true  # Mark as default data source
```

---

## Features

- **Multiple Data Source Support** - Configure and manage multiple database data sources
- **Dynamic Data Source Switching** - Switch between different data sources at runtime
- **Extension Features** - Extend functionality through Groovy scripts
- **SQL Security Control** - Prevent AI models from executing dangerous SQL operations

## Detailed Documentation

| Document                                                    | Description                                                                         |
|:------------------------------------------------------------|:------------------------------------------------------------------------------------|
| [Extensions Documentation](EXTENSIONS_EN.md)                | Detailed configuration and development guide for Groovy script extensions           |
| [Data Source Configuration Documentation](DATASOURCE_EN.md) | Detailed data source configuration, multi-environment management and best practices |
| [SQL Security Control Documentation](SQL_SECURITY_EN.md)    | Configuration and management of SQL security policies                               |

## Environment Requirements

- **JDK 21** or higher
- **Maven 3.6** or higher
