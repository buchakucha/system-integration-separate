# Указание базового образа - nginx:1.19-alpine
FROM nginx:1.19-alpine
# Добавление метаданных для образа
LABEL maintainer="support@taiga.io"

# Копирование файлов и директорий
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/conf.json.template /
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

# Выполнение команд
RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
       subversion; \
    apk add \
       bash; \
    # установка ядра taiga-front
    wget https://github.com/kaleidos-ventures/taiga-front-dist/archive/6.2.1.zip -O source.zip; \
    unzip source.zip; \
    mv /taiga-front-dist-6.2.1 /taiga; \
    mv /conf.json.template taiga/dist/; \
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # установка taiga-front contribs
    mkdir /taiga/dist/plugins; \
    cd /taiga/dist/plugins; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-slack/tags/6.2.1/front/dist" "slack"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-github-auth/tags/6.2.1/front/dist" "github-auth"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-gitlab-auth/tags/6.2.1/front/dist" "gitlab-auth"; \
    cd /; \
    # удаление неиспользуемых зависимостей
    apk del --no-cache .build-deps; \
    rm source.zip; \
    # подготовка для nginx
    mv /taiga/dist/* /usr/share/nginx/html; \
    rm -rf /taiga