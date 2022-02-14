# Linux VMs with qemu

## Introduction

Sometimes I have to test various network configurations involving linux
machines.

Sometimes I use my own PC and some other device such as a Raspberry pi this has
the advantage that each device physically exists and can be poked at.
The main drawback is that the setup is cumbersome and time consuming and there's
the risk of screwing something up with the configuration of my main laptop.

The ideal would be to have a bunch of virtual machines connected together
through some network interfaces, each one doing its thing independently.
The VMs have also connected to the internet in order to download the required
packages and updates.

As an added bonus the test setup should be repeatable and has to be launched
easily from the command line.

This page contains some notes on how I accomplished such thing.

## Guest OS installation

I won't go into the details of installing a linux guest OS in qemu as there's
plenty of guides on the internet [\[1\]][1].

## Startup Script

Let's get straight into it. This is the setup I use for launching a server with
three clients. Each machine is connected to the internet and to each other
through a virtual layer 2 switch [\[2\]][2]. Please note that this script
requires root privileges to be effective.

	#!/bin/bash

	# Amount of RAM each VM is given
	RAM_SIZE_MB=512

	# Additional qemu options
	QEMU_OPTIONS="-enable-kvm -vga std"

	# interface names
	TAP_SERVER=tapSrv0
	TAP1=tap1
	TAP2=tap2
	BRIDGE=brVrt0

	# Preliminary network interface setup (requires root privieges)
	sudo ip tuntap add $TAP_SERVER mode tap user `whoami`
	sudo ip link set $TAP_SERVER up

	sudo ip tuntap add $TAP1 mode tap user `whoami`
	sudo ip link set $TAP1 up

	sudo ip tuntap add $TAP2 mode tap user `whoami`
	sudo ip link set $TAP2 up

	sudo ip link add $BRIDGE type bridge
	sudo ip link set $BRIDGE up

	sudo ip link set $TAP_SERVER master $BRIDGE
	sudo ip link set $TAP1 master $BRIDGE
	sudo ip link set $TAP2 master $BRIDGE

	# Start the testbench
	qemu-system-i386 $QEMU_OPTIONS -m $RAM_SIZE_MB \
		-netdev tap,id=vlan0,ifname=$TAP_SERVER \
		-device e1000,netdev=vlan0,mac=52:54:00:00:00:01 \
		-netdev user,id=user0 -device e1000,netdev=user0 -hda server.cow &

	qemu-system-i386 $QEMU_OPTIONS -m $RAM_SIZE_MB \
		-netdev tap,id=vlan0,ifname=$TAP1 \
		-device e1000,netdev=vlan0,mac=52:54:00:00:00:02 \
		-netdev user,id=user0 -device e1000,netdev=user0 -hda client1.cow &

	qemu-system-i386 $QEMU_OPTIONS -m $RAM_SIZE_MB \
		-netdev tap,id=vlan0,ifname=$TAP2 \
		-device e1000,netdev=vlan0,mac=52:54:00:00:00:03 \
		-netdev user,id=user0 -device e1000,netdev=user0 -hda client2.cow &

	# Wait for background jobs to terminate
	wait

	# Interface teardown
	sudo ip tuntap del $TAP_SERVER mode tap
	sudo ip tuntap del $TAP1 mode tap
	sudo ip tuntap del $TAP2 mode tap

	sudo ip link del $BRIDGE

The most difficult part was getting the interface setup right, both from the
host and guest perspective. There's plenty of outdated and misleading guides
around the web.

The first thing to note is that qemu requires a device instance for each
declared netdev. To do so we have to add an id to each netdev
(<tt>-netdev id=netdev_id,netdev_type</tt>) and then attach a device to it like
so <tt>-device hw_type,netdev=netdev_id</tt>. As it can be seen this is done
twice, the first time for the <tt>tap</tt> device and the second for an
<tt>user</tt> device. Refer to the guide about qemu networking [\[3\]][3] for
details about the role of each device.

Then in order to get the network topology we like we have to create and bridge
together the tap interfaces at the host side. This has to be done before
starting the various virtual machines. The commands have been taken from
[\[4\]][4] and adapted a bit to the situation.

Each virtual machine is started as a background job (note the <tt>&</tt> at the
end) so before tearing down the network we issue a <tt>wait</tt> command which
halts the script until all the jobs terminate.

## References

1. [QEMU - ArchWiki -][1]
[1]: https://wiki.archlinux.org/index.php/QEMU "QEMU - ArchWiki -"

2. [LAN switching - Wikipedia -][2]
[2]: https://en.wikipedia.org/wiki/LAN_switching "LAN switching - Wikipedia -"

3. [Documentation/Networking - qemu project -][3]
[3]: http://wiki.qemu-project.org/Documentation/Networking "Documentation/Networking - qemu project -"

4. [Networking - KVM -][4]
[4]: https://www.linux-kvm.org/page/Networking "Networking - KVM -"

