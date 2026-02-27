# settings

早期版本的 pydantic 内置 settings 管理模块, 后来单独分离了一个`pydantic-settings`库

## 使用pydantic_settings 管理配置文件

1. 支持读取指定 toml 文件覆盖配置

<details>
<summary>Example</summary>

```python
import os
import tomllib
from pathlib import Path
from typing import Tuple, Type

from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
    TomlConfigSettingsSource,
)


class AppConfig(BaseSettings):
    model_config = SettingsConfigDict(
        toml_file=os.getenv("CONFIG_FILE", ".settings.toml"),
        extra="ignore",  # 忽略 TOML 文件中的额外字段
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: Type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> Tuple[PydanticBaseSettingsSource, ...]:
        """自定义配置源，优先级：初始化参数 > TOML 文件 > 环境变量"""
        return (
            init_settings,
            TomlConfigSettingsSource(settings_cls),
            env_settings,
        )

    @classmethod
    def from_toml(cls, toml_path: str | Path) -> "AppConfig":
        if isinstance(toml_path, str):
            toml_path = Path(toml_path).resolve()
        if not toml_path.exists() or not toml_path.is_file():
            raise FileNotFoundError(f"配置文件不存在或不是文件: {toml_path}")
        try:
            return cls.model_validate(tomllib.loads(toml_path.read_text(encoding="utf-8")))
        except tomllib.TOMLDecodeError as e:
            raise ValueError(f"配置文件解析失败: {e}")

    @classmethod
    def update_from_toml(cls, app_config: "AppConfig", toml_path: str | Path) -> None:
        """从 TOML 文件更新配置对象（直接修改传入的对象）"""
        new_config = cls.from_toml(toml_path)
        # 直接更新传入对象的所有字段，保持 Pydantic 模型类型
        for field_name in cls.model_fields.keys():
            setattr(app_config, field_name, getattr(new_config, field_name))

APP_CONFIG: AppConfig = AppConfig.model_validate({})

```

</details>
