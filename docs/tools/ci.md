# ci

## kaniko

构建并推送镜像

```shell
docker run -it --rm -v ~/.docker/config.json:/kaniko/.docker/config.json -v $codedir:/workspace  gcr.io/kaniko-project/executor:v1.9.0-debug  -d $PUSH_IMAGE
```

[kaniko github action](https://github.com/aevea/action-kaniko)

## Gitlab CI Runner

安装 Runner

```shell
docker run -d --name gitlab-runner --restart always \
-v /etc/gitlab-runner:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ~/.docker/config.json:$HOME/.docker/config.json \
-v /usr/bin/docker:/usr/local/bin/docker \
-v /usr/local/bin/docker-compose:/usr/local/bin/docker-compose \
gitlab/gitlab-runner:latest
```

导出注册 Token

```shell
export REGISTRATION_TOKEN={}
```

注册 Runner

```shell
docker exec -it gitlab-runner gitlab-runner register --url https://gitlab.com/ --registration-token $REGISTRATION_TOKEN
```

注册 runner 时, tag 需要和项目中指定的 tag 匹配. 可在 gitlab 控制台修改 tag 列表.

注册 runner 时, 可以随意指定 docker executor. 在项目配置文件中, 可以指定覆盖 image.

gitlab-ci 配置文件模板

```yaml
stages:
  - build
  - notify

build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - |
      cat > /kaniko/.docker/config.json << EOF
      {
        "auths": {
          "https://index.docker.io/v1/": {
            "auth": "${AUTH}"
          }
        }
      }
      EOF
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination ${PUSH_IMAGE}
  tags:
    - zimaboard
  only:
    - main

notify:
  stage: notify
  script:
    - if [ -n ${BARK_TOKEN} ]; then curl https://api.day.app/$(BARK_TOKEN)/project%20ci%20build%20success; fi;
  tags:
    - zimaboard
  only:
    - main

```

 将 `pull_policy = "if-not-present"` 写入配置, 避免每次作业都重新拉取镜像

```conf
[[runners]]
  name = ""
  url = ""
  token = ""
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = ""
    privileged = false
    disable_cache = false
    volumes = ["/cache"]
    pull_policy = "if-not-present"
    shm_size = 0
  [runners.cache]
```

## Github Actions

[github-actions](https://docs.github.com/cn/actions)

[workflow-syntax-for-github-actions](https://docs.github.com/cn/actions/using-workflows/workflow-syntax-for-github-actions)

[hosting-your-own-runners](https://docs.github.com/cn/actions/hosting-your-own-runners)

部署容器作为 self-hosted 环境

github runner 不允许以 root 用户身份执行命令, 所以在启动容器时可以指定非 root 用户, 或者指定环境变量 `RUNNER_ALLOW_RUNASROOT=1`

### 基于 debian 构建镜像

```shell
docker run -d --name github-runner \
--restart unless-stopped \
-u 1000:1000 \
-w /github/actions-runner \
-v /etc/passwd:/etc/passwd:ro \
-v /github/actions-runner:/github/actions-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/local/bin/docker \
debian:11 sleep infinity
```

```shell
# 修改容器 root 密码
docker exec -it -u 0 github-runner bash -c "echo 'root:root' | chpasswd"

# 以 root 身份安装 runner

docker exec -it -u 0 github-runner bash -c "apt update"

docker exec -it -u 0 github-runner bash -c "apt install -y curl"

docker exec -it -u 0 github-runner bash -c "curl -o actions-runner-linux-x64-2.298.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.298.2/actions-runner-linux-x64-2.298.2.tar.gz"

docker exec -it -u 0 github-runner bash -c "tar xzf ./actions-runner-linux-x64-2.298.2.tar.gz"

docker exec -it -u 0 github-runner bash -c "./bin/installdependencies.sh"

docker exec -it -u 1000 github-runner bash -c "./config.sh"

# 前台运行 runner
docker exec -it -u 1000 github-runner bash -c "./run.sh"


# 注册 runner 为系统服务
# https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service
docker exec -it -u 0 github-runner bash -c "apt install -y systemctl"
docker exec -it -u 0 github-runner bash -c "./svc.sh install"
docker exec -it -u 0 github-runner bash -c "./svc.sh start"
```

### 基于自封装镜像

```shell
docker run -d --name github-runner-{repo-name} \
--restart unless-stopped \
-w /github/actions-runner \
-v github-runner-{repo-name}:/github/actions-runner \
-v /github/actions-runner/_work/{repo-name}:/github/actions-runner/_work/{repo-name} \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/local/bin/docker \
--platform linux/x86_64 \
qsoyq/github-action-image
```

根据交互提示, 输入对应的仓库地址和注册 token

```shell
docker exec -it github-runner-{repo-name} bash -c "./config.sh"
```

注册系统服务

```shell
docker exec -it -u 0 github-runner-{repo-name} bash -c "./svc.sh install"
```

启动

```shell
docker exec -it -u 0 github-runner-{repo-name} bash -c "./svc.sh start"
```

### github actions 本地配置

main分支推送时构建并推送镜像

```yaml
name: Docker build for main branch
on:
  push:
    branches:
      - 'main'
jobs:
  docker:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@master
      - name: Kaniko build
        uses: aevea/action-kaniko@master
        with:
          image: ${{ secrets.IMAGE }}
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
          cache: true
          cache_registry: aevea/cache
          tag: latest

```

release 发布时构建并推送镜像

```yaml
name: Docker build for release
on:
  release:
    types: [published]

jobs:
  docker:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@master
      - name: Kaniko build
        uses: aevea/action-kaniko@master
        with:
          image: ${{ secrets.IMAGE }}
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
          cache: true
          cache_registry: aevea/cache
          tag: ${{ github.ref_name }}
```
