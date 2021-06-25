# Основан на openjdk:8-jdk-alpine
FROM openjdk:8-jdk-alpine

# Установка различных зависимостей
RUN apk add --no-cache \
  bash \
  coreutils \
  curl \
  git \
  git-lfs \
  openssh-client \
  tini \
  ttf-dejavu \
  tzdata \
  unzip

# Объявление аргументов и переменных окружения
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref


ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# Создание корневого каталога , добавление группы и пользователя, 
# а также изменение владельца корневого каталога
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && addgroup -g ${gid} ${group} \
  && adduser -h "$JENKINS_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}

# Установка домашней директории Jenkins в качестве хранилища
VOLUME $JENKINS_HOME

# Команда по созданию директории, которая будет содержать
# всю справочную конфигурацию, которую необходимо установить
RUN mkdir -p ${REF}/init.groovy.d

# Объявление аргументов и переменных окружения
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.235}

ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# Выполнение команд
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war"


ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# Открытие портов для главного веб-интерфейса и для подключенных подчиненных агентов
EXPOSE ${http_port}

EXPOSE ${agent_port}

# Переменная окружения
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# Установка текущего пользователя
USER ${user}

# Копирование файлов/директорий и указание точки входа
COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY tini-shim.sh /bin/tini
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

# Установка хранилища
VOLUME /var/jenkins_home