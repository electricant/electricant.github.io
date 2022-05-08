# Buying No-Name SD Cards from China

## Introduction

So I finally decided to upgrade the self-built firewall/gateway for my home
internet connection [\[1\]][1]. I replaced an old Raspberry Pi Model B revision
1 (rpi B1) with a more powerful Pine A64. The transition was seamless, but I
found myself in need of a microSD card (the rpi B1 was using a full-size SD 
card). I resorted to a random class-2 [\[2\]][2] 4 GB card I had laying around
that worked beautifully.

With my internet connection working again I was left wondering: can I do better
with as little money as possible? What if I buy some random microSD card(s) on a
famous online retail service based in China?

Many articles (such as [\[3\]][3] and [\[4\]][4]) test the speed of microSD
cards  but none deal with no-name brands. Moreover, it turns out that buying
cheap from china may be a waste of money due to fake products [\[5\]][5]. But
how bad the situation really is? People usually buy high-capacity drives and end
up receiving 8-16 GB cards with a fake firmware that reports a different disk
size to the OS. I don't need much space for a standalone router thing. What if I
buy small microSD cards directly? Will they be fake nonetheless or will they be
the real thing? I found no answer to this question on the web so I decided to
run an experiment myself.

## The Funny microSD Cards under Test

On a whim I bought 4 microSD cards for the same price as one 8 GB card from a
reputable brand. Those cards have some the funniest names I've ever seen. Upon
arrival I also noticed that they are stamped with the most weird and
nonsensical approvals and speed ratings.

<figure>
	<a href="/res/img/sdcard_test/4-cards.jpg">
		<img src="/res/img/sdcard_test/4-cards.jpg"/>
	</a>
	<figcaption>
		The SD cards under test: Banoi_roox, Miomg, OUIO, ShanDian.
	</figcaption>
</figure>

As a bonus, I added to the test batch two more reasonable cards I acquired while
waiting for the shipment to arrive: a 4 GB card labelled 'eb-flash' and an
official Raspberry Pi 16 GB microSD card.

## The Test Script

To test the cards I used the f3 - Fight Flash Fraud tools [\[6\]][6] with a
custom script for repeatability. The usage guide [\[7\]][7] does not provide a
reference script for testing cards, so I had to make my own.

	#!/bin/sh -e
	#
	# sdcard_test.sh - test sdcards for fake/broken flash
	######################################################

	# WARNING! This script will eat your data. Set those variables correctly
	DEV="/dev/mmcblk0"
	MOUNTPOINT="./mnt"

	# Print some info on the device (will fail if $DEV does not exists)
	fdisk -l $DEV

	# Perform a destructive test on the device
	echo ""
	f3probe --destructive --time-ops $DEV

	# Get first partition name, format it, mount it and run read/write tests
	part=$(fdisk -l $DEV | awk 'END {print $1}')
	echo ""
	echo First partition is $part, formatting it to FAT32

	umount $part || true
	mkfs.fat -F32 $part

	echo ""
	echo Performing R/W test on $part

	mount $part $MOUNTPOINT
	f3write $MOUNTPOINT

	umount $MOUNTPOINT

	mount $part $MOUNTPOINT
	f3read $MOUNTPOINT

	# Done. Unmount
	umount $MOUNTPOINT

This script is run with <tt>sdcard_test.sh > cardname.log</tt> for each of the 
microSD card tested.

As the comments already explain, it does three things:
 1. Performs a destructive test with <tt>f3probe</tt>
 2. Identifies the first partition on the card and formats it to FAT32
 3. Since now we're sure the card is empty, it runs <tt>f3write</tt> and
    <tt>f3read</tt> to verify the whole capacity of the device 

The <tt>umount</tt> - <tt>mount</tt> incantations before <tt>f3read</tt> are
needed to force-flush the filesystem cache. This forces Linux to re-read from
the device directly to make sure we are verifying the actual data written.

<figure>
	<a href="/res/img/sdcard_test/testing.jpg">
		<img src="/res/img/sdcard_test/testing.jpg"/>
	</a>
	<figcaption>
		Using the test script.
	</figcaption>
</figure>

The procedure is thorough and takes 10-15 minutes for each SD card. However, it
ensures that I'll also catch broken or failing flash chips. The part taking 
most of the time is the execution of <tt>f3write</tt> and <tt>f3read</tt>.
This tests are needed because apparently, <tt>f3probe</tt> alone is not
sufficient to tell for sure if a card is not fake. At first I was confused, so I
opened an issue on the f3 repository [\[8\]][8] that led to a great explanation
on this matter by the f3 author himself.

## Test Results

Enough talking here is a table with the results:

