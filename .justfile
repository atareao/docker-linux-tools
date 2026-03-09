set shell := ["fish", "-c"]

user    := "atareao"
name    := `basename $PWD`
version := `vampus show`
runtime := "crun"

# Sube la versión (patch) usando vampus
upgrade:
    vampus upgrade --patch

build:
    @echo "Construyendo con Buildah BUD..."
    buildah bud \
        --layers \
        -t {{user}}/{{name}}:latest \
        -t {{user}}/{{name}}:{{version}} \
        .

# Construcción imperativa con Buildah
build-pro:
    @echo "Construyendo {{name}}:{{version}}..."
    BUILDAH_RUNTIME={{runtime}} buildah unshare fish docker-linux-tools.fish "{{user}}" "{{name}}" "{{version}}"
    # Etiquetamos el resultado final para que push lo encuentre
    # El script debe haber hecho un 'buildah commit ... {{name}}'
    buildah tag {{user}}/{{name}}:latest {{user}}/{{name}}:{{version}}
    buildah tag {{user}}/{{name}}:latest {{user}}/{{name}}:latest

# Subida directa a Docker Hub (o el registry configurado)
push:
    @echo "Subiendo {{user}}/{{name}}..."
    buildah push --format oci {{user}}/{{name}}:{{version}}
    buildah push --format oci {{user}}/{{name}}:latest

# Elimina contenedores de trabajo y la imagen local
clean:
    buildah rm --all
    buildah rmi {{user}}/{{name}}:latest
    buildah rmi {{user}}/{{name}}:{{version}}

# Mantiene solo 'latest' y las 3 versiones más recientes localmente
prune:
    @echo "Limpiando imágenes antiguas, conservando solo las 3 últimas..."
    buildah rmi $(buildah images --filter "reference={{user}}/{{name}}" --format "{{"{{.Name}}:{{.Tag}}"}}" | \
        grep -v ":latest" | \
        sort -V | \
        head -n -3)
