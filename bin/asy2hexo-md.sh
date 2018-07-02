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
DEST_MEDIA_BASE_URL=/media/asymptote
DEST_MEDIA_DIR=~/code/pi/hexo-blog/source$DEST_MEDIA_BASE_URL

rm -rf $DEST_DIR && rm -rf $DEST_MEDIA_DIR

## Commande pour asymptote
ASYCOM=/usr/local/bin/asy
ASYOPTION="-noprc "
## Commande pour convert
CONVERTCOM=/usr/bin/convert

EXTIMAG="png" #format des images sorties par defaut.
EXTASY="eps"  #format de sortie de asy par defaut
# sauf si le code contient le mot "opacity" (=> pdf))
MAXW=200     # Largeur maximale des images
MAXH=$MAXW   # Hauteur maximale des images
AFFCODE=true # par defaut chaque image est suivie du code qui la genere. (option -nocode pour changer)

GENCODE=true
ODOC=false
ANIM=false

while true; do
    case $1 in
        -gif)
            EXTIMAG="gif"
            ;;
        -png)
            EXTIMAG="png"
            ;;
        -pdf) # Force l'utilisation du pdf
            EXTASY="pdf"
            ;;
        -odoc) # On est dans le r�pertoire des exemples officiels.
            ODOC=true
            nofind=$2
            ;;
        -anim) # On est dans le r�pertoire des animations.
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

while true; do
    case $1 in
        -gif)
            EXTIMAG="gif"
            ;;
        -png)
            EXTIMAG="png"
            ;;
        -pdf) # Forece l'utilisation du pdf
            EXTASY="pdf"
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Recupere le texte qui se trouve entre les balises <body> et </body>
bodyinner() {
    cat $1 | awk -v FS="^Z" "/<body>/,/<\/body>/" | sed "s/<\/*body>//g" | sed 's/^ *<pre>/<pre class="asymptote">/g'
}

get_asy_directories() {
    find "${SRC_DIR}" -type d ! -regex "${SRC_DIR}" ! -regex '.*/modules.*' -maxdepth 1 -print | sort
}

# $1 is the directory to find
get_asy_files() {
    if $ODOC; then
        find "${1}" -type f -name '*\.asy' $nofind -print | sort
    else
        find "${1}" -name 'fig*\.asy' -type f -print | sort
    fi
}

mkdirIfNotExits() {
    [ -e "$1" ] || {
        echo "Creating directory $1"
        mkdir -p "$1" || exit 1
    }
}

CREATECODE=false # Par defaut il n'y a pas a recreer code.xml et index.html

