function jelly-move --description 'Mueve vídeos de un origen obligatorio al directorio actual'
    set -l SOURCE_DIR $argv[1]

    # 1. Validar que se ha pasado un origen
    if test -z "$SOURCE_DIR"
        set_color red
        echo "❌ Error: El directorio de origen es obligatorio."
        set_color normal
        echo "Uso: move-videos-here /ruta/al/origen"
        return 1
    end

    # 2. Obtener rutas absolutas para comparar
    set -l ABS_SOURCE (realpath "$SOURCE_DIR" 2>/dev/null)
    set -l ABS_DEST (pwd)

    # 3. Validar existencia del origen
    if not test -d "$ABS_SOURCE"
        set_color red
        echo "❌ Error: El directorio de origen '$SOURCE_DIR' no existe."
        set_color normal
        return 1
    end

    # 4. Restricción: Origen y destino no pueden coincidir
    if test "$ABS_SOURCE" = "$ABS_DEST"
        set_color yellow
        echo "⚠️  Operación cancelada: El origen no puede ser el mismo que el destino ($ABS_DEST)."
        set_color normal
        return 1
    end

    set -l EXTENSIONS mkv mp4 avi mov webm flv
    echo "📦 Trayendo vídeos desde $ABS_SOURCE hacia el directorio actual..."

    # 5. Buscar archivos de forma recursiva en el origen
    set -l files (fd -t f -e mkv -e mp4 -e avi -e mov -e webm -e flv . "$ABS_SOURCE")

    if test -z "$files"
        echo "No se encontraron vídeos en el origen."
        return 0
    end

    set -l count 0
    for file in $files
        set -l filename (basename "$file")
        set -l target "$ABS_DEST/$filename"

        # Verificar si el archivo ya existe en el destino
        if test -f "$target"
            set_color yellow
            echo "⚠️  Omitido: '$filename' ya existe en el directorio actual."
            set_color normal
        else
            mv "$file" "$target"
            set count (math $count + 1)
            echo "✅ Movido: $filename"
        end
    end

    echo "🏁 ¡Finalizado! Se han movido $count archivos a $ABS_DEST."
end
