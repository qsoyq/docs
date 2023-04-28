[sqlalchemy-2.0](https://docs.sqlalchemy.org/en/20/)

[quickstart](https://docs.sqlalchemy.org/en/14/orm/quickstart.html)

[migration to 2.0](https://docs.sqlalchemy.org/en/14/changelog/migration_20.html)

```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
# SQLALCHEMY_DATABASE_URL = "postgresql://user:password@postgresserver/db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}, echo=True, future=True
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

Base.metadata.create_all(engine) # 在关联到所有的 Model 之后
```

## crud 2.0 style

query

```python
from sqlalchemy import select
from sqlalchemy.orm import Session

session = Session(engine, future=True)

session.execute(
  select(User)
).scalars().all()

session.execute(
  select(User).
  filter_by(name="some user")
).scalar_one()
```

update

```python
from sqlalchemy import update

stmt = (
    update(User)
    .where(User.name == "squidward")
    .values(name="spongebob")
    .execution_options(synchronize_session="fetch")
)

result = session.execute(stmt)
```

delete

```python
from sqlalchemy import delete

stmt = (
    delete(User)
    .where(User.name == "squidward")
    .execution_options(synchronize_session="fetch")
)

session.execute(stmt)
```