for dir in $(get_asy_directories); do
    tagsStr=''
    tags=''

    echo "* Handling directory : ${dir}..."

    for fic in $(get_asy_files ${dir}); do
        srcFile="$fic" # Renaming
        echo "-> Handling $srcFile"
        srcFileNoExt="${srcFile%.*}"
        srcFileTag="${srcFileNoExt}.tag"
        srcFileVersion="${srcFileNoExt}.ver"
        srcFileHtml="${srcFileNoExt}.html"
        srcFilePostId="${srcFileNoExt}.postid"
        srcFileNameNoExt=$(basename "$srcFileNoExt")
        srcFilePath="${fic%/*}"
        srcFileDirName=$(basename "$srcFilePath")
        currentDestDir="${DEST_DIR}/${srcFileDirName}"
        category=$(echo ${srcFileDirName} | awk 'sub(/./,toupper(substr($1,1,1)),$1)')
        destFileNoExt="${DEST_DIR}/${srcFileDirName}/${category}"
        destFileMd="${destFileNoExt}.md"
        destAssetPath="${DEST_MEDIA_DIR}/${srcFileDirName}"
        destAssetBaseURL="${DEST_MEDIA_BASE_URL}/${srcFileDirName}"

        mkdirIfNotExits "$currentDestDir"
        mkdirIfNotExits "$destAssetPath"

        [ "$category" == "Tailpieces" ] && continue

        tagsFig=''
        tagSpace=''

        [ -e ${srcFileTag} ] && {
            for tag in $(cat ${srcFileTag}); do
                tag=$(
                    echo $tag | awk -F '|' '{print $3}' |
                        awk -F '|' '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}2' |
                        tr ' /' '__'
                   )

                [ "$tag" == "" ] || {
                    tagsFig="${tagsFig}${tagSpace}#asy-${tag}"
                    echo $tags | grep -q "@${tag}@" || tags="${tags}@${tag}@"
                    tagSpace=' | '
                }

            done
        }

        [ "$tagsFig" == "" ] || {
            tagsFig="
Tags for this figure : ${tagsFig}"
        }
        # le tag ADDPDF permet de mettre un lien vers le fichier .pdf
        COMB="s/ADDPDF/<a href=\"###DIRNAME###${destAssetPath}/out.pdf\">${srcFileNameNoExt}.pdf<\/a>/g"

        # *=======================================================*
        # *...Creation du fichier .md a partir du fichier .asy....*
        # *=======================================================*
        # if [ "${srcFile}" -nt "${destFileMd}" ]; then
        echo "Creating ${destFileMd}"
        # content=$(cat ${srcFile})
        content=$(bodyinner ${srcFileHtml} | sed 's/geometry_dev/geometry/g;s/{/\&lbrace;/g;s/}/\&rbrace;/g')
        # echo $content
        # exit 0
        postId=$(cat ${srcFilePostId})

        [ -z $postId ] && {
            postId=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 18 | head -n 1)
        }

        ## Not used now because of problem whith rel url
        #  See https://hexo.io/docs/asset-folders.html
        imgAlt="asymptote ${category} ${tags} ${srcFileNameNoExt}"
        imgMdk="![${imgAlt}](${destAssetBaseURL}/${srcFileNameNoExt}.png \"${srcFileNameNoExt}\")"
        asyversion="$(sed 's/ \[.*\]//g;s/Asymptote version //g' ${srcFileVersion})"

        [ "$tagsStr" == "" ] || {
            tagsStr="tags:${tagsStr}"
        }

        cp "${srcFileNoExt}.png" "${destAssetPath}/"
        [ -e "${srcFileNoExt}r.png" ] && {
            cp "${srcFileNoExt}r.png" "${destAssetPath}/"

            imgMdk="
<a href=\"${destAssetBaseURL}/${srcFileNameNoExt}.png\">
<img src=\"${destAssetBaseURL}/${srcFileNameNoExt}r.png\"
     alt=\"${imgAlt}\"
     title=\"Click to enlarge\"
/>
</a>"
        }

        [ -e "${srcFileNoExt}.pdf" ] && cp "${srcFileNoExt}.pdf" "${destAssetPath}/"
        [ -e "${srcFileNoExt}.gif" ] && {
            cp "${srcFileNoExt}.gif" "${destAssetPath}/"

            imgMdk="
<a href=\"${destAssetBaseURL}/${srcFileNameNoExt}.gif\">
<img src=\"${destAssetBaseURL}/${srcFileNameNoExt}.png\"
     alt=\"${imgAlt}\"
     title=\"Click to see the animation\"
/>
</a>

This animation is also available in the [Syracuse web site](http://www.melusine.eu.org/syracuse/asymptote/animations/).
"
        }

        [ ! -e "$destFileMd" ] && {
            sleep 1
            cat >"$destFileMd" <<EOF
title: "Asymptote ${category}"
date: 2013-7-13 $(date "+%H:%M:%S")
id: $postId
categories:
- [Tech, Programming, Asymptote]
tags:@TAGS
---
EOF
        }

        figName="$(echo ${srcFileNameNoExt} | sed 's/fig/Figure /')"

        cat >>"$destFileMd" <<EOF

# ${figName}
${tagsFig}
$imgMdk

This code was compiled with [Asymptote](http://asymptote.sourceforge.net/) ${asyversion}

$content
EOF



        # fi

    done

    tagsStr=$(echo $tags | sed -E "s/@@/@/g;s/@$//g;s/@([^@]+)/£M£- \"asy-\1\"/g")

    sed -i "s/tags:@TAGS/tags:${tagsStr}/g;s/£M£/\n/g" "$destFileMd"
done
