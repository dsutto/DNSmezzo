#!/bin/sh

# Run various tests against hard disks to measure performances. Linux
# only.

set -e

SU=sudo
user=${USER}
SUPG="${SU} -u ${pguser}"
# http://www.coker.com.au/bonnie++/
BONNIE=bonnie++
bonnie_options=""
# http://developer.postgresql.org/pgdocs/postgres/pgbench.html
PGBENCH=/usr/lib/postgresql/8.3/bin/pgbench
pguser=postgres
SUPG="sudo -u $pguser"
# Must be able to log in without passwords
pgtester=$USER
tablespace=benchmarkpartition
database=benchmark
pgbench_scale=100
pgbench_concurrent=15
pgbench_transactions=1000

if [ -z "$2" ]; then
    echo "Usage: $0 partition mountpoint" >&2
    exit 1
fi

partition=$1
mountpoint=$2
if [ ! -d $mountpoint ]; then
    echo "Directory $mountpoint does not exist" >&2
    exit 1
fi
if [ ! -e /dev/$partition ]; then
    echo "Partition /dev/$partition does not exist" >&2
    exit 1
fi

format() {
    if [ -z "$1" ]; then
	echo "Usage: test_onefs fstype" >&2
	exit 1
    fi
    fstype=$1
    case $fstype in
	ext2)
	    ${SU} mke2fs -q /dev/$partition
	    ;;
	ext3)
	    ${SU} mke2fs -q -j /dev/$partition
	    ;;
	ext4)
	    ${SU} mke2fs -q -t ext4 /dev/$partition
	    ;;
	xfs)
	    ${SU} mkfs.xfs -f /dev/$partition
	    ;;
	jfs)
	    ${SU} jfs_mkfs -q /dev/$partition
	    ;;
	*) 
	    echo "Unsupported filesystem type $fstype" >&2
	    exit 1
	    ;;
     esac
}

test_onefs() {
    if [ -z "$1" ]; then
	echo "Usage: test_onefs fstype" >&2
	exit 1
    fi
    fstype=$1
    echo "Formatting $partition..."
    format $fstype
    ${SU} mount /dev/${partition} $mountpoint
    ${SU} chown ${user} $mountpoint
    echo "Running Bonnie on $mountpoint..."
    ${BONNIE} ${bonnie_options} -d $mountpoint
    ${SU} umount $mountpoint
    echo "Re-formatting $partition..."
    format $fstype
    ${SU} mount /dev/${partition} $mountpoint
    ${SU} chown ${pguser} $mountpoint
    ${SUPG} mkdir ${mountpoint}/db
    ${SUPG} psql -c "CREATE tablespace $tablespace location '${mountpoint}/db'"
    ${SUPG} createdb --owner $pgtester --tablespace $tablespace $database
    ${PGBENCH} -U ${pgtester} -i -s $pgbench_scale ${database}
    echo "Running pgbench on $mountpoint..."
    ${PGBENCH} -U ${pgtester} -t $pgbench_transactions -c $pgbench_concurrent ${database}
    ${SUPG} dropdb $database
    ${SUPG} psql -c "DROP tablespace $tablespace"
    # "device is busy" is we are too fast
    sleep 10
    ${SU} umount $mountpoint
}

# ext4 not tested, no support for it in Debian "lenny"
for fs in ext2 ext3 xfs jfs; do
    echo ""
    echo "Testing $fs at $(date)..."
    echo ""
    test_onefs $fs
    echo ""
    echo "Ending test of $fs at $(date)"
    echo ""
done



