# Post-install Raspberry Pi Tweaks

Some notes about the first tweaks I apply on a freshly installed Arch Linux
image on a Raspberry Pi. The following notes apply to other Linux distros as
well. Maybe the commands and/or package names are different.

If, for whatever reason, I'll switch distro (why should I? Arch is the best one)
I may also update this guide, pointing to the Arch-specific stuff and offering
alternatives. In the meantime, if you stumble upon this page, do your own
research (DYOR) before blindly applying those tweaks. Moreover, this list is
highly opinionated and DYOR helps de-opinionate it. Feel free to discuss the
content by opening an [issue on github](https://github.com/electricant/electricant.github.io/issues).

## Fakehwclock

The Raspberry Pi does not have an hardware real time clock (RTC). Therefore,
upon reboot the time is lost and has to be set manually or via the network time
protocol (NTP). This process takes time and requires an internet connection
available after boot. The utility fake-hwclock [\[1\]][1] can be used to restore
the clock to an approximately accurate value to speed up the NTP clock
synchronization procedure.

Fake-hwclock is installed the usual way via pacman:

	# sudo pacman -Syu fake-hwclock

By default, the fake-hwclock-save.timer unit is run every 15 minutes and also 
15 minutes after boot. The saving interval is quite short and may damage the SD
card in the long run. Depending on the time accuracy requirements, by creating
an overlay file for the unit with the command:

	# sudo systemctl edit fake-hwclock-save.timer

the interval can be modified. By adding the following lines to the file, the
timer is run once per day:

	[Timer]
	OnUnitActiveSec=1day
	AccuracySec=1day

The 'AccuracySec' settings is used to save power and avoid waking up the CPU
just to save the time. Refer to [systemd.timer](https://www.freedesktop.org/software/systemd/man/systemd.timer.html) for more details about the various
timer config options. Keep in mind that the clock is automatically saved during
shutdown, independently of the last time it was saved. This means that, if the
Raspberry Pi is rebooted cleanly the clock will lag a few minutes. In case of a
power loss the clock will be one day behind actual time in the worst case.

## Use the Hardware Random Number Generator

More information is available here: [Rng-tools - ArchWiki](https://wiki.archlinux.org/title/Rng-tools).
This guide is shorter and tailored to the Raspberry Pi.

Make sure rng-tools is installed:

	# sudo pacman -Syu rng-tools

Disable haveged since it is no longer needed and it might compete with rngd

	# sudo systemctl disable --now haveged

Check that /etc/conf.d/rngd contains the line

	RNGD_OPTS="-o /dev/random -r /dev/hwrng"

otherwise add it to the file to tell the daemon where to find the hardware
random number generator.

Rngd can now be enabled and started:

	# sudo systemctl enable --now rngd

You can now check the amount of entropy reported by the kernel:

	# cat /proc/sys/kernel/random/entropy_avail

It should be around 3000 (the more the better).

On Raspberry Pis and other SBCs, rngd may exhibit sporadic CPU spikes to 100%
which can last quite a long time [\[2\]][2].
At the time of writing, a fix has already been merged to the repo. Anyway, the 
issue disappears by editing /etc/conf.d/rngd to include the following option and
restarting the daemon:

	RNGD_OPTS="-x jitter"

Apparently, starting from Linux kernel 5.6, both haveged and rng-tools are not
needed anymore [\[3\]][3][\[4\]][4]. This section is kept for posterity.

## Mount /var/cache (and whatnot) in memory with zram

[ZRAM](https://www.kernel.org/doc/html/latest/admin-guide/blockdev/zram.html) is a Linux kernel module to create block devices that store the data
compressed in RAM, this allows to store more data in the same amount of memory,
at the expense of CPU usage. This is ideal, for example, for /var/cache that
contains cached data from application programs and does not need to survive a
reboot.

Many guides already exist [\[5\]][5][\[6\]][6], I mixed and merged them to suit
my own taste. First of all one needs to load the zram module, telling it how
many devices to create. The simplest way to achieve this is to create the file
/etc/modules-load.d/zram.conf containing:

	zram

This loads the zram module on boot which, by default, starts a single device.
To change this behavior, create /etc/modprobe.d/zram.conf and insert:

	options zram num_devices=<desired number of zram devices>

Zram devices are block devices with no actual file system on them, so we need to
format the device before we can mount it somewhere. I used udev to format on
boot /dev/zram0 as ext4 without journalling. Removing the journal speeds up the
file system at the expense of probable data corruption if the power fails. Zram
contents are lost anyway if the power is removed so, I'd rather get my
performance bonus. Create /etc/udev/rules.d/10-zram.rules containing:

	KERNEL=="zram0", SUBSYSTEM=="block", ACTION=="add", \
		ATTR{disksize}="256M" ATTR{mem_limit}="256M", \
		RUN+="/sbin/mkfs.ext4 -O ^has_journal -L $name $env{DEVNAME}"

This creates a 256M zram disk formatted as ext4 on /dev/zram0.

The device can now be mounted via /etc/fstab as usual:

	/dev/zram0 /var/cache ext4  defaults,nosuid,nodev,noexec 0 0

## Enable the Watchdog

*NOTE:* I'm still checking whether I really need this or not. Or even if it
works and keeps my Pi up and running. For the time being I'll keep this section
as a dump of unorganized thoughts and references.

https://wiki.archlinux.org/title/Arch_User_Repository
https://aur.archlinux.org/packages/watchdog/ -> add armv6h to the architectures
in PKGBUILD
https://raspberrypi.stackexchange.com/questions/92462/installing-watchdog-daemon-on-arch

## References

<div class="references">
\[1\] [fake-hwclock for Arch Linux Arm on Raspberry Pi (using systemd)][1]
[1]: https://archplusplus.co.uk/post/40202081414/fake-hwclock-for-arch-linux-arm-on-raspberry-pi

\[2\] [Sporadic excessive CPU usage on RPi4B - Issue #136][2]
[2]: https://github.com/nhorman/rng-tools/issues/136

\[3\] [random: make /dev/random be almost like /dev/urandom][3]
[3]: https://github.com/torvalds/linux/commit/30c08efec8884fb106b8e57094baa51bb4c44e32

\[4\] [Is haveged still useful/relevant? - Issue #57][4]
[4]: https://github.com/jirka-h/haveged/issues/57

\[5\] [zram - Gentoo Wiki][5]
[5]: https://wiki.gentoo.org/wiki/Zram

\[6\] [Improving performance - ArchWiki][6]
[6]: https://wiki.archlinux.org/title/Improving_performance#zram_or_zswap
</div>
