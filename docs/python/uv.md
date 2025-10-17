# uv

- <https://docs.astral.sh/uv/>

## Versions

- uv python install: Install Python versions.
- uv python list: View available Python versions.
- uv python find: Find an installed Python version.
- uv python pin: Pin the current project to use a specific Python version.
- uv python uninstall: Uninstall a Python version.

## Scripts

uv run: Run a script.
uv add --script: Add a dependency to a script.
uv remove --script: Remove a dependency from a script.

## Project

uv init: Create a new Python project.
uv add: Add a dependency to the project.
uv remove: Remove a dependency from the project.
uv sync: Sync the project's dependencies with the environment.
uv lock: Create a lockfile for the project's dependencies.
uv run: Run a command in the project environment.
uv tree: View the dependency tree for the project.
uv build: Build the project into distribution archives.
uv publish: Publish the project to a package index.

### dependency

```bash
uv add 'requests==2.31.0'
uv add 'httpx[http2,socks]'
uv add git+https://github.com/psf/requests
uv add -r requirements.txt -c constraints.txt
uv lock --upgrade-package requests
```

### pyproject.toml

```toml
[project]
name = "python"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "requests==2.31.0",
]

```

## Tools

Running and installing tools published to Python package indexes, e.g., ruff or black.

- uvx / uv tool run: Run a tool in a temporary environment.
- uv tool install: Install a tool user-wide.
- uv tool uninstall: Uninstall a tool.
- uv tool list: List installed tools.
- uv tool update-shell: Update the shell to include tool executables.

## Utility

- uv cache clean: Remove cache entries.
- uv cache prune: Remove outdated cache entries.
- uv cache dir: Show the uv cache directory path.
- uv tool dir: Show the uv tool directory path.
- uv python dir: Show the uv installed Python versions path.
- uv self update: Update uv to the latest version.
