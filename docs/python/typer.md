# typer

[typer](https://typer.tiangolo.com/) 是基于 click 的命令行工具库, 最大的特点是对类型注解支持友好, 代码可读性很强.

## Set default command

```python
@app.command()
def serve(address: str = typer.Option("0.0.0.0:8000", '--address', '-a')):
    _cwd = cwd
    cmd = f'mkdocs serve -a {address}'
    args = shlex.split(cmd)
    p = subprocess.run(args, capture_output=False, text=True, cwd=_cwd.absolute())
    if p.returncode != 0:
        typer.echo(bad_message(f"{cmd} failed."))
        raise typer.Exit(p.returncode)


@app.callback(invoke_without_command=True)
def build(site_dir: Optional[Path] = typer.Option(None, '--site', '-s'),):
    if site_dir is None:
        site_dir = cwd / 'site'

    cmd = f'mkdocs build -d {site_dir}'
    args = shlex.split(cmd)
    p = subprocess.run(args, capture_output=False, text=True, cwd=cwd.absolute())
    if p.returncode != 0:
        typer.echo(bad_message(f"{cmd} failed."))
        raise typer.Exit(p.returncode)
```

如上代码所示, 本意是想为 typer app 添加一个默认命令, 比如 build, 这样对于一些脚本有最常用的命令时比较方便.

但是`callback` 是在所有命令中都会被触发的.

如果在`serve`里, 也触发`build`, 是不符合预期的.

在这种情况, 可以使用 typer.Context, 根据当前上下文中的命令, 来控制处理逻辑.

```python
@app.callback(invoke_without_command=True)
def build(ctx: typer.Context, site_dir: Optional[Path] = typer.Option(None, '--site', '-s')):
    # 当前函数使用回调作为默认命令
    # 如果调用了其他子命令的情况, 退出当前函数处理流程
    typer.echo(f'{ctx.invoked_subcommand}, {inspect.stack()[0].function}')
    if ctx.invoked_subcommand  and ctx.invoked_subcommand != inspect.stack()[0].function:
        return

    if site_dir is None:
        site_dir = cwd / 'site'

    cmd = f'mkdocs build -d {site_dir}'
    args = shlex.split(cmd)
    p = subprocess.run(args, capture_output=False, text=True, cwd=cwd.absolute())
    if p.returncode != 0:
        typer.echo(bad_message(f"{cmd} failed."))
        raise typer.Exit(p.returncode)
```
