FROM gitpod/openvscode-server:latest

## Root user to get permissions to install packages
USER root 

## Install Python3, pip3, and other dependencies
RUN apt-get update && \
    apt-get install -y \
        ## Python3
        python3 \
        python3-pip \
        ## Other dependencies
        sudo \
        curl \
        git \
        wget \
        unzip && \ 
        apt-get clean
        
## Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
        sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
        sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && \
        sudo apt install ngrok

## Install VScode extensions
# ENV OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
# ENV OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"
# SHELL ["/bin/bash", "-c"]
# RUN \
#     urls=(\
#         https://open-vsx.org/api/ms-python/python/2024.10.0/file/ms-python.python-2024.10.0.vsix \
#     )\
#     ## Create a tmp dir for downloading
#     && tdir=/tmp/exts && mkdir -p "${tdir}" && cd "${tdir}" \
#     ## Download via wget from $urls array.
#     && wget "${urls[@]}" && \
#     ## List the extensions in this array
#     exts=(\
#         ## From https://open-vsx.org/ registry directly
#         gitpod.gitpod-theme \
#         ## From filesystem, .vsix that we downloaded (using bash wildcard '*')
#         "${tdir}"/* \
#     )\
#     ## Install the $exts
#     && for ext in "${exts[@]}"; do ${OPENVSCODE} --install-extension "${ext}"; done


## Configure ngrok environment variables
ENV NGROK_AUTHTOKEN 1bZ0mdX1e5w0mfe8igGmHlMyriD_4azXY84YHzSt5fJbjZ5bm
ENV NGROK_DOMAIN close-endlessly-grubworm.ngrok-free.app
ENV NGROK_PORT 3000
RUN ngrok config add-authtoken $NGROK_AUTHTOKEN

## Restore permissions for the web interface
USER openvscode-server

## Change the entrypoint to start ngrok and openvscode-server
ENTRYPOINT [ "/bin/sh", "-c", "ngrok http --log=stdout --domain=${NGROK_DOMAIN} ${NGROK_PORT} > /dev/null & exec ${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server --host 0.0.0.0 --without-connection-token \"${@}\"", "--" ]