FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# Use a dedicated user's home directory
ENV APP_USER=openclaw
ENV APP_UID=10001
ENV APP_GID=10001
ENV OPENCLAW_HOME=/home/openclaw/

RUN apt-get update && apt-get install -y --no-install-recommends \
   bash \
   ca-certificates \
   curl \
   git \
   tini \
   locales \
   tzdata \
   python3 \
   python3-pip \
   gettext-base \
   && sed -i 's/^# *ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
   && locale-gen \
   && update-locale LANG=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 \
   && rm -rf /var/lib/apt/lists/*

# Create a dedicated application user and group
RUN groupadd -g ${APP_GID} ${APP_USER} \
   && useradd -m -d /home/${APP_USER} -s /bin/bash -u ${APP_UID} -g ${APP_GID} ${APP_USER}

# Install OpenClaw
RUN npm install -g openclaw@2026.3.23-2

# Copy configuration template and entrypoint script
COPY openclaw.json.template ${OPENCLAW_HOME}/openclaw.json.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Create required directories and assign ownership to the application user
RUN chmod +x /usr/local/bin/entrypoint.sh \
   && mkdir -p ${OPENCLAW_HOME}/.openclaw \
   && chown -R ${APP_UID}:${APP_GID} /home/${APP_USER}

# Expose port for OpenClaw dashboard
EXPOSE 18789

# Run the container as the non-root user
USER ${APP_UID}:${APP_GID}
WORKDIR /home/openclaw

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]