# MCP MySQL Server

## 🚀 快速启动

```bash
# 一键启动 (推荐)
./start

# 或者使用完整路径
./scripts/start.sh
```

## 📖 文档

- [启动器详细文档](docs/launcher.md) - 跨平台启动脚本使用指南
- [数据源配置](DATASOURCE.md) - 数据库连接配置
- [扩展系统](EXTENSIONS.md) - Groovy扩展开发指南

## 🌍 跨平台支持

| 平台 | 状态 | 推荐环境 |
|------|------|----------|
| macOS | ✅ | Terminal |
| Linux | ✅ | Bash |
| Windows | ✅ | Git Bash |

## 📁 项目结构

```
mcp-mysql-server/
├── start                   # 快捷启动器
├── scripts/               # 启动脚本目录
│   ├── start.sh          # 统一跨平台脚本
│   ├── start-old.sh      # 旧版macOS脚本 (备份)
│   └── start-old.bat     # 旧版Windows脚本 (备份)
├── docs/                 # 文档目录
│   └── launcher.md       # 启动器文档
├── src/                  # 源代码
├── mvnw                  # Maven Wrapper
└── pom.xml              # Maven配置
```

## 🔧 开发

项目使用Maven构建，Java 21+运行。启动脚本会自动处理Java环境配置。

更多详细信息请查看 [启动器文档](docs/launcher.md)。
