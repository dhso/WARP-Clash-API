FROM python:3.11-alpine

WORKDIR /app

# Install dependencies for building some Python packages
# Check if in Github Actions, if not, change Alpine source and PyPI source to Aliyun
ARG GITHUB_ACTIONS
RUN if [ "$GITHUB_ACTIONS" != "true" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
        pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/; \
    fi
RUN apk add --no-cache bash build-base libffi-dev openssl-dev gcompat gzip

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY . .
RUN chmod +x ./scripts/*.sh

RUN wget https://github.com/MetaCubeX/mihomo/releases/download/v1.18.5/mihomo-linux-amd64-compatible-v1.18.5.gz  -O mihomo.gz \
    && gzip -d mihomo.gz \
    && chmod +x mihomo \
    && mv mihomo /usr/local/bin/

RUN mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && chmod 600 /dev/net/tun

COPY ./mihomo.config.yaml /etc/mihomo/config.yaml

# Set environment variables
ENV RUN_IN_DOCKER=true

CMD ["/bin/sh", "./scripts/run.sh"]
