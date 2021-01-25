# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.15 as builder

# Copy local code to the container image.
WORKDIR /app

# Retrieve application dependencies using go modules.
# Allows container builds to reuse downloaded dependencies.
COPY go.* ./
#RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
# -mod=readonly ensures immutable go.mod and go.sum in container builds.
RUN CGO_ENABLED=0 GOOS=linux GOPROXY="https://goproxy.cn",direct go build -mod=readonly  -v -o helloworld

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3.9

# 更新Alpine的软件源为阿里云，因为从默认官源拉取实在太慢了
RUN echo http://mirrors.aliyun.com/alpine/v3.9/main/ > /etc/apk/repositories && \
echo http://mirrors.aliyun.com/alpine/v3.9/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade

# 运行指定的命令
## Alpine linux为了精简本身并没有安装太多的常用软件,apk类似于ubuntu的apt-get，
## 用来安装一些常用软V件，其语法如下：apk add bash wget curl git make vim docker
## wget是linux下的ftp/http传输工具，没安装会报错“/bin/sh: 　　wget: not found”，网上例子少安装wget
## ca-certificates证书服务，是安装glibc前置依赖
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/httptester /httptester

# Run the web service on container startup.
CMD ["/httptester"]

# 执行docker build构建镜像
# docker build -t tektoncd-test/httptester .
