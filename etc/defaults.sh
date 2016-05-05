# debugging options
#set -x
#set >&2

dir=/usr/share/ganeti/extstorage/zfs/

host_config=$dir/etc/`hostname -s`.sh
test -e $host_config && . $host_config

# when enabled debugging logs to debug.log in $LOG_DIR
test -z "$DEBUG" && DEBUG="0"

# log directory (used by debugging)
test -z "$LOG_DIR" && LOG_DIR="/var/log/ganeti/extstorage"

# parameters for zfs create, by default
# -s	sparse
# -b 4k	block size sutable for ext4 filesystem which ganeti uses
# lz4	compression with low cpu operhead which always helps
test -z "$EXTP_CREATE" && EXTP_CREATE="-s -b 4k -o compression=lz4"

# on zfs destroy remove dependent snapshots
test -z "$EXTP_DESTROY" && EXTP_DESTROY="-R"

# emulate VG configured in cluster for wrapper scripts in sbin
test -z "$EXTP_VG" && EXTP_VG='ffzgvg'

# zfs pool and file system (existing) where to create block devices
test -z "$EXTP_ZFS" && EXTP_ZFS=tmp500g/$EXTP_VG

# show numbers without compression for volume sizes
test -z "$EXTP_USED" && EXTP_USED=logicalused

export VOL_NAME

zfs_get() {
zfs get $1 -o value -p -H $EXTP_ZFS/$VOL_NAME
}

log_start() {
	if [ $DEBUG -eq 1 ] && [ -w "$LOG_DIR" ]; then
		echo -n "`date '+%d-%m-%Y %H:%M:%S'` - [`basename $0`]: Starting command" >> $LOG_DIR/zfs-debug.log
		if [ -n "$*" ]; then
			echo " (parameters: $*)" >> $LOG_DIR/zfs-debug.log
		else
			echo "" >> $LOG_DIR/zfs-debug.log
		fi
	fi
}

log_event() {
	if [ $DEBUG -eq 1 ] && [ -w "$LOG_DIR" ]; then
		echo "`date '+%d-%m-%Y %H:%M:%S'` - [`basename $0`]: $1" >> $LOG_DIR/zfs-debug.log
	fi
}
