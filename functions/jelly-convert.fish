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

            set -l needs_v_conv false
            set -l needs_a_conv false
            set -l v_arg "copy"
            set -l a_arg "copy"
            set -l filter_arg ""

            # 3. Lógica de verificación
            # Convertimos a H264 si no lo es o si supera los 720p
            if test "$v_codec" != "h264" -o "$v_height" -gt 720
                set v_arg "libx264"
                set filter_arg "-vf scale=-1:720"
                set needs_v_conv true
            end

            # Convertimos audio si no es AAC
            if test "$a_codec" != "aac"
                set a_arg "aac"
                set needs_a_conv true
            end

            # 4. Procesamiento
            if test "$needs_v_conv" = "true" -o "$needs_a_conv" = "true"
                echo "🍿 Procesando: $file (V: $v_codec @ {$v_height}p, A: $a_codec)"
                set temp_file "$base"_tmp.mp4
                
                ffmpeg -v quiet -stats -i "$file" \
                    $filter_arg \
                    -c:v $v_arg -crf 20 -preset fast \
                    -c:a $a_arg -b:a 128k \
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
