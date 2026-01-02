function jelly-convert --description 'Convierte videos a 720p H.264 para Jellyfin'
    # Si le pasas un argumento, usa esa ruta. Si no, usa la carpeta actual.
    set TARGET_DIR $argv[1]
    if test -z "$TARGET_DIR"
        set TARGET_DIR (pwd)
    end

    set EXTENSIONS mkv mp4 avi mov

    echo "🔍 Buscando videos en: $TARGET_DIR"

    for file in (fd . "$TARGET_DIR" -t f)
        set ext (string split -r -m1 . $file)[2]
        set base (string split -r -m1 . $file)[1]

        if contains $ext $EXTENSIONS
            # Evitar procesar archivos que ya son temporales
            if string match -q "*_tmp*" $file
                continue
            end

            echo "🍿 Procesando: $file"
            set temp_file "$base"_tmp.mp4
            
            ffmpeg -i "$file" \
              -vf "scale=-1:720" \
              -c:v libx264 -crf 20 -preset fast \
              -c:a aac -b:a 128k \
              -movflags +faststart \
              -y $temp_file

            if test $status -eq 0
                echo "✅ Éxito. Reemplazando original..."
                rm "$file"
                mv $temp_file "$base.mp4"
            else
                set_color red
                echo "❌ Error en $file. Manteniendo original."
                set_color normal
                rm -f $temp_file
            end
        end
    end
    echo "🏁 ¡Proceso completado!"
end
