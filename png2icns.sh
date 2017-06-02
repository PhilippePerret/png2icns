#!/bin/bash

#
# Ce script transforme un unique PNG de 1024x1024 en un fichier ICNS
#

# query="/Users/philippeperret/Programmation/Electron/afaire/_DEV_/imagerie/Chantier/Logo/Logo_01.png"

# ---------------------------------------------------------------------
# Arguments parsing

# Options par défaut
verbose=false
keepiconsetfolder=false

for arg in "$@"
do
case $arg in
    -h|--help)
    echo "

    png2icns

      let's convert a 1024x1024 PNG image to a ICNS icon (for your Mac).
      PNG -> ICNS

Usage
-----
      ./png2icns [options] /path/to/image.png

Options
-------

      -h --help       Display this help
      -v --verbose    Verbose mode (default: false)
      -d --keep-iconset-folder

"
    exit 0
    shift # past argument
    ;;
    -v|--verbose)
    verbose=true
    shift
    ;;
    -d|--keep-iconset-folder)
    keepiconsetfolder=true
    shift
    ;;
    *)
    query=$arg
    ;;
esac
shift
done

readonly VERBOSE=$verbose
readonly KEEP_ICONSET_FOLDER=$keepiconsetfolder
readonly FILE="$query"
FNAME=$(basename $FILE)
FILE_FOLDER=$(dirname $FILE)
AFFIXE=${FNAME%%.*}
ICON_NAME="${AFFIXE}.icns"


$VERBOSE && echo -e "\n\n=== PNG to ICNS Conversion ($FNAME -> $ICON_NAME) ===\n"

# ---------------------------------------------------------------------
# Tests

# File must exist
if [ ! -f $FILE ];
then
  echo "ERROR: File '$FILE' doesn't exist."
  exit 1
fi

# File must have .png extension
FILE_EXTNAME=${FILE##*.}
if [ ! $FILE_EXTNAME = 'png' ];
then
  echo "ERROR: File '$FILE' must have a '.png' extname not a '.$FILE_EXTNAME' extname."
  exit 1
fi

# File should have 1024x1024 sixe
retour=`sips -g pixelWidth -g pixelHeight "$FILE"`
extrait=${retour#*pixelWidth: }
WIDTH=$((0+${extrait%% *}))
extrait=${retour#*pixelHeight: }
HEIGHT=$((0+${extrait%% *}))
$VERBOSE && echo "Original image size: ${WIDTH}x${HEIGHT}"
if (($WIDTH < 1024)) ;
then
  echo "WARNING: PNG Image width (${WIDTH}px) is less then 1024 pixels. Perhaps the icon'll be ugly…"
fi
if (($HEIGHT < 1024));
then
  echo "WARNING: PNG Image height (${HEIGHT}px) is less then 1024 pixels. Perhaps the icon'll be ugly…"
fi

if (( $HEIGHT != $WIDTH ));
then
  echo "WARNING: PNG Image width and height are not the same (${WIDTH}px vs ${HEIGHT}px). Perhaps the icon'll be ugly…"
fi

# ---------------------------------------------------------------------


$VERBOSE && echo "Fichier original: ${FNAME}"
$VERBOSE && echo "Affixe : ${AFFIXE}"

# The iconset folder
# We put inside all the png we need to build the icns icon
ICONSET_FOLDER="./Icones.iconset"

# Go in the image folder
cd $FILE_FOLDER
$VERBOSE && echo `pwd`

# = Si le dossier .iconset existe, il faut le détruire avant
# = de le faire
if [ -d $ICONSET_FOLDER ];
then
  rm -R $ICONSET_FOLDER
fi
mkdir $ICONSET_FOLDER

# Si l'icon existe déjà, il faut la détruire
if [ -f "./${ICON_NAME}" ];
then
  rm ./$ICON_NAME
  $VERBOSE && echo "A icon $ICON_NAME already existed. I removed it."
fi

# = D'abord, on doit faire un set de PNG à l'aide de sips
for width in 512 256 128 32 16 ;
do
  fname_dest="icon_${width}x${width}.png"
  $VERBOSE && printf "Création du PNG ${fname_dest}… "
  # On fait une copie du fichier redimensionné dans le dossier
  sips $FNAME -z $width $width --out "${ICONSET_FOLDER}/${fname_dest}"
  $VERBOSE && echo "done"

  # On fait des fichier @2x pour tout les fichiers hors 1024 et 516
  # sips -z 32 32     Icon1024.png --out MyIcon.iconset/icon_16x16@2x.png
  dblwidth=$(( 2 * $width ))
  fname_dest_dblw="icon_${width}x${width}@2x.png"
  $VERBOSE && printf "Fichier ${fname_dest_dblw}… "
  sips $FNAME -z $dblwidth $dblwidth --out "${ICONSET_FOLDER}/${fname_dest_dblw}"
  $VERBOSE && echo "done"
done

# = Maintenant que le set de fichiers PNG est fabriqué, on peut construire
# = les ICNS
# cp Icon1024.png MyIcon.iconset/icon_512x512@2x.png

# === Faire les icns ===
$VERBOSE && printf "Generating ICNS…"
iconutil -c icns "$ICONSET_FOLDER"

if [ ! -f icones.icns ];
then
  echo "ERROR: Unable to built ICNS icon… Sorry."
  exit 1
fi

# === On renomme le fichier obtenu, qui s'appelle pour le moment
# === icone.icns
mv icones.icns "$ICON_NAME"
$VERBOSE && echo " done"

# === Détruire le dossier des PNG ===
if $KEEP_ICONSET_FOLDER ;
then
  $VERBOSE && echo "I don't remove iconset folder with all PNG images."
else
  $VERBOSE && printf "* Removing iconset folder…"
  rm -R "$ICONSET_FOLDER"
  $VERBOSE && echo " done"
fi

# Si l'icone existe bien, c'est un succès
if [ -f "./${ICON_NAME}" ];
then
  echo -e "\nIcon '${ICON_NAME}' generated with success.\nIn: ${FILE_FOLDER}/"
else
  echo "WARNING: Strange… Can't find the ./${ICON_NAME} icon…"
fi
