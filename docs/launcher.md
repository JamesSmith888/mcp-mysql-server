# 统一启动脚本

这个跨平台启动脚本支持Windows、macOS和Linux，会自动下载所需的Java 21运行时环境，然后启动Spring Boot应用。

## 🚀 快速开始

### 方式1: 使用快捷启动器 (推荐)
```bash
./start
```

### 方式2: 直接使用统一脚本
```bash
./scripts/start.sh
```

## 🌍 平台支持

| 平台 | 环境要求 | 状态 |
|------|----------|------|
| **macOS** | 原生Terminal/iTerm | ✅ 完全支持 |
| **Linux** | Bash shell | ✅ 完全支持 |
| **Windows** | Git Bash (推荐) | ✅ 完全支持 |
| **Windows** | WSL/WSL2 | ✅ 完全支持 |
| **Windows** | PowerShell | ✅ 支持 |
| **Windows** | CMD | ❌ 不支持 |

> **注意**: Windows用户推荐使用Git Bash，它随Git一起安装，提供最佳兼容性。

## ✨ 主要特性

✅ **一键启动**: 直接运行即可启动Spring Boot应用  
✅ **跨平台统一**: 一个脚本支持所有主流平台  
✅ **智能Java管理**: 优先使用系统Java，需要时自动下载  
✅ **架构检测**: 自动检测x64/ARM64/Apple Silicon  
✅ **Windows兼容**: 完美支持Git Bash、WSL等环境  
✅ **缓存机制**: 下载一次，永久使用  
✅ **详细日志**: 彩色输出，清晰的执行步骤  

## 📁 目录结构

```
project-root/
├── start                    # 快捷启动器
├── scripts/
│   └── start.sh            # 统一跨平台脚本
├── docs/
│   └── launcher.md         # 启动器文档 (本文件)
├── mvnw                    # Maven Wrapper (Unix)
├── mvnw.cmd               # Maven Wrapper (Windows)
└── pom.xml                # Maven项目配置
```

## 🔧 执行的命令

脚本会执行以下命令：
```bash
./mvnw -q -f /path/to/project/pom.xml spring-boot:run
```

参数说明：
- `-q`: 静默模式，减少输出
- `-f`: 指定pom.xml文件路径
- `spring-boot:run`: 启动Spring Boot应用

## 🗂️ Java环境管理

### 系统Java检测
脚本会首先检查系统是否已安装Java 21+：
- ✅ 如果版本满足要求，直接使用
- ❌ 如果版本不足或未安装，自动下载

### JRE安装位置
- **Unix系统**: `~/.jres/amazon-corretto-jre-21-{platform}`
- **Windows**: `%USERPROFILE%\.jres\amazon-corretto-jre-21-{platform}`

## 🎯 首次运行

首次运行时会：
1. 检测操作系统和架构
2. 检查系统Java版本
3. 如果需要，下载适合的Amazon Corretto JRE
4. 解压并配置环境变量
5. 启动Spring Boot应用

后续运行会直接使用已配置的Java环境。

## 🔧 故障排除

### Windows环境问题
如果在Windows上遇到问题：

1. **推荐解决方案** - 使用Git Bash：
   ```bash
   # 在Git Bash中运行
   ./start
   ```

2. **PowerShell解决方案**：
   ```powershell
   # 在PowerShell中运行
   bash ./start
   ```

3. **WSL解决方案**：
   ```bash
   # 在WSL中运行
   ./start
   ```

### 下载失败
- 检查网络连接
- 确保有足够的磁盘空间 (约150MB)
- 某些企业网络可能需要代理配置

### 强制重新下载Java
如果需要重新下载Java：
```bash
# 删除JRE缓存目录
rm -rf ~/.jres/amazon-corretto-jre-21-*
```

### 权限问题
```bash
# 确保脚本有执行权限
chmod +x start
chmod +x scripts/start.sh
```

## 🏗️ 开发者信息

### 脚本架构
- **统一入口**: `scripts/start.sh` 是主脚本
- **平台检测**: 自动识别 Windows/macOS/Linux
- **Java管理**: 智能选择系统Java或下载Amazon Corretto
- **Maven集成**: 自动调用项目的Maven Wrapper

### 自定义配置
如需修改配置，编辑 `scripts/start.sh` 中的变量：
```bash
JAVA_VERSION=21                    # 所需Java版本
JRE_VENDOR="amazon-corretto"       # Java发行版
```
