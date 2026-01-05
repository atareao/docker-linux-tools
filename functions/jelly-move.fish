function jelly-move --description 'Mueve vídeos de carpetas con patrón y borra el origen'
    set -l SOURCE_ROOT $argv[1]
    set -l PATTERN $argv[2]

    # 1. Validaciones
    if test (count $argv) -lt 2
        set_color red; echo "❌ Error: Faltan argumentos."; set_color normal
        echo "Uso: move-and-clean-pattern <ruta_descargas> <patrón>"
        return 1
    end

    set -l ABS_SOURCE (realpath "$SOURCE_ROOT" 2>/dev/null)
    set -l ABS_DEST (pwd)

    if not test -d "$ABS_SOURCE"
        echo "❌ El origen no existe."
        return 1
    end

    set -l EXTENSIONS mkv mp4 avi mov

    # 2. Obtener los directorios que coinciden con el patrón
    set -l target_dirs (fd -t d -g "$PATTERN" "$ABS_SOURCE")

    if test -z "$target_dirs"
        echo "No se encontraron directorios para: $PATTERN"
        return 0
    end

    for dir in $target_dirs
        echo "📂 Procesando carpeta: "(basename "$dir")
        
        # Buscamos los vídeos dentro de esta carpeta específica
        set -l files (fd -t f -e mkv -e mp4 -e avi -e mov . "$dir")
        set -l success_move false

        if test -z "$files"
            echo "   ⚠️  No hay vídeos en esta carpeta. ¿Borrar de todos modos? (Omitiendo)"
            continue
        end

        for file in $files
            set -l filename (basename "$file")
            set -l target "$ABS_DEST/$filename"

            if test -f "$target"
                echo "   ⚠️  Conflicto: $filename ya existe en destino. No se borra el origen."
                set success_move false
                break
            else
                if mv "$file" "$target"
                    echo "   ✅ Movido: $filename"
                    set success_move true
                else
                    echo "   ❌ Error al mover $filename"
                    set success_move false
                    break
                end
            end
        end

        # 3. Borrar el directorio de origen solo si todo ha ido bien
        if test "$success_move" = "true"
            rm -rf "$dir"
            echo "   🗑️  Directorio original eliminado."
        end
        echo "---"
    end

    echo "🏁 ¡Proceso de limpieza completado!"
end
