# Docker Compose Setup for Multiple Services

This project includes a `docker-compose` configuration to deploy a stack of services, including MySQL, Nginx, Redis, Jaeger, and NSQ components. The services are configured to run together using Docker, with necessary environment variables and volumes defined.

## Services

### 1. **MySQL**

- **Image**: `mysql:${MYSQL_VERSION}`
- **Container Name**: `mysqld`
- **Environment Variables**:
  - `MYSQL_ROOT_PASSWORD`: The root password for MySQL.
  - `TZ`: Set to `Asia/Shanghai` timezone.
- **Ports**:
  - `${MYSQL_PORT}:${MYSQL_CONTAINER_PORT}`
- **Volumes**:
  - `/mnt/data/mysql` to `/var/lib/mysql` for database persistence.
  - `/mnt/logs/mysql` to `/var/log/mysql` for MySQL logs.
- **Command**: Custom MySQL configuration for replication and performance optimization.

### 2. **Nginx**

- **Image**: `nginx:latest`
- **Container Name**: `my-nginx`
- **Ports**:
  - `${NGINX_PORT_1}:${NGINX_CONTAINER_PORT_1}`
  - `${NGINX_PORT_2}:${NGINX_CONTAINER_PORT_2}`
- **Volumes**:
  - `./nginx/conf` to `/etc/nginx/conf.d` for Nginx configurations.
  - `./nginx/html` to `/usr/share/nginx/html` for HTML files.
- **Restart Policy**: Always restart unless stopped manually.

### 3. **Redis**

- **Image**: `redis:5.0.7`
- **Container Name**: `redis`
- **Command**: `redis-server --requirepass ${REDIS_PASSWORD}`
- **Ports**:
  - `${REDIS_PORT}:${REDIS_CONTAINER_PORT}`
- **Environment Variables**:
  - `REDIS_PASSWORD`: Password for Redis authentication.

### 4. **Jaeger**

- **Image**: `jaegertracing/all-in-one:1.55`
- **Container Name**: `jaeger`
- **Environment Variables**:
  - `COLLECTOR_ZIPKIN_HOST_PORT`: Set to `":9411"`.
- **Ports**:
  - Multiple Jaeger ports (e.g., `${JAEGER_PORT_1}:${JAEGER_CONTAINER_PORT_1}`, etc.) for various Jaeger services.

### 5. **NSQ**

- **NSQLookupd**
  - **Image**: `nsqio/nsq`
  - **Ports**:
    - `${NSQLOOKUPD_PORT_1}:${NSQLOOKUPD_CONTAINER_PORT_1}`
    - `${NSQLOOKUPD_PORT_2}:${NSQLOOKUPD_CONTAINER_PORT_2}`
  - **Volumes**:
    - `./nsqlookupd.conf` to `/etc/nsqlookupd/nsqlookupd.conf`.
    - `./logs/lookupd_log` to `/logs/lookupd_log`.
- **NSQD**
  - **Image**: `nsqio/nsq`
  - **Ports**:
    - `${NSQD_PORT_1}:${NSQD_CONTAINER_PORT_1}`
    - `${NSQD_PORT_2}:${NSQD_CONTAINER_PORT_2}`
  - **Volumes**:
    - `./nsqd.conf` to `/etc/nsqd/nsqd.conf`.
    - `./data` to `/nsq-data`.
    - `./logs/nsqd_log` to `/logs/nsqd`.
- **NSQAdmin**
  - **Image**: `nsqio/nsq`
  - **Ports**:
    - `${NSQADMIN_PORT}:${NSQADMIN_CONTAINER_PORT}`

## Environment Variables

Create a `.env` file with the following content:

