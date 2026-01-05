function jelly-convert --description 'Convierte videos a 720p H.264 usando JSON y jq'
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
            if string match -q "*_tmp*" $file; continue; end

            # 1. Obtener metadatos en formato JSON
            set -l json_data (ffprobe -v quiet -print_format json -show_streams "$file")
            
            # 2. Extraer información con jq
            set -l v_codec (echo $json_data | jq -r '.streams[] | select(.codec_type=="video") | .codec_name' | head -n 1)
            set -l v_height (echo $json_data | jq -r '.streams[] | select(.codec_type=="video") | .height' | head -n 1)
            set -l a_codec (echo $json_data | jq -r '.streams[] | select(.codec_type=="audio") | .codec_name' | head -n 1)

            # Validar v_height (evita errores si es nulo)
            if test "$v_height" = "null" -o -z "$v_height"
                set v_height 0
            end

            set -l needs_conv false
            set -l v_arg "copy"
            set -l a_arg "copy"
            set -l ffmpeg_params # Lista para acumular parámetros

            # 3. Lógica de Video
            if test "$v_codec" != "h264" -o "$v_height" -gt 720
                set v_arg "libx264"
                set needs_conv true
                if test "$v_height" -gt 720
                    set -a ffmpeg_params -vf "scale=-1:720"
                end
                set -a ffmpeg_params -c:v libx264 -crf 20 -preset fast
            else
                set -a ffmpeg_params -c:v copy
            end

            # 4. Lógica de Audio
            if test "$a_codec" != "aac"
                set -a ffmpeg_params -c:a aac -b:a 128k
                set needs_conv true
            else
                set -a ffmpeg_params -c:a copy
            end

            # 5. Procesamiento
            if test "$needs_conv" = "true"
                echo "🍿 Procesando: $file (V: $v_codec @ {$v_height}p, A: $a_codec)"
                set temp_file "$base"_tmp.mp4
                
                # Ejecución de ffmpeg (Nota: "$file" sin comillas simples extra)
                ffmpeg -v quiet -stats -i "$file" \
                    $ffmpeg_params \
                    -movflags +faststart \
                    -y "$temp_file"

                if test $status -eq 0
                    echo "✅ Éxito. Reemplazando original..."
                    rm "$file"
                    mv "$temp_file" "$base.mp4"
                else
                    set_color red
                    echo "❌ Error en $file. Manteniendo original."
                    set_color normal
                    rm -f "$temp_file"
                end
            else
                set_color cyan
                echo "✨ Omitido: $file ya cumple los requisitos."
                set_color normal
            end
        end
    end
    echo "🏁 ¡Proceso completado!"
end
