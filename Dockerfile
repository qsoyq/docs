FROM squidfunk/mkdocs-material

ENV TZ=Asia/Shanghai

COPY docs /docs/docs

COPY mkdocs.yml /docs/mkdocs.yml