```env
# version for mysql
MYSQL_VERSION=8.0.19

# password for mysql
MYSQL_PASSWORD=changeme

# port for mysql
MYSQL_PORT=3306

# port for mysql container
MYSQL_CONTAINER_PORT=3306

# port for redis
REDIS_PORT=6379

# port for redis container
REDIS_CONTAINER_PORT=6379

# password for redis
REDIS_PASSWORD=changeme

# port for nginx
NGINX_PORT_1=80
NGINX_PORT_2=8080

# port for nginx container
NGINX_CONTAINER_PORT_1=80
NGINX_CONTAINER_PORT_2=8080

# ports for jaeger
JAEGER_PORT_1=6831
JAEGER_PORT_2=6832
JAEGER_PORT_3=5778
JAEGER_PORT_4=16686
JAEGER_PORT_5=4317
JAEGER_PORT_6=4318
JAEGER_PORT_7=14250
JAEGER_PORT_8=14268
JAEGER_PORT_9=14269
JAEGER_PORT_10=9411

# ports for jaeger container
JAEGER_CONTAINER_PORT_1=6831
JAEGER_CONTAINER_PORT_2=6832
JAEGER_CONTAINER_PORT_3=5778
JAEGER_CONTAINER_PORT_4=16686
JAEGER_CONTAINER_PORT_5=4317
JAEGER_CONTAINER_PORT_6=4318
JAEGER_CONTAINER_PORT_7=14250
JAEGER_CONTAINER_PORT_8=14268
JAEGER_CONTAINER_PORT_9=14269
JAEGER_CONTAINER_PORT_10=9411

# ports for nsqlookupd
NSQLOOKUPD_PORT_1=4161
NSQLOOKUPD_PORT_2=4160

# ports for nsqlookupd container
NSQLOOKUPD_CONTAINER_PORT_1=4161
NSQLOOKUPD_CONTAINER_PORT_2=4160

# ports for nsqd
NSQD_PORT_1=4151
NSQD_PORT_2=4150

# ports for nsqd container
NSQD_CONTAINER_PORT_1=4151
NSQD_CONTAINER_PORT_2=4150

# port for nsqadmin
NSQADMIN_PORT=4171

# port for nsqadmin container
NSQADMIN_CONTAINER_PORT=4171
```

| 端口  | 协议       | 组件              | 用途                               |
| ----- | ---------- | ----------------- | ---------------------------------- |
| 6831  | UDP        | Jaeger Agent      | Thrift over UDP（追踪数据）        |
| 6832  | UDP        | Jaeger Agent 备用 | Thrift over UDP                    |
| 5778  | TCP (HTTP) | Jaeger Collector  | Zipkin 格式（Thrift）追踪数据      |
| 16686 | TCP (HTTP) | Jaeger Query      | Jaeger Web UI                      |
| 4317  | TCP (gRPC) | Jaeger Collector  | OpenTelemetry gRPC 追踪数据        |
| 4318  | TCP (HTTP) | Jaeger Collector  | OpenTelemetry HTTP 追踪数据        |
| 14250 | TCP (gRPC) | Jaeger Collector  | Jaeger 原生 gRPC 追踪数据          |
| 14268 | TCP (HTTP) | Jaeger Collector  | Jaeger 原生 HTTP 追踪数据          |
| 14269 | TCP (HTTP) | Jaeger Collector  | 管理端口（健康检查、指标）         |
| 9411  | TCP (HTTP) | Jaeger Collector  | Zipkin 格式（JSON/Thrift）追踪数据 |

1. 6831/udp
   用途: Jaeger 客户端（如应用程序中的 Jaeger SDK）通过 UDP 协议向 Jaeger Agent 发送追踪数据（spans）。这是 Jaeger 的默认 Thrift over UDP 端口，用于高效的追踪数据传输。
   协议: UDP
   组件: Jaeger Agent
   说明: 通常用于轻量级、高性能的追踪数据收集，适合生产环境中客户端直接向 Agent 发送数据。
2. 6832/udp
   用途: 备用 UDP 端口，通常用于 Jaeger 的 Thrift over UDP 协议，功能与 6831 类似，但在某些情况下用于分离不同的追踪数据流或处理高负载场景。
   协议: UDP
   组件: Jaeger Agent
   说明: Jaeger 官方文档中提到此端口较少使用，但在 all-in-one 镜像中仍开放，可能用于特定配置或调试。

