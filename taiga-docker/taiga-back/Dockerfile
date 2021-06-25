# База - python:3.7-slim
FROM python:3.7-slim

# Добавление метаданных для образа
LABEL maintainer="support@taiga.io"

# Объявление переменных окружения
ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# Команда на использование virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Копирование файлов и указание рабочей директории
COPY . /taiga-back
WORKDIR /taiga-back

ENV GOSU_VERSION 1.12

# Выполение команд и установка зависмостей
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    # установка зависимостей
    apt-get install -y \
       build-essential \
       gettext \
       git \
       net-tools \
       procps \
       wget; \
    # установка gosu
    apt-get install -y --no-install-recommends ca-certificates wget; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    chmod +x /usr/local/bin/gosu; \
    # Проверка подписи gosu
    export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    # установка зависимостей Taiga
    python -m pip install --upgrade pip; \
    python -m pip install wheel; \
    python -m pip install -r requirements.txt; \
    python -m pip install -r requirements-contribs.txt; \
    python manage.py compilemessages; \
    python manage.py collectstatic --no-input; \
    chmod +x docker/entrypoint.sh; \
    chmod +x docker/async_entrypoint.sh; \
    cp docker/config.py settings/config.py; \
    # создание taiga группы и пользователя
    groupadd --system taiga --gid=999; \
    useradd --system --no-create-home --gid taiga --uid=999 --shell=/bin/bash taiga; \
    mkdir -p /taiga-back/media/exports; \
    chown -R taiga:taiga /taiga-back; \
    # удаление ненужных пакетов и файлов
    apt-get purge -y \
       build-essential \
       gettext \
       git; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /root/.cache; \
    # очистка gosu
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    # очистка taiga
    rm requirements.txt; \
    rm requirements-contribs.txt; \
    find . -name '__pycache__' -exec rm -r '{}' +; \
    find . -name '*pyc' -exec rm -r '{}' +; \
    find . -name '*po' -exec rm -r '{}' +

ENV DJANGO_SETTINGS_MODULE=settings.config

# Открытие порта
EXPOSE 8000

# Указание точки входа
ENTRYPOINT ["./docker/entrypoint.sh"]