## Usage

```python
from tortoise.models import Model
from tortoise import fields

class Tournament(Model):
    id = fields.IntField(primary_key=True)
    name = fields.TextField()

await Tournament.create(name='Another Tournament')
tour = await Tournament.filter(name__contains='Another').first()
print(tour.name)

await Tournament.annotate(
    name_prefix=Case(
        When(name__startswith="One", then="1"),
        When(name__startswith="Two", then="2"),
        default="0",
    ),
).annotate(
    count=Count(F("name_prefix")),
).group_by(
    "name_prefix"
).values("name_prefix", "count")

from tortoise import Tortoise, run_async

async def main():
    # Here we connect to a SQLite DB file.
    # also specify the app name of "models"
    # which contain models from "app.models
    await Tortoise.init(
        db_url='sqlite://db.sqlite3',
        modules={'models': ['app.models']}
    )
    await Tortoise.generate_schemas()

run_async(main())
```

### CustomlBaseModel

```python
class UUIDDBModel:
    hashed_id = fields.UUIDField(unique=True, pk=False, default=uuid.uuid4)


class BaseCreatedAtModel:
    created_at = fields.DatetimeField(auto_now_add=True)


class BaseCreatedUpdatedAtModel:
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)


class SoftDeleteModel:
    deleted_at = fields.DatetimeField(null=True)

    @classmethod
    def get_query(cls, *args, **kwargs):
        return super().get_query(*args, **kwargs).filter(deleted_at__isnull=True)

    async def delete(self, *args, **kwargs):
        self.deleted_at = datetime.datetime.now()
        return await self.save(*args, **kwargs)

class BaseModel(UUIDDBModel,BaseCreatedAtModel,BaseCreatedUpdatedAtModel,SoftDeleteModel):
    id = fields.IntField(pk=True)
```

## aerich

```bash
aerich init -t settings.TORTOISE_ORM
aerich init-db
aerich migrate
aerich upgrade
aerich downgrade
aerich history
```
