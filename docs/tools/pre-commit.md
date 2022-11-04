# pre-commit

[pre-commit](https://pre-commit.com/#intro)

在 git commit 之前运行, 对项目进行检查和格式化.

需要在git项目根目录创建 `.pre-commit-config.yaml` 配置文件.

```shell
pip install pre-commit    # 安装 pre-commit 工具
pre-commit install        # Install the pre-commit script.
pre-commit run --all-file # Run hooks.
pre-commit sample-config  # Produce a sample .pre-commit-config.yaml file
```

[pre-commit插件](https://github.com/qsoyq/precommit)实现

## Python pre-commit 配置模板

```yaml
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v3.2.0
    hooks:
      - id: check-yaml
      - id: check-toml
      - id: check-json
      - id: check-added-large-files
      - id: debug-statements
      - id: end-of-file-fixer
      - id: mixed-line-ending
        files: "\\.(py|txt|yaml|json|md|toml|lock|cfg|html|sh|js|yml)$"
      - id: trailing-whitespace
        files: "\\.(py|txt|yaml|json|md|toml|lock|cfg|html|sh|js|yml)$"
      - id: check-case-conflict
      - id: check-docstring-first
      - id: check-byte-order-marker
      - id: check-added-large-files
      - id: check-executables-have-shebangs


-   repo: https://github.com/pre-commit/mirrors-yapf
    rev: v0.32.0
    hooks:
      - id: yapf
        args: ["-r", "-i"]


-   repo: https://github.com/pycqa/isort
    rev: v5.10.1
    hooks:
      - id: isort
        files: "\\.(py)$"
        args: [--settings-path=pyproject.toml]


-   repo: https://github.com/hadialqattan/pycln
    rev: v1.1.0 # Possible releases: https://github.com/hadialqattan/pycln/releases
    hooks:
      - id: pycln
        args: [--config=pyproject.toml]


# -   repo: https://github.com/pre-commit/mirrors-mypy
#     rev: "v0.910"
#     hooks:
#     -   id: mypy
#         args: [--config=pyproject.toml]
#         additional_dependencies:
#             - pydantic
#             - sqlalchemy-stubs

```

## 对于 pre-commit 冲突

如果遇到 hook 冲突, 比如 yapf 和 isort 对于代码的格式化结果不一致, 就会陷入无法提交的困境.

一种办法是尽量让两者存在交集的地方保持兼容, 而这也是目前我在尝试的, 比如对于 `multi_line_output` 的风格统一.

一种办法是尽量让两者存在交集的地方, 一者直接跳过, 但是没有在 yapf 中找到[Ignore imports](https://github.com/google/yapf/issues/429)的方案.

如果上述两者都无法做到, 那就只能放弃其中不太重要的一者了.
