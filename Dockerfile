FROM alpine:3.23

LABEL version=0.1.2

RUN apk add --update --no-cache \
        curl \
        bat \
        neovim \
        ripgrep \
        fd \
        lsd \
        sd && \
    rm -rf /var/lib/app/lists* && \
    rm -rf /var/cache/apk && \
    set -eux; \
    URL="https://github.com/ismaelgv/rnr/releases/download/v0.5.1/rnr-v0.5.1-x86_64-unknown-linux-musl.tar.gz"; \
    FILENAME=$(basename $URL); \
    TEMP_DIR="/tmp/rnr_extract"; \
    # 1. Descargar el archivo
    curl -L $URL -o /tmp/$FILENAME; \
    # 2. Crear un directorio temporal para la extracción
    mkdir -p $TEMP_DIR; \
    # 3. Descomprimir el contenido en el directorio temporal
    tar -xzf /tmp/$FILENAME -C $TEMP_DIR; \
    # 4. Mover SOLO el binario 'rnr' (que está anidado) a /usr/bin/
    #    Ajusta 'rnr-v0.5.1-x86_64-unknown-linux-musl' si el nombre del directorio extraído es diferente.
    mv $TEMP_DIR/rnr-v0.5.1-x86_64-unknown-linux-musl/rnr /usr/bin/rnr; \
    # 5. Asegurar permisos de ejecución
    chmod +x /usr/bin/rnr; \
    # 6. Limpieza: Eliminar el archivo descargado, el directorio temporal y las herramientas de instalación
    rm /tmp/$FILENAME; \
    rm -rf $TEMP_DIR;
