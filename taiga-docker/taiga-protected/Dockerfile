# Ьазовый образ - python:3.7-slim
FROM python:3.7-slim
# Добавление метаданных для образа
LABEL maintainer="support@taiga.io"

# Объявление переменных окружений
ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# Команда на использование virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Копирование файлов и указание рабочей директории
COPY . /taiga-protected
WORKDIR /taiga-protected

ENV GOSU_VERSION 1.12

# Выполнение команд
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    # уставновка системных зависимостей
    apt-get install -y \
       build-essential \
       git; \
    # уставновка gosu
    apt-get install -y --no-install-recommends ca-certificates wget; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    chmod +x /usr/local/bin/gosu; \
    # проверка подписи gosu
    export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    # уставновка Taiga protected зависимостей
    python -m pip install --upgrade pip; \
    python -m pip install wheel; \
    python -m pip install -r requirements.txt; \
    chmod +x docker/entrypoint.sh; \
    #  создание taiga группы и пользователя
    groupadd --system taiga --gid=999; \
    useradd --system --no-create-home --gid taiga --uid=999 --shell=/bin/bash taiga; \
    chown -R taiga:taiga /taiga-protected; \
    # удаление ненужных файлов и директорий
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
    # очистка taiga protected
    rm requirements.txt; \
    find . -name '__pycache__' -exec rm -r '{}' +; \
    find . -name '*pyc' -exec rm -r '{}' +

# Открытие порта
EXPOSE 8003

# Указание точки входа
ENTRYPOINT ["./docker/entrypoint.sh"]