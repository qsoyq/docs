# cursor-cli

## 使用须知

通过别名使用

```bash
alias agentx='agent --sandbox enabled --approve-mcps --model gpt-5.2 -p'
```

```bash
agentx "检查目录下所有的 markdown 文件, 并修复格式问题"
```

- `api-key` 在 [dashboard -> integrations](https://cursor.com/cn/dashboard?&tab=integrations) 下配置
- 在脚本中将 `--print` 与 `--force` 结合使用来修改文件：

### 命令行参数

| 参数                       | 说明                                                                                                   | 默认值   |
| -------------------------- | ------------------------------------------------------------------------------------------------------ | -------- |
| `--api-key <key>`          | API 密钥用于身份验证（也可使用 `CURSOR_API_KEY` 环境变量）                                             | -        |
| `-p, --print`              | 将响应打印到控制台（用于脚本或非交互式使用）。可访问所有工具，包括写入和 bash                          | `false`  |
| `--output-format <format>` | 输出格式（仅在 `--print` 模式下有效）：`text` \| `json` \| `stream-json`                               | `text`   |
| `--mode <mode>`            | 以指定的执行模式启动。`plan`：只读/规划模式（分析、提出计划，不编辑）。`ask`：问答式解释和提问（只读） | -        |
| `--plan`                   | 以 plan 模式启动（`--mode=plan` 的简写）。如果传递了 `--cloud` 则忽略                                  | `false`  |
| `--model <model>`          | 使用的模型（例如：`gpt-5`、`sonnet-4`、`sonnet-4-thinking`）                                           | -        |
| `-f, --force`              | 强制允许命令（除非明确拒绝, 允许代理在无需确认的情况下直接修改文件）                                   | `false`  |
| `--sandbox <mode>`         | 明确启用或禁用沙箱模式（覆盖配置）：`enabled` \| `disabled`                                            | -        |
| `--approve-mcps`           | 自动批准所有 MCP 服务器（仅在 `--print`/无头模式下有效）                                               | `false`  |
| `--workspace <path>`       | 要使用的工作区目录（默认为当前工作目录）                                                               | 当前目录 |
