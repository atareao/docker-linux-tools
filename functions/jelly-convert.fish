function jelly-convert --description 'Convierte videos a 720p H.264 para Jellyfin con verificación previa'
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

            # 1. Extraer metadatos: Codecs y Altura (height)
            set -l metadata (ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,height -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file")
            
            # ffprobe devuelve los valores en líneas: 1. Video Codec, 2. Height, 3. Audio Codec
            set -l v_codec $metadata[1]
            set -l v_height $metadata[2]
            set -l a_codec $metadata[3]

            set -l needs_v_conv false
            set -l needs_a_conv false
            set -l v_arg "copy"
            set -l a_arg "copy"
            set -l filter_arg ""

            # 2. Lógica de Video: Verificar codec y resolución
            if test "$v_codec" != "h264" -o "$v_height" -gt 720
                set v_arg "libx264"
                set filter_arg "-vf scale=-1:720"
                set needs_v_conv true
            end

            # 3. Lógica de Audio: Verificar codec
            if test "$a_codec" != "aac"
                set a_arg "aac"
                set needs_a_conv true
            end

            # 4. ¿Es necesaria la conversión?
            if test "$needs_v_conv" = "true" -o "$needs_a_conv" = "true"
                echo "🍿 Procesando ($v_codec@{$v_height}p, $a_codec): $file"
                set temp_file "$base"_tmp.mp4
                
                # Ejecución de ffmpeg (usando variables dinámicas)
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
                echo "✨ Omitido: $file ya es H.264/AAC y <= 720p"
                set_color normal
            end
        end
    end
    echo "🏁 ¡Proceso completado!"
end
