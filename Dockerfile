FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update && apt-get install -y \
    net-tools apt-utils gawk wget git-core diffstat unzip \
    texinfo gcc-multilib build-essential chrpath socat cpio python3 \
    python3-pip python3-pexpect xz-utils debianutils iputils-ping file \
    python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm locales \
    vim bash-completion screen curl subversion tzdata zstd liblz4-tool \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME
ARG PUID
ARG PGID
ENV HOME /home/${USERNAME}

RUN groupadd -g ${PGID} ${USERNAME} \
    && useradd -u ${PUID} -g ${USERNAME} -d ${HOME} ${USERNAME} \
    && mkdir ${HOME} \
    && chown -R ${USERNAME}:${USERNAME} ${HOME}

RUN mkdir -m 777 ${HOME}/Volume

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

USER ${USERNAME}
WORKDIR ${HOME}/Volume

ENTRYPOINT ["./entrypoint.sh"]
