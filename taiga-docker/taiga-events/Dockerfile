# Базовый образ - node:12-alpine
FROM node:12-alpine
# Добавление метаданных для образа
LABEL maintainer="support@taiga.io"

# Копирование файлов и указание рабочей директории
COPY . /taiga-events
WORKDIR /taiga-events

# Выполение команд и установка зависмостей
RUN set -eux; \
    apk update; \
    apk add --no-cache \
       gettext \
       su-exec; \
    npm install; \
    chmod +x docker/entrypoint.sh; \
    addgroup -g 99 -S taiga; \
    adduser -u 99 -S -D -G taiga -H -h /taiga-events -s /bin/sh taiga; \
    chown -R taiga:taiga /taiga-events

# Открытие порта
EXPOSE 8888

# Указание точки входа
ENTRYPOINT ["./docker/entrypoint.sh"]