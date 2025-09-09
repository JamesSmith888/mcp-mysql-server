# SQL安全控制功能

SQL安全控制功能可以防止AI模型执行危险的数据库操作，如UPDATE、DELETE、DROP等，确保数据安全。支持全局和单数据源级别的控制。

## 配置方式

在 `datasource.yml` 文件中为每个数据源配置独立的安全策略：
src/main/resources/datasource.yml

```yaml
datasource:
  security: # 全局默认配置
    # 排除掉不需要检查的数据源。允许所有操作
    exclude-datasources:
      - db1
      - db2
    dangerous-keywords:
      - update
      - delete
  datasources: # 多数据源配置，详情见 src/main/resources/datasource.yml
    db1:
    db2:
    db3:
      readonly: true  # 只读数据源优先级最高，安全检查自动禁用
    db4:
      security: # 数据源级别配置
        dangerous-keywords:
          - drop
          - truncate
```

## 配置参数详解

### 全局（datasource）配置参数

| 参数                            | 类型      | 默认值   | 描述      |
|:------------------------------|:--------|:------|:--------|
| `readonly`                    | Boolean | false | 全局只读设置  |
| `security.dangerous-keywords` | Array   | 见配置示例 | 危险关键字列表 |

### 数据源级别（datasources）配置参数

| 参数                            | 类型      | 默认值    | 描述                                      |
|:------------------------------|:--------|:-------|:----------------------------------------|
| `readonly`                    | Boolean | 继承全局设置 | 数据源只读设置                                 |
| `security.enabled`            | Boolean | true   | 该数据源是否启用安全检查，只有全局启用时才需此项                |
| `security.dangerous-keywords` | Array   | 继承全局设置 | 该数据源危险关键字列表。与全局`dangerous-keywords`取并集。 |

**注意：** 当 `readonly: true` 时，`security` 配置将被忽略，安全检查自动禁用。

## 错误提示

### 安全检查失败时的错误信息

当AI模型尝试执行被禁止的操作时，会收到详细的错误提示：

```json
{
  "error": "Dangerous SQL operation keyword 'DELETE' detected. This operation has been blocked for data security.\nTo execute this type of operation, please configure in datasource.yml:\n1) Set readonly=true for read-only access, or\n2) Set security.enabled=false to disable SQL security checks, or\n3) Remove the 'delete' keyword from the security.dangerous-keywords list.\nPlease restart the service after modifying the configuration.",
  "detected_keyword": "delete",
  "sql_security_enabled": true,
  "datasource": "production"
}
```
