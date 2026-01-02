function jelly-move --description 'Mueve todos los archivos de vídeo a un directorio especificado para Jellyfin'
    # Si le pasas un argumento, usa esa ruta. Si no, usa la carpeta actual.
    set TARGET_DIR $argv[1]
    if test -z "$TARGET_DIR"
        set TARGET_DIR (pwd)
    end

    set EXTENSIONS mkv mp4 avi mov

    # Crear el directorio si no existe
    mkdir -p $TARGET_DIR

    echo "Buscando archivos de vídeo y moviendo a: $TARGET_DIR"

    # Utilizamos fd para buscar extensiones de video comunes
    # -e: extensiones
    # -t f: solo archivos
    # -x: ejecutar comando
    fd -t f -e mp4 -e mkv -e avi -e mov \
       -x mv -v {} $TARGET_DIR

    if test $status -eq 0
        echo "¡Hecho! Todos los vídeos se han movido correctamente."
    else
        echo "Hubo un error durante el movimiento."
    end
end
