# SQL Security Control

SQL security control features can prevent AI models from executing dangerous database operations such as UPDATE, DELETE, DROP, etc., ensuring data security. This functionality supports both global configuration and fine-grained control at the data source level.

## Features

- **Global Security Control** - Unified security policy configuration
- **Data Source Level Control** - Set different security policies for different data sources
- **Read-only Data Source Support** - Read-only data sources automatically disable security checks
- **Keyword Detection Mechanism** - Block dangerous operations through keyword matching
- **Flexible Configuration** - Support enable/disable and custom dangerous keyword lists

## Configuration Methods

### Method 1: Traditional Global Configuration (application.yml)

Configure global SQL security control in the `application.yml` file:

```yaml
sql:
  security:
    # Whether to enable security check
    enabled: true
    # Dangerous keyword list (case insensitive)
    dangerous-keywords:
      - update
      - delete
      - insert
      - replace
      - drop
      - create
      - alter
      - truncate
      - grant
      - revoke
      - shutdown
      - restart
      - call
      - execute
      - commit
      - rollback
```

### Method 2: Data Source Level Configuration (Recommended)

Configure independent security policies for each data source in the `datasource.yml` file:

```yaml
datasource:
  # Global default configuration
  readonly: false
  security:
    enabled: true
    dangerous-keywords:
      - update
      - delete
      - drop
      - truncate
  
  datasources:
    # Production environment - strict security control
    production:
      url: jdbc:mysql://prod-server:3306/production_db
      username: prod_user
      password: prod_password
      default: true
      security:
        enabled: true
        dangerous-keywords:
          - update
          - delete
          - insert
          - drop
          - create
          - alter
          - truncate
    
    # Read-only analytics database - no security check needed
    analytics_readonly:
      url: jdbc:mysql://analytics-server:3306/analytics_db
      username: analytics_user
      password: analytics_password
      readonly: true  # Read-only data source, security check automatically disabled
    
    # Testing environment - lenient security control
    testing:
      url: jdbc:mysql://test-server:3306/test_db
      username: test_user
      password: test_password
      security:
        enabled: true
        dangerous-keywords:
          - drop
          - truncate  # Only prohibit the most dangerous operations
    
    # Development environment - disable security check
    development:
      url: jdbc:mysql://localhost:3306/dev_db
      username: dev_user
      password: dev_password
      security:
        enabled: false  # Allow all operations in development environment
```

## Configuration Priority

1. **Read-only data source has highest priority**: Data sources with `readonly: true` automatically disable SQL security checks
2. **Data source level configuration**: Overrides global configuration
3. **Global configuration**: Serves as default configuration

## Security Level Description

### Read-only Protection (Highest Level)
- Data source set to `readonly: true`
- Database connection layer set to read-only
- Automatically disable SQL security checks (because database layer already provides protection)

### Application Layer Security Check
- Block dangerous operations through keyword detection
- Support custom dangerous keyword lists
- Fine-grained configuration per data source

### No Protection Mode
- Set `security.enabled: false`
- Allow execution of all SQL operations
- Suitable for development environment or trusted environment

## Use Case Examples

### Scenario 1: Multi-environment Deployment
```yaml
datasource:
  security:
    enabled: true  # Global default enabled
    dangerous-keywords: ["drop", "truncate", "delete"]
  
  datasources:
    prod:
      url: jdbc:mysql://prod-server:3306/prod_db
      readonly: false
      security:
        enabled: true  # Production environment strict control
        dangerous-keywords: ["update", "delete", "insert", "drop", "create", "alter", "truncate"]
    
    test:
      url: jdbc:mysql://test-server:3306/test_db
      readonly: false
      security:
        enabled: true  # Testing environment moderate control
        dangerous-keywords: ["drop", "truncate"]
    
    dev:
      url: jdbc:mysql://localhost:3306/dev_db
      readonly: false
      security:
        enabled: false  # Development environment unrestricted
```

### Scenario 2: Read-only Analytics Scenario
```yaml
datasource:
  datasources:
    main_db:
      url: jdbc:mysql://main-server:3306/main_db
      readonly: false
      security:
        enabled: true
        dangerous-keywords: ["update", "delete", "drop"]
    
    report_db:
      url: jdbc:mysql://report-server:3306/report_db
      readonly: true  # Read-only database, security check automatically disabled
```

## Error Messages

### Error Information When Security Check Fails

When AI models attempt to execute prohibited operations, they will receive detailed error messages:

```json
{
  "error": "Dangerous SQL operation keyword 'DELETE' detected. This operation has been blocked for data security.\nTo execute this type of operation, please configure in datasource.yml:\n1) Set readonly=true for read-only access, or\n2) Set security.enabled=false to disable SQL security checks, or\n3) Remove the 'delete' keyword from the security.dangerous-keywords list.\nPlease restart the service after modifying the configuration.",
  "detected_keyword": "delete",
  "sql_security_enabled": true,
  "datasource": "production"
}
```

## Best Practices

1. **Production Environment**: Enable strict security control, including all dangerous keywords
2. **Testing Environment**: Enable moderate security control, only prohibit the most dangerous operations
3. **Development Environment**: Can disable security checks for development and debugging
4. **Read-only Scenarios**: Use `readonly: true` to get database layer protection
5. **Data Analytics**: Read-only data sources are suitable for AI models to perform data queries and analysis

## Configuration Parameters Reference

### Global Configuration Parameters

| Parameter | Type | Default | Description |
|:----------|:-----|:--------|:------------|
| `readonly` | Boolean | false | Global read-only setting |
| `security.enabled` | Boolean | true | Whether to enable SQL security check |
| `security.dangerous-keywords` | List<String> | See configuration example | Dangerous keyword list |

### Data Source Level Configuration Parameters

| Parameter | Type | Default | Description |
|:----------|:-----|:--------|:------------|
| `readonly` | Boolean | Inherit global setting | Data source read-only setting |
| `security.enabled` | Boolean | Inherit global setting | Data source security check switch |
| `security.dangerous-keywords` | List<String> | Inherit global setting | Data source dangerous keyword list |

**Note:** When `readonly: true`, `security` configuration will be ignored and security checks are automatically disabled.