3. 5778
   用途: 用于接收 Zipkin 格式的追踪数据（Thrift 编码）。这是 Jaeger Collector 的一个 HTTP 端点，允许兼容 Zipkin 的客户端通过 HTTP 发送追踪数据。
   协议: TCP (HTTP)
   组件: Jaeger Collector
   说明: 如果你的系统中有服务使用 Zipkin 协议（而非 Jaeger 原生协议），可以通过此端口与 Jaeger 集成。

4. 16686
   用途: Jaeger Web UI 的端口。用户可以通过浏览器访问 http://<jaeger-host>:16686 来查看追踪数据、调用链和服务依赖图。
   协议: TCP (HTTP)
   组件: Jaeger Query Service
   说明: 这是 Jaeger 的前端界面端口，供开发者和运维人员分析追踪数据，是最常用的交互端口。
5. 4317
   用途: 用于接收 OpenTelemetry gRPC 格式的追踪数据。这是 OpenTelemetry 协议（OTLP）的 gRPC 端点，Jaeger 支持直接接收 OTLP 数据。
   协议: TCP (gRPC)
   组件: Jaeger Collector
   说明: OpenTelemetry 是现代追踪和监控的标准协议，此端口允许 Jaeger 与支持 OTLP 的客户端集成。
6. 4318
   用途: 用于接收 OpenTelemetry HTTP 格式的追踪数据。这是 OTLP 协议的 HTTP 端点，适合需要通过 HTTP 发送追踪数据的场景。
   协议: TCP (HTTP)
   组件: Jaeger Collector
   说明: 与 4317 类似，但使用 HTTP 协议，适合无法使用 gRPC 的环境。
7. 14250
   用途: Jaeger Collector 的 gRPC 端口，用于接收 Jaeger 原生格式的追踪数据（通过 gRPC 协议）。
   协议: TCP (gRPC)
   组件: Jaeger Collector
   说明: 这是 Jaeger Agent 或客户端直接向 Collector 发送追踪数据的主要 gRPC 端口，适合高性能场景。
8. 14268
   用途: Jaeger Collector 的 HTTP 端口，用于接收 Jaeger 原生格式的追踪数据（通过 HTTP 协议）。
   协议: TCP (HTTP)
   组件: Jaeger Collector
   说明: 允许客户端通过 HTTP 发送追踪数据，适合不使用 gRPC 的场景。
9. 14269
   用途: Jaeger Collector 的管理端口（Admin Port），用于健康检查、指标收集（如 Prometheus 指标）和其他管理功能。
   协议: TCP (HTTP)
   组件: Jaeger Collector
   说明: 通常用于监控 Jaeger 服务的运行状态，例如通过 /metrics 端点暴露 Prometheus 指标。
10. 9411
    用途: 用于接收 Zipkin 格式的追踪数据（JSON 或 Thrift 编码），兼容 Zipkin 的 HTTP API。这是 Zipkin Collector 的标准端口。
    协议: TCP (HTTP)
    组件: Jaeger Collector
    说明: 你的配置中通过 COLLECTOR_ZIPKIN_HOST_PORT=:9411 明确启用了 Zipkin 兼容模式，允许 Zipkin 客户端通过此端口发送追踪数据。

## Usage

1. Make sure you have Docker and Docker Compose installed.
2. Clone the repository and navigate to the project directory.
3. Create the `.env` file in the root directory with the environment variables above.
4. Run the following command to start all services

```shell
docker-compose up -d
```

This will launch all the services in detached mode.

## Volumes and Logs

- **MySQL**: Data is persisted under `/mnt/data/mysql`.
- **Nginx**: Configuration and HTML files are stored under `./nginx/conf` and `./nginx/html`.
- **Redis**: Logs and data can be found under `/mnt/logs/redis`.
- **Jaeger**: The Jaeger instance will persist data based on the provided port configurations.

##

## Shutdown

To stop the services, use the following command:

```
docker-compose down
```

This will stop and remove the containers but keep the data volumes intact.
