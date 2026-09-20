FROM --platform=amd64 ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

# Enable i386 architecture required by SteamCMD
RUN dpkg --add-architecture i386

# Install SteamCMD runtime dependencies and gosu for PUID/PGID switching
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gosu \
        lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install SteamCMD
RUN mkdir -p /steamcmd \
    && curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
       | tar -xz -C /steamcmd

ENV PATH="/steamcmd:$PATH"

# Default PUID/PGID — override in derived images or at runtime
ENV PUID=1000
ENV PGID=1000

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
