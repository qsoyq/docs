# ci

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

## kaniko

构建并推送镜像

```shell
docker run -it --rm -v ~/.docker/config.json:/kaniko/.docker/config.json -v $codedir:/workspace  gcr.io/kaniko-project/executor:v1.9.0-debug  -d $PUSH_IMAGE
```
