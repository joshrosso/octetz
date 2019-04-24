#!/bin/bash

# This script creates all the static assets for octetz.com.
# It achieves this in the following steps.
#
# 1. Clone all repositories if not already existent in $OCTETZ_PATH
# 2. Convert markdown to html using pandoc against a custom HTML template
# 3. Move generated HTML to $STATIC_SITE_PATH/posts
# 3. Copy images to $STATIC_SITE_PATH/img

bold=`tput bold`
green=`tput setaf 2`
reset=`tput sgr0`

OCTETZ_PATH=/home/josh/f/d/octetz
STATIC_SITE_PATH=/home/josh/f/d/octetz/octetz-static

POSTS=( 
"vim-as-go-ide" 
"k8s-network-policy-apis" 
"contour-adv-ing-and-delegation" 
"ha-control-plane-k8s-kubeadm" 
"secure-port-k8s-cm-sched" 
"setting-up-psps" 
"rr-setup"
)

TEMPLATE=template.html

printf "${green}===============> Pulling any missing repos${reset}"
for POST in "${POSTS[@]}"
do
  if [ ! -d ${OCTETZ_PATH}/${POST} ]
  then
    CURRENT_DIR=$(pwd)
    cd ${OCTETZ_PATH}
    git clone https://github.com/octetz/${POST}
    cd ${CURRENT_DIR}
  fi
done

echo
printf "${green}===============> Generating HTML and Copying resources to ${STATIC_SITE_PATH}${reset}"
for POST in "${POSTS[@]}"
do
    echo 
    echo Processing ${OCTETZ_PATH}/${POST}
    echo

    pandoc -f markdown -t html5 --template=${TEMPLATE} -o ${POST}.html ${OCTETZ_PATH}/${POST}/README.md
    mv -v ${POST}.html ${STATIC_SITE_PATH}/posts/
    cp -v ${OCTETZ_PATH}/${POST}/img/* ${STATIC_SITE_PATH}/posts/img/
done

echo
printf "${green}===============> Moving static assets\n${reset}"
    cp -v index.html ${STATIC_SITE_PATH}/
    cp -v posts/index.html ${STATIC_SITE_PATH}/posts
    cp -v rss/feed.xml ${STATIC_SITE_PATH}/rss
echo

echo
printf "${green}===============> Static site regenerated\n${reset}"
printf "${green}git -C ${STATIC_SITE_PATH} add -A &&\ \n${reset}"
printf "    ${green}git -C ${STATIC_SITE_PATH} commit -m \"update\" &&\ \n${reset}"
printf "    ${green}git -C ${STATIC_SITE_PATH} push origin master\n${reset}"
echo
