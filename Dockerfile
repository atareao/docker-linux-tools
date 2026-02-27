FROM alpine:3.23

LABEL version=0.1.12

RUN apk add --update --no-cache \
        curl \
        bat \
        neovim \
        ripgrep \
        fd \
        lsd \
        yazi \
        7zip \
        fish \
        starship \
        ffmpeg \
        jq \
        sd && \
    rm -rf /var/cache/apk
ENV RNR_VERSION=0.5.1 \
    RSNAME_VERSION=0.1.9
RUN set -eux; \
    URL="https://github.com/ismaelgv/rnr/releases/download/v${RNR_VERSION}/rnr-v${RNR_VERSION}-x86_64-unknown-linux-musl.tar.gz"; \
    FILENAME=$(basename $URL); \
    TEMP_DIR="/tmp/rnr_extract"; \
    curl -L $URL -o /tmp/$FILENAME && \
    mkdir -p $TEMP_DIR && \
    tar -xzf /tmp/$FILENAME -C $TEMP_DIR && \
    mv $TEMP_DIR/rnr-v0.5.1-x86_64-unknown-linux-musl/rnr /usr/bin/rnr && \
    chmod +x /usr/bin/rnr && \
    rm /tmp/$FILENAME && \
    rm -rf $TEMP_DIR && \
    curl -L "https://github.com/atareao/rsname/releases/download/v${RSNAME_VERSION}/rsname-linux-x86_64" -o /usr/bin/rsname && \
    chmod +x /usr/bin/rsname && \
    mkdir -p /root/.config/fish/functions && \
    mkdir -p /root/.config/fish && \
    echo 'starship init fish | source' > /root/.config/fish/config.fish && \
    echo "alias ls='lsd'" >> /root/.config/fish/config.fish && \
    echo "alias cat='bat -p'" >> /root/.config/fish/config.fish && \
    echo "alias find='fd'" >> /root/.config/fish/config.fish
COPY ./functions /root/.config/fish/functions/
ENV SHELL=/usr/bin/fish
