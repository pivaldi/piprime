#!/bin/bash

# Copyright (C) 2018
# Author: Philippe IVALDI
#
# This program is free software ; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation ; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY ; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program ; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

## Convert all the asy directory tree to hexo markdown directory tree

SRC_DIR=~/code/pi/asymptote/exemples/src
DEST_DIR=~/code/pi/hexo-blog/source/_posts/en/asymptote

## Commande pour asymptote
ASYCOM=/usr/local/bin/asy
ASYOPTION="-noprc "
## Commande pour convert
CONVERTCOM=/usr/bin/convert

EXTIMAG="png" #format des images sorties par defaut.
EXTASY="eps"  #format de sortie de asy par defaut
# sauf si le code contient le mot "opacity" (=> pdf))
MAXW=200      # Largeur maximale des images
MAXH=$MAXW    # Hauteur maximale des images
AFFCODE=true  # par defaut chaque image est suivie du code qui la genere. (option -nocode pour changer)

GENCODE=true
ODOC=false
ANIM=false

while true
do
    case $1 in
        -gif)
	    EXTIMAG="gif"
            ;;
        -png)
	    EXTIMAG="png"
            ;;
        -pdf)# Force l'utilisation du pdf
            EXTASY="pdf"
            ;;
        -odoc)# On est dans le répertoire des exemples officiels.
            ODOC=true
            nofind=$2
            ;;
        -anim)# On est dans le répertoire des animations.
            ANIM=true
            ;;
        -nocode)
            EXTASY="pdf"
            GENCODE=false # index.html est remplace par figure-index.html
            # et les figures pointent sur le pdf correspondant
            ;;
        *)
            break
            ;;
    esac
    shift
done

ASYCOM=/usr/local/bin/asy

while true
do
    case $1 in
        -gif)
            EXTIMAG="gif"
            ;;
        -png)
            EXTIMAG="png"
            ;;
        -pdf)# Forece l'utilisation du pdf
            EXTASY="pdf"
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Recupere le texte qui se trouve entre les balises <body> et </body>
function bodyinner()
{
    cat $1 | awk -v FS="^Z" "/<body>/,/<\/body>/" | sed "s/<\/*body>//g" | sed 's/^ *<pre>/<pre class="asymptote">/g'
}

function get_asy_files()
{
    if $ODOC; then
        find "$SRC_DIR" -type f -name '*\.asy' $nofind -print | sort -r
    else
        find "$SRC_DIR" -name 'fig*\.asy' -type f -print | sort -r
    fi
}

mkdirIfNotExits() {
    [ -e "$1" ] || {
        echo "Creating directory $1"
        mkdir -p "$1" || exit 1
    }
}

CREATECODE=false # Par defaut il n'y a pas a recreer code.xml et index.html

for fic in $(get_asy_files) ; do
    srcFile="$fic" # Renaming
    echo "-> Handling $srcFile"
    srcFileNoExt="${srcFile%.*}"
    srcFileTag="${srcFileNoExt}.tag"
    srcFileHtml="${srcFileNoExt}.html"
    srcFilePostId="${srcFileNoExt}.postid"
    srcFileNameNoExt=$(basename "$srcFileNoExt")
    srcFilePath="${fic%/*}"
    srcFileDirName=$(basename "$srcFilePath")
    currentDestDir="${DEST_DIR}/${srcFileDirName}"
    destFileNoExt="${DEST_DIR}/${srcFileDirName}/${srcFileNameNoExt}"
    destFileMd="${destFileNoExt}.md"
    destAssetPath="${destFileNoExt}"
    category=$(echo ${srcFileDirName} | awk 'sub(/./,toupper(substr($1,1,1)),$1)')

    mkdirIfNotExits "$currentDestDir"
    mkdirIfNotExits "$destAssetPath"

    tagsStr=''
    isFirstTag=true
    firstTag=''
    tags=''
    space=''

    for tag in $(cat ${srcFileTag}); do
        tag=$(
            echo $tag | awk -F '|' '{print $3}' | \
                awk -F '|' '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}2' | \
                tr ' /' '__'
           )

        $isFirstTag && firstTag=$tag
        tags="${tags}${space}${tag}"
        space=' '
        isFirstTag=false
        tagsStr="${tagsStr}
- #Asy${tag}"
    done

    # le tag ADDPDF permet de mettre un lien vers le fichier .pdf
    COMB="s/ADDPDF/<a href=\"###DIRNAME###${destAssetPath}/out.pdf\">${srcFileNameNoExt}.pdf<\/a>/g"

    # *=======================================================*
    # *...Creation du fichier .md a partir du fichier .asy....*
    # *=======================================================*
    # if [ "${srcFile}" -nt "${destFileMd}" ]; then
        echo "Creating ${destFileMd}"
        # content=$(cat ${srcFile})
        content=$(bodyinner ${srcFileHtml} | sed 's/geometry_dev/geometry/g')
        # echo $content
        # exit 0
        postId=$(cat ${srcFilePostId})

        partialTitle="$category $firstTag"
        [ $category == $firstTag ] && partialTitle=$category

        ## Not used now because of problem whith rel url
        #  See https://hexo.io/docs/asset-folders.html
        imgMdk="![alt asymptote ${category} ${tags} ${srcFileNameNoExt}](out.png "${srcFileNameNoExt}")"

        ## Using this one instead, waiting for best solution
        imgMdk="{% asset_img out.png "${srcFileNameNoExt}" %}"

        cat>"$destFileMd"<<EOF
title: "Asymptote ${partialTitle} -- ${srcFileNameNoExt}"
date: 2013/7/13 $(date "+%H %M %S %N")
comments: false
categories:
- [Programming, Asymptote, $category]
tags:${tagsStr}
---

$imgMdk
$content
EOF

cp "${srcFileNoExt}.png" "${destAssetPath}/out.png"

# fi

done
