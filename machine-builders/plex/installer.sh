MOUNT_PATHS=$@

mount_share() {
    path=$1
    machine=$2
    readwrite=$(get_readwrite $3)
    exports="/etc/exports"
    echo "$path $machine($readwrite,all_squash,no_subtree_check)" >> $exports
}

fix_repositories
install_packages tzdata curl xmlstarlet uuid-runtime unrar

install_packages_from_urls "$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu" | sed -n 's/.*url="\([^"]*\)".*/\1/p')"



apt-get -y autoremove && \
apt-get -y clean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /tmp/* && \
rm -rf /var/tmp/*

useradd -U -d /config -s /bin/false plex
usermod -G users plex

mkdir -p /config /transcode /data


# EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
# VOLUME /config /transcode

# ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
#     HOME="/config"

# ARG TAG=beta
# ARG URL=




for i in $MOUNT_PATHS; do
    params=($(get_colon_separated_arguments 3 $i))
    path=${params[0]}
    machine=${params[1]}
    readwrite=${params[2]}
    
    mount_share $path $machine $readwrite
done

# activate_services nfs