#!/usr/bin/fish

set IMAGE_USER $argv[1]
set IMAGE_NAME $argv[2]
set IMAGE_VERSION $argv[3]

echo "🚀 Iniciando construcción de $IMAGE_USER/$IMAGE_NAME version $IMAGE_VERSION"

set RNR_VERSION 0.5.1
set RSHAPE_VERSION 0.1.10
set DUST_VERSION 1.2.4

# 1. Crear el contenedor y montar
set container (buildah from alpine:3.23)
set mountpoint (buildah mount $container)

# 2. Configurar etiquetas y variables de entorno
buildah config --label version=$IMAGE_VERSION $container
buildah config --env SHELL=/usr/bin/fish  $container

# 3. Instalar paquetes (RUN apk add...)
# Usamos -- para separar los comandos de buildah de los del contenedor
buildah run $container -- apk add --update --no-cache \
    curl bat neovim ripgrep fd lsd yazi 7zip fish starship ffmpeg jq sd

# 4. Lógica compleja (Descargas y configuración)

# Descargar y extraer RNR directamente al mountpoint
set RNR_URL "https://github.com/ismaelgv/rnr/releases/download/v$RNR_VERSION/rnr-v$RNR_VERSION-x86_64-unknown-linux-musl.tar.gz"

curl -L $RNR_URL | tar -xzC $mountpoint/tmp/
mv $mountpoint/tmp/rnr-v$RNR_VERSION-x86_64-unknown-linux-musl/rnr $mountpoint/usr/bin/rnr
chmod +x $mountpoint/usr/bin/rnr

# Descargar y extraer DUST directamente al mountpoint
set DUST_URL "https://github.com/bootandy/dust/releases/download/v$DUST_VERSION/dust-v$DUST_VERSION-x86_64-unknown-linux-musl.tar.gz" 

curl -L $DUST_URL | tar -xzC $mountpoint/tmp/
mv $mountpoint/tmp/dust-v$DUST_VERSION-x86_64-unknown-linux-musl/dust $mountpoint/usr/bin/dust
chmod +x $mountpoint/usr/bin/dust

# Descargar rsname
curl -L "https://github.com/atareao/rsname/releases/download/v$RSNAME_VERSION/rsname-linux-x86_64" \
     -o $mountpoint/usr/bin/rsname
chmod +x $mountpoint/usr/bin/rsname


# 5. Configurar Fish y Starship
mkdir -p $mountpoint/root/.config/fish/functions
echo 'starship init fish | source' > $mountpoint/root/.config/fish/config.fish
echo "alias ls='lsd'" >> $mountpoint/root/.config/fish/config.fish
echo "alias cat='bat -p'" >> $mountpoint/root/.config/fish/config.fish
echo "alias find='fd'" >> $mountpoint/root/.config/fish/config.fish

# 6. Copiar archivos locales (Equivalente a COPY)
# Al estar montado, un 'cp' estándar de Arch es suficiente
cp -r ./functions/* $mountpoint/root/.config/fish/functions/

# 7. Finalizar: Punto de entrada y guardado
echo "Finalizar: Punto de entrada y guardado"
buildah config --entrypoint /usr/bin/fish $container
echo "💾 Guardando imagen..."
buildah commit --squash $container "$IMAGE_USER/$IMAGE_NAME"
echo "🧹 Clean"
buildah unmount $container
buildah rm $container
