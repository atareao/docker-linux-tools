FROM alpine:3.23

LABEL version=0.1.9

RUN apk add --update --no-cache \
        curl \
        bat \
        neovim \
        ripgrep \
        fd \
        lsd \
        yazi \
        fish \
        starship \
        ffmpeg \
        sd && \
    rm -rf /var/cache/apk && \
    set -eux; \
    URL="https://github.com/ismaelgv/rnr/releases/download/v0.5.1/rnr-v0.5.1-x86_64-unknown-linux-musl.tar.gz"; \
    FILENAME=$(basename $URL); \
    TEMP_DIR="/tmp/rnr_extract"; \
    curl -L $URL -o /tmp/$FILENAME && \
    mkdir -p $TEMP_DIR && \
    tar -xzf /tmp/$FILENAME -C $TEMP_DIR && \
    mv $TEMP_DIR/rnr-v0.5.1-x86_64-unknown-linux-musl/rnr /usr/bin/rnr && \
    chmod +x /usr/bin/rnr && \
    rm /tmp/$FILENAME && \
    rm -rf $TEMP_DIR && \
    mkdir -p /root/.config/fish/functions && \
    mkdir -p /root/.config/fish && \
    echo 'starship init fish | source' > /root/.config/fish/config.fish && \
    echo "alias ls='lsd'" >> /root/.config/fish/config.fish && \
    echo "alias cat='bat -p'" >> /root/.config/fish/config.fish && \
    echo "alias find='fd'" >> /root/.config/fish/config.fish
COPY ./functions /root/.config/fish/functions/
ENV SHELL=/usr/bin/fish
