# Mysql Foreign Key Constraints

[create-table-foreign-keys](https://dev.mysql.com/doc/refman/8.0/en/create-table-foreign-keys.html)

## ON_DELETE

按照外键`ON_DELETE CASCADE`的规则, 当删除`id=1`的 `tag` 表内的记录时, 与之关联的`record`表内的`tag_id=1`的数据也会被同步删除

```sql
DROP TABLE IF EXISTS `record`;
DROP TABLE IF EXISTS `tag`;
CREATE TABLE IF not EXISTS `tag`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,

  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE IF not EXISTS `record`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `tag_id` int not NULL,

  PRIMARY KEY (id),

  FOREIGN KEY (tag_id)
    REFERENCES tag(id)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO tag (name) VALUES ("A"), ("B");

INSERT INTO record (name, tag_id) values ("a.1", 1), ("a.2", 1), ("b.1", 2), ("b.2", 2);

select name from record where tag_id=1;
select name from record where tag_id=2;

delete from tag where id = 1;

select name from record where tag_id=1;
select name from record where tag_id=2;
```
