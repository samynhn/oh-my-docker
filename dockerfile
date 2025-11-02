# Modified version by Mian-Heng Shan (@samynhn), 2024

# Copyright (c) 2024 Mian-Heng Shan (@samynhn)
# Copyright (c) 2023 ACAL, National Cheng Kung University
# Copyright (c) 2022 Playlab, National Cheng Kung University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel

ARG UID=1000
ARG GID=1000
ARG USERNAME="user"
ARG PROJNAME="proj"
ARG TZ="Asia/Taipei"
ARG ARCH



ENV INSTALLATION_TOOLS apt-utils \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common

ENV TOOL_PACKAGES bash \
    dos2unix \
    git \
    locales \
    nano \
    tree \
    vim \
    sudo \
    gdb \
    zip \
    unzip \
    htop \
    nvtop \
    btop \
    tmux 

ENV NODEJS_SETUP_URL https://deb.nodesource.com/setup_20.x
ENV DEVELOPMENT_PACKAGES libgl1-mesa-glx nodejs

ENV USER ${USERNAME}
ENV TERM xterm-256color
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn

# install system packages
RUN apt-get -qq update && \
    apt-get -qq install ${INSTALLATION_TOOLS} && \
    apt-get -qq install ${TOOL_PACKAGES} && \
    curl -fsSL ${NODEJS_SETUP_URL} | bash - && \
    apt-get -qq install ${DEVELOPMENT_PACKAGES} && \
    apt-get -qq update && \
    apt-get -qq upgrade 



# install dependencies from requirements directory 
COPY ./requirements /tmp/requirements
COPY ./install.sh /tmp/install.sh

RUN chmod +x /tmp/install.sh && \
    cd /tmp && ./install.sh && \
    rm -rf /tmp/requirements /tmp/install.sh



# setup time zone
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# add support of locale zh_TW
RUN sed -i 's/# en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen && \
    sed -i 's/# zh_TW.UTF-8/zh_TW.UTF-8/g' /etc/locale.gen && \
    sed -i 's/# zh_TW BIG5/zh_TW BIG5/g' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# add non-root user account
RUN groupadd -o -g ${GID} ${USERNAME} && \
    useradd -u ${UID} -m -s /bin/bash -g ${GID} ${USERNAME} && \
    echo "${USERNAME} ALL = NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    passwd -d ${USERNAME}

# add scripts and setup permissions
COPY --chown=${UID}:${GID} ./scripts/.bashrc /home/${USERNAME}/.bashrc
COPY --chown=${UID}:${GID} ./scripts/start.sh /docker/start.sh
COPY --chown=${UID}:${GID} ./scripts/login.sh /docker/login.sh
COPY --chown=${UID}:${GID} ./scripts/startup.sh /usr/local/bin/startup
RUN dos2unix -ic "/home/${USERNAME}/.bashrc" | xargs dos2unix && \
    dos2unix -ic "/docker/start.sh" | xargs dos2unix && \
    dos2unix -ic "/docker/login.sh" | xargs dos2unix && \
    dos2unix -ic "/usr/local/bin/startup" | xargs dos2unix && \
    chmod +x "/usr/local/bin/startup"

# user account configuration
RUN mkdir -p /home/${USERNAME}/.ssh && \
    mkdir -p /home/${USERNAME}/.vscode-server && \
    mkdir -p /home/${USERNAME}/${PROJNAME} 
RUN chown -R ${UID}:${GID} /home/${USERNAME}

USER ${USERNAME}

WORKDIR /home/${USERNAME}/${PROJNAME}

CMD [ "/bin/bash", "-c", "bash -x /docker/start.sh > /docker/start.log 2>&1" ]
