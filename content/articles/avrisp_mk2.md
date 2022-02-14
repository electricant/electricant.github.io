# Using the AVRISP mkII With GNU/Linux

## Introduction

The [AVRISP mk2](http://www.atmel.com/tools/AVRISPMKII.aspx) is an USB
programmer for Atmel 8-bit microcontrollers with ISP (ATtiny, ATmega), PDI
(ATxmega) or TPI (smaller ATtiny) interface.

It can be used either with:

 * [Atmel Studio](http://www.atmel.com/tools/ATMELSTUDIO.aspx) (Windows only)
 * [Arduino Playground](http://playground.arduino.cc/) (Windows, MAC, Linux)
 * [avrdude](http://www.nongnu.org/avrdude/) (virtually any OS, directly from the command line).

Please note that the Arduino Playground uses avrdude under the hood to burn the
firmware onto microcontrollers if the arduino bootloader is not used.

This guide is about building, installing and using avrdude on GNU/Linux.  Due to
[a bug](https://savannah.nongnu.org/bugs/index.php?40831) in the most recent
version of avrdude in order for the AVRISP mk2 to be recognized and used the
program must be manually built after applying a patch to the source code.

## Installing Required Packages

First of all we are going to install some helper programs and libraries. This
process varies depending on your distribution of choice.

The packages listed below are the bare minimum required to build avrdude from
source. You may also like to install `gcc-avr binutils-avr avr-libc` in order to
compile the firmware for Atmel microcontrollers.

### Debian/Ubuntu/Linux Mint

As root run:

	# apt-get install wget bison automake autoconf flex gcc libelf-dev
	libusb-dev libusb-1.0-0-dev libftdi-dev libftdi1-dev`

### Red Hat/Centos/Fedora

As root run:

	# yum install wget bison automake autoconf flex gcc patch
	elfutils-libelf-devel libusb-devel libftdi-devel`

## Compiling and Installing avrdude

First of all we need to prepare a working directory to store the source code,
place it where you like:

	$ mkdir avrdude; cd avrdude

Get the source code for the latest version (at the time of writing it is
version 6.2):

	$ wget -qO- http://download.savannah.gnu.org/releases/avrdude/avrdude-6.2.tar.gz | tar zxv --strip-components 1

Download and apply the patch to fix the bug (the patch is for version 6.2):

	$ wget -qO- https://savannah.nongnu.org/support/download.php?file_id=32171 | patch

We are now ready to build!

	$ ./bootstrap && ./configure && make -j2

If no error is received avrdude is ready to rock with the AVRISP mk2. Before
installing you can try if everything works by running the command
`$ ./avrdude -v` which should display the current version and the build date.

You can now run avrdude directly from the build directory or better still
install it system-wide. To do so you need root privileges. Run the following
commands as root:

	# make install && cp ./avrdude /usr/bin/

Now you are done. In the following section some useful avrdude commands are
listed. Try them to see if everything was configured correctly.

## Testing Communication

Connect the programmer to a microcontroller. Assuming you are using an ATmega16
the command you should runt to test the connection is:

	$ avrdude -p m16 -c avrispmkII -P usb

If something goes wrong ensure that [udev was configured correctly](http://www.droids-corp.org/blog/html/2013/05/14/olimex_avr_isp_mk2.html)
and the electrical connections are OK.

To see the list of devices supported by avrdude issue: `avrdude -p ?`

A sample programming line for avrdude would be:

	avrdude -p m328p -P usb -c avrispmkII -e -U flash:w:test.hex:i

If none of the above commands report any error you are ready to go. Happy
programming.
