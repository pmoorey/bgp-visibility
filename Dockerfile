#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Update the VARIANT arg in devcontainer.json to pick a Python version: 3, 3.8, 3.7, 3.6 
# To fully customize the contents of this image, use the following Dockerfile instead:
# https://github.com/microsoft/vscode-dev-containers/tree/v0.112.0/containers/python-3/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-12

WORKDIR /app

COPY ./bgp-visibility/package.json /app/package.json
RUN npm install
RUN npm install -g @angular/cli

COPY ./bgp-visibility /app

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   && apt-get -y install --no-install-recommends python3-pip\
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp

EXPOSE 80
RUN npm run build --prod

FROM nginx:1.15.8-alpine
COPY --from=builder /usr/src/app/dist/bgp-visibility/ /usr/share/nginx/html
