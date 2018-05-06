MOUNT_PATHS=$@

get_writable() {
    case "$1" in
        r) echo no ;;
        w) echo yes ;;
        *)
            >&2 echo "$1: Unknown read/write flag"
            exit 1
    esac
}

mount_share() {
    path=$1
    name=$2
    writable=$(get_writable $3)
    echo "Mounting $path as $name (writable=$writable)"
    smbconf="/etc/samba/smb.conf"
    echo "" >> $smbconf
    echo "[$name]" >> $smbconf
    echo "    path = $path" >> $smbconf
    echo "    writable = $writable" >> $smbconf
    echo "    browsable = yes" >> $smbconf
    echo "    guest ok = yes" >> $smbconf
}

fix_avahi()
{
    sed -i 's/\(rlimit-nproc\)/#\1/g' /etc/avahi/avahi-daemon.conf
    sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf
    sed -i 's/need dbus/use dbus/g' /etc/init.d/avahi-daemon
    rm /etc/avahi/services/ssh.service /etc/avahi/services/sftp-ssh.service
}

fix_repositories
install_packages samba avahi
fix_avahi

for i in ${MOUNT_PATHS}; do
    host_path=$(echo $i|sed 's/\([^:]*\):.*/\1/g')
    name=$(echo $i|sed 's/[^:]*:\([^:]*\):.*/\1/g')
    readwrite=$(echo $i|sed 's/[^:]*:[^:]*:\([^:]*\).*/\1/g')
    mount_share $host_path $name $readwrite
done

activate_services samba avahi-daemon
