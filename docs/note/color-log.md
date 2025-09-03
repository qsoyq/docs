
## 前因

为了方便在终端上查看日志, 带色彩的文本, 能更轻松地定位到关注的信息.

日志输出到终端的时候能显示色彩, 本质原理就是终端匹配到了表示颜色的前缀, 以及表示结束色彩的后缀, 那么中间这部分字符串, 就会按照前缀里指定的颜色进行输出.

## 思路

那么基本的实现思路, 无非两种.

1. 在输出文本的时候, 对文本内容进行封装. 虽然灵活, 但是繁琐.
2. 在格式化日志的时候, 按照格式, 如`"%(levelname)s"`, 对格式内容进行封装. 泛用性高, 但是定制性差.

## 实现

最终还是选择了以格式化为基本的做法, 简单更加重要.

顺便一提, `click.style` 函数封装了在终端显示文本时的色彩等样式功能, 使用起来非常方便.

```python
class CustomFormatter(logging.Formatter):

    _format = LoggerSettings().logger_default_formatter

    log_colors: dict[int,
                     list[tuple[str,
                                str]]] = {
                                    logging.DEBUG: [
                                        ("%(levelname)s",
                                         "cyan"),
                                        ("%(message)s",
                                         "cyan"),
                                    ],
                                    logging.INFO: [("%(levelname)s",
                                                    "green"),
                                                   ("%(message)s",
                                                    "green")],
                                    logging.WARNING: [("%(levelname)s",
                                                       "yellow")],
                                    logging.ERROR: [("%(levelname)s",
                                                     "red")],
                                    logging.CRITICAL: [("%(levelname)s",
                                                        "bright_red")],
                                }

    def format(self, record: logging.LogRecord):
        log_fmt = self._format

        if LoggerSettings().logger_use_color:
            color_handlers: list[tuple[str, str]] = self.log_colors.get(record.levelno, [])
            for text, color in color_handlers:
                log_fmt = log_fmt.replace(text, click.style(str(text), fg=color))

        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)
```
