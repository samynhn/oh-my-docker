#!/bin/bash

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

# change owner and permission of volume folders
sudo chown -R "$(id -u)":"$(id -g)" "/home/$(id -un)/.ssh"
chmod 755 "/home/$(id -un)/.ssh" && chmod 644 "/home/$(id -un)/.ssh"/*
[[ -f "/home/$(id -un)/.ssh/id_rsa" ]] && chmod 600 "/home/$(id -un)/.ssh/id_rsa"
sudo chown "$(id -u)":"$(id -g)" "/home/$(id -un)/.vscode-server" && chmod 755 "/home/$(id -un)/.vscode-server"
sudo chown "$(id -u)":"$(id -g)" "/home/$(id -un)/projects" && chmod 755 "/home/$(id -un)/projects"

[ ! -e "/home/$(id -un)/CFU-Playground/proj/proj.mk" ] && cp /tmp/proj.mk /home/$(id -un)/CFU-Playground/proj/

# keep the container running
tail -f /dev/null