<table>
	<thead>
		<tr>
			<th>SD card</th>
			<th>Capacity</th>
			<th>Verdict</th>
			<th>Write Speed [MB/s]</th>
			<th>Read Speed [MB/s]</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Banoi_roox</td>
			<td data-th="Capacity">7.44 GB</td>
			<td data-th="Verdict">PASS</td>
			<td data-th="Write Speed [MB/s]">8.37</td>
			<td data-th="Read Speed [MB/s]">17.14</td>
		</tr>
		<tr>
			<td>eb-flash</td>
			<td data-th="Capacity">3.69 GB</td>
			<td data-th="Verdict">PASS</td>
			<td data-th="Write Speed [MB/s]">3.9</td>
			<td data-th="Read Speed [MB/s]">18.34</td>
		</tr>
		<tr>
			<td>miomg</td>
			<td data-th="Capacity">14.88 GB</td>
			<td data-th="Verdict">PASS</td>
			<td data-th="Write Speed [MB/s]">9.01</td>
			<td data-th="Read Speed [MB/s]">18.47</td>
		</tr>
		<tr>
			<td>ouio</td>
			<td data-th="Capacity">7.5 GB</td>
			<td data-th="Verdict">FAIL</td>
			<td data-th="Write Speed [MB/s]">-</td>
			<td data-th="Read Speed [MB/s]">-</td>
		</tr>
		<tr>
			<td>Raspberry Pi</td>
			<td data-th="Capacity">14.75 GB</td>
			<td data-th="Verdict">PASS</td>
			<td data-th="Write Speed [MB/s]">5.91</td>
			<td data-th="Read Speed [MB/s]">18.4</td>
		</tr>
		<tr>
			<td>shandian</td>
			<td data-th="Capacity">7.5 GB</td>
			<td data-th="Verdict">PASS</td>
			<td data-th="Write Speed [MB/s]">4.51</td>
			<td data-th="Read Speed [MB/s]">16.21</td>
		</tr>
	</tbody>
</table>

To compare the SD cards against each other, I calculated two figures of merit:
 - the **speed score** is the product of the read and write speeds in MB/s
 - the **overall score** which is the speed score times the capacity in GB

The results are summarized in the following table (ordered by overall score). 
I have removed the OUIO SD card since it did not pass the test.

<table>
	<thead>
		<tr>
			<th>SD card</th>
			<th>Speed Score</th>
			<th>Overall Score</th>
		</tr>
	</thead><tbody>
		<tr>
			<td>miomg</td>
			<td data-th="Speed Score">166.4</td>
			<td data-th="Overall Score">2476.3</td>
		</tr><tr>
			<td>Raspberry Pi</td>
			<td data-th="Speed Score">108.7</td>
			<td data-th="Overall Score">1604</td>
		</tr><tr>
			<td>Banoi_roox</td>
			<td data-th="Speed Score">143.5</td>
			<td data-th="Overall Score">1067.4</td>
		</tr><tr>
			<td>shandian</td>
			<td data-th="Speed Score">73.1</td>
			<td data-th="Overall Score">548.3</td>
		</tr><tr>
			<td>eb-flash</td>
			<td data-th="Speed Score">71.5</td>
			<td data-th="Overall Score">263.9</td>
		</tr>
	</tbody>
</table>

All in all, the best card seems to be the miomg one. It is the fastest of the
lot and holds 16 GB of data. For the second prize I'd pick the Banoi\_roox SD
card which, even though is ranked third, it is faster than the stock Raspberry
Pi SD. However, I see what the Raspberry Pi Foundation did here. Application
responsiveness is tied to the read speed and their SD card heavily favors
reading compared to writing. Keep in mind though that the Banoi\_roox is almost
twice as fast in writing and its read speed is roughly 7% less than the rpi 
card. I did not test random IOPS while reading and writing because a
firewall/gateway is not a desktop computer so I do not really care about
application responsiveness.

## Conclusion

It seems common internet knowledge that fake and/or cheap SD cards from china
are bad. By betting on smaller-size cards you can increase your chances to
purchase a *working* card.  This is based on the assumption that the
higher-capacity cards are just the same as the smaller size ones reporting to
the OS a fake capacity. To test this assumption, I bought a few 8-16 GB cards
and put them through a test script that reads and writes test patterns on the
flash to make sure it's working as expected.

From my test results, I witnessed that 3/4 cards were actually working and
reported the correct capacity. One of those was even faster than an official
Raspberry Pi SD card of the same size. Read/write performance of the other cards
was as expected, considering the purchase price (~2-3 $ each).

I can now provide an answer to the questions:
 1. How bad are cheap small-size microSD cards? Not that bad actually, 25% bad
    I'd say ;).
 2. Can I trust such cards? For niche applications I'd say yes, provided that
    they are thoroughly tested before use.
 3. Will I do it again? Of course. It's worth it and now that I'm confident
    about the script, testing is not time consuming and requires minimal manual
    interaction.

P.S. I won't trust those SD cards with my family photos anyway.

P.P.S. I received full refund for the broken OUIO card. Always ask for a refund!

## References

<div class="references">
\[1\] [gateway_collection/atlas - electricant][1]
[1]: https://github.com/electricant/gateway_collection/tree/master/atlas

\[2\] [Speed Class | SD Association][2] 
[2]: https://www.sdcard.org/developers/sd-standard-overview/speed-class/

\[3\] [microSD Card Benchmarks | Raspberry Pi Dramble][3]
[3]: https://www.pidramble.com/wiki/benchmarks/microsd-cards

\[4\] [Raspberry Pi microSD card performance comparison - 2019 | Jeff Geerling][4]
[4]: https://www.jeffgeerling.com/blog/2019/raspberry-pi-microsd-card-performance-comparison-2019

\[5\] [Chinese micro SD card. : ExpectationVsReality][5]
[5]: https://www.reddit.com/r/ExpectationVsReality/comments/41vl2i/chinese_micro_sd_card/

\[6\] [f3 - Fight Flash Fraud][6]
[6]: https://fight-flash-fraud.readthedocs.io/en/stable/introduction.html

\[7\] [Usage - f3][7]
[7]: https://fight-flash-fraud.readthedocs.io/en/stable/usage.html

\[8\] [Fake card not detected by f3probe][8]
[8]: https://github.com/AltraMayor/f3/issues/180
</div>
