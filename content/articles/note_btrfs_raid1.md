# A Note About Btrfs RAID1 for my Future Self

## Introduction

This is just a random note I have collected about Btrfs RAID1 [\[1\]][1] and 
how to deal with it in my NAS setup (I really have to write about it some day).

## How Btrfs RAID1 Works

By default RAID1 in Btrfs creates no more than two copies of the data,
regardless of the number of disks in the array. This means that, from the data
integrity point of view, there is no point in using more than two disks. In
RAID1, mode when a third disk is added, only the total capacity is increased. 
Btrfs distributes the writes in such a way that the array will survive the
failure of one disk only. There are different RAID options [\[2\]][2] that 
enable more copies of the data and parity with more than two disks.

## Btrfs RAID1 in my NAS

The motherboard I'm currently using has 4 serial-ATA ports. One of them is used
for the OS disk while the other three are left for the data RAID.

Of the three remaining ports, two are dedicated to the main hard disks while the
third one is left unused. By doing so I can use this spare port to throw in a
new hard disk in case one is near its end of life but it is not yet failed.
I will eventually remove the failing disk after the new one is in place,
leaving its port free for future drive replacements.

To add a new device to a Btrfs RAID:
	
	# btrfs device add /dev/newdrive /mountpoint

To remove the failed disk:
	
	# btrfs device remove /dev/broken /mountpoint

This command removes the selected disk and automatically rebalances the data
within the remaining hard drives.

And while I'm at it why not throw in a run of

	# badblocks -b 4096 -e 1 -wsv /dev/sdX

as a new drive burn-in ritual [\[3\]][3] before formatting and adding the drive
to the pool?

After going through all the steps above the array is ready. However, I have to
buy a new hard drive to have a spare when needed. It is worth having a look at 
[r/DataHoarder wiki](https://www.reddit.com/r/datahoarder/wiki/index) for some
tips.

## References

\[1\] [Using Btrfs with Multiple Devices][1]
[1]: https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices

\[2\] [Manpage/mkfs.btrfs][2]
[2]: https://btrfs.wiki.kernel.org/index.php/Manpage/mkfs.btrfs#PROFILES

\[3\] [New Drive Burn-In Rituals][3]
[3]: https://perfectmediaserver.com/hardware/new-drive-burnin/

