ARG JAVA_VERSION=11
FROM docker-base.mobilcom.de/azuljdk-${JAVA_VERSION}:latest
MAINTAINER MCBS Entwicklung <it.abba.abr.entw@md.de>
LABEL author="it.abba.abr.entw@md.de"

ARG JASYPT_ENCRYPTOR_PASSWORD
ARG SERVICE_NAME
ARG SERVICE_JAR
ARG SERVICE_LANGUAGE
ARG COPY_TO_HOME_DIR=home
ARG COPY_TO_HOME_DIR_2=home

ENV SERVICE_NAME=${SERVICE_NAME}
ENV JASYPT_ENCRYPTOR_PASSWORD=${JASYPT_ENCRYPTOR_PASSWORD}

# Overwrite and set ISO-8859-1 encodings
ENV LANG=${SERVICE_LANGUAGE}
ENV LC_ALL=${SERVICE_LANGUAGE}

RUN apt-get -qq update && \
    apt-get -qq -y upgrade && \
    apt-get install -y --no-install-recommends \
      gnupg2 \
      locales \
      bzip2 \
      unzip \
      xz-utils \
      dirmngr \
      wget \
      apt-transport-https \
      dos2unix \
      ca-certificates && \
      locale-gen de_DE.UTF-8 && \
      update-ca-certificates -f

# Configure timezone and locale
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo "LC_ALL=de_DE.UTF-8" >> /etc/environment && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_US.ISO-8859-1 ISO-8859-1' >> /etc/locale.gen && \
    echo 'de_DE.ISO-8859-1 ISO-8859-1' >> /etc/locale.gen && \
    echo 'LANG="de_DE.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=de_DE.UTF-8

# Configure timezone and locale
# uid=37219(zxrestapi) gid=11000(Domänen-Benutzer)
RUN groupadd -g 11000 Domaenen-Benutzer
RUN useradd -u 37219 -m -s /bin/bash zxrestapi -g 11000

# all commands below USER are executed as zxrestapi, no root in following containers
USER zxrestapi

COPY --chown=zxrestapi:11000 "${COPY_TO_HOME_DIR}"   /home/zxrestapi/
COPY --chown=zxrestapi:11000 "${COPY_TO_HOME_DIR_2}" /home/zxrestapi/
COPY --chown=zxrestapi:11000 "${SERVICE_JAR}" "/home/zxrestapi/${SERVICE_NAME}.jar"

RUN chmod 755 /home/zxrestapi/*.sh && \
    dos2unix /home/zxrestapi/run.sh && \
    mkdir /home/zxrestapi/logs && \
    chmod 775 /home/zxrestapi/logs

WORKDIR /home/zxrestapi

EXPOSE 8080

CMD [ "./run.sh" ]
