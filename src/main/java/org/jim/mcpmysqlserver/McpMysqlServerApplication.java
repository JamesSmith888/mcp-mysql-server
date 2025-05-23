package org.jim.mcpmysqlserver;

import lombok.extern.slf4j.Slf4j;
import org.jim.mcpmysqlserver.mcp.MysqlOptionService;
import org.jim.mcpmysqlserver.util.PortUtils;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/**
 * 应用主类
 * @author yangxin
 */
@SpringBootApplication
@Slf4j
public class McpMysqlServerApplication {

    /**
     * 应用默认端口
     */
    private static final int DEFAULT_PORT = 9433;

    /**
     * 应用启动入口
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        // 从命令行参数或环境变量中获取端口号，默认为9433
        int port = getPortFromArgs(args, DEFAULT_PORT);

        // 检查端口是否已被占用
        if (PortUtils.isPortInUse(port)) {
            log.warn("Port {} is already in use. Trying to start with a random available port...", port);
            // 获取一个随机可用端口
            int randomPort = PortUtils.findAvailablePort();
            if (randomPort <= 0) {
                log.error("Failed to find an available port. Exiting...");
                System.exit(1);
                return;
            }

            // 设置系统属性，使Spring Boot使用新的端口
            log.info("Using random available port: {}", randomPort);
            System.setProperty("server.port", String.valueOf(randomPort));
        }

        // 获取最终使用的端口号（可能是随机分配的）
        String finalPort = System.getProperty("server.port", String.valueOf(port));
        log.info("Starting application on port {}", finalPort);
        SpringApplication.run(McpMysqlServerApplication.class, args);
    }

    /**
     * 从命令行参数中获取端口号
     * 支持两种格式：--server.port=9433 或 -Dserver.port=9433
     *
     * @param args 命令行参数
     * @param defaultPort 默认端口
     * @return 解析到的端口号，如果未指定则返回默认端口
     */
    private static int getPortFromArgs(String[] args, int defaultPort) {
        // 检查命令行参数
        if (args != null) {
            for (String arg : args) {
                // 检查--server.port=xxx格式
                if (arg.startsWith("--server.port=")) {
                    try {
                        return Integer.parseInt(arg.substring("--server.port=".length()));
                    } catch (NumberFormatException e) {
                        log.warn("Invalid port number in argument: {}", arg);
                    }
                }
                // 检查-Dserver.port=xxx格式
                else if (arg.startsWith("-Dserver.port=")) {
                    try {
                        return Integer.parseInt(arg.substring("-Dserver.port=".length()));
                    } catch (NumberFormatException e) {
                        log.warn("Invalid port number in argument: {}", arg);
                    }
                }
            }
        }

        // 检查系统属性
        String systemPort = System.getProperty("server.port");
        if (systemPort != null && !systemPort.isEmpty()) {
            try {
                return Integer.parseInt(systemPort);
            } catch (NumberFormatException e) {
                log.warn("Invalid port number in system property: {}", systemPort);
            }
        }

        // 返回默认端口
        return defaultPort;
    }


    @Bean
    public ToolCallbackProvider mysqlToolCallbackProvider(MysqlOptionService mysqlOptionService) {
        return MethodToolCallbackProvider.builder()
                .toolObjects(mysqlOptionService)
                .build();
    }
}
