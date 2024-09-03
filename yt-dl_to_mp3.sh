#!/usr/bin/env fish

# ffmpeg options :
#   - hide_banner : silent
#   - loglevel error : show only errors
#   - n : don't replace file if output already exists (inverse parameter is y)

# yt-dlp options :
#   - q : quiet

# Fonction pour télécharger les vidéos à partir des liens dans links.txt
function download_from_yt
    set dir $argv[1]
    cat "$dir/links.txt" | while read -l url
        yt-dlp -q $url -o "$dir/%(title)s.%(ext)s"
    end
end

# Fonction pour convertir les fichiers vidéo en fichiers mp3
function convert_to_mp3
    set dir $argv[1]
    set ext $argv[2]
    for file in "$dir"/*.$ext
        if test -f "$file"
            set output "$dir/$(basename "$file" .$ext).mp3"
            ffmpeg -hide_banner -loglevel error -n -i "$file" -q:a 0 "$output"
            rm "$file"
        end
    end
end

# Fonction principale
function main
    set parent_dir $argv[1]

    # Vérifier si le dossier existe
    if not test -d $parent_dir
        echo "Le dossier $parent_dir n'existe pas."
        exit 1
    end

    echo "[i] Parent directory : $parent_dir"

    # Boucle sur chaque sous-dossier du dossier parent (une seule profondeur)
    for dir in (find $parent_dir -mindepth 1 -maxdepth 1 -type d)
        echo "[i] Checking directory $dir"
        # Vérifier si le fichier links.txt existe dans le sous-dossier
        if test -f "$dir/links.txt"
            echo "  \-> found $dir/links.txt"

            # Télécharger les vidéos depuis links.txt
            download_from_yt $dir

            # Convertir les fichiers vidéo en mp3
            convert_to_mp3 $dir "webm"
            convert_to_mp3 $dir "mkv"
            convert_to_mp3 $dir "mp4"
        end
    end
end

# Exécution de la fonction principale avec le dossier fourni en argument
if test (count $argv) -eq 0
    echo "Veuillez fournir un dossier en paramètre."
    exit 1
end

main $argv[1]
