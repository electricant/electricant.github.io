# Notes on Using AVRDUDE

## Introduction

[avrdude](http://www.nongnu.org/avrdude/) is the standard command-line utility
to program Atmel/Microchip AVR microcontrollers.  It supports multiple
programmers, including:
- **serialUPDI** (for new ATtiny/mega0/1-series with UPDI interface)  
- **AVRISP mkII** (ISP/PDI/TPI programmer, see Appendix A for legacy setup)  

This article collects practical usage notes, examples, and troubleshooting tips
when working with <tt>avrdude</tt> on GNU/Linux.

## Example Session with SerialUPDI (ATtiny816)

         Using Port                    : /dev/ttyUSB0                           
         Using Programmer              : serialupdi                             
         Overriding Baud Rate          : 230400                                 
         AVR Part                      : ATtiny816                              
         RESET disposition             : dedicated                              
         RETRY pulse                   : SCK                                    
         Serial program mode           : yes                                    
         Parallel program mode         : yes

                                          Block Poll               Page                       Polled                                                           
           Memory Type Alias    Mode Delay Size  Indx Paged  Size   Size #Pages MinW  MaxW   ReadBack                                                           
           ----------- -------- ---- ----- ----- ---- ------ ------ ---- ------ ----- ----- ---------
           fuse0       wdtcfg      0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse1       bodcfg      0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse2       osccfg      0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse4       tcd0cfg     0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse5       syscfg0     0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse6       syscfg1     0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse7       append      0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuse8       bootend     0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           fuses                   0     0     0    0 no          9   10      0     0     0 0x00 0x00                                                           
           lock                    0     0     0    0 no          1    1      0     0     0 0x00 0x00                                                           
           tempsense               0     0     0    0 no          2    1      0     0     0 0x00 0x00                                                           
           signature               0     0     0    0 no          3    1      0     0     0 0x00 0x00                                                           
           prodsig                 0     0     0    0 no         61   61      0     0     0 0x00 0x00                                                           
           sernum                  0     0     0    0 no         10    1      0     0     0 0x00 0x00                                                           
           osccal16                0     0     0    0 no          2    1      0     0     0 0x00 0x00                                                           
           osccal20                0     0     0    0 no          2    1      0     0     0 0x00 0x00                                                           
           osc16err                0     0     0    0 no          2    1      0     0     0 0x00 0x00                                                           
           osc20err                0     0     0    0 no          2    1      0     0     0 0x00 0x00                                                           
           data                    0     0     0    0 no          0    1      0     0     0 0x00 0x00                                                           
           userrow     usersig     0     0     0    0 no         32   32      0     0     0 0x00 0x00                                                           
           eeprom                  0     0     0    0 no        128   32      0     0     0 0x00 0x00                                                           
           flash                   0     0     0    0 no       8192   64      0     0     0 0x00 0x00 

Detected memory areas:

 * Fuses (fuse0 … fuse8, syscfg, osccfg, etc.)
 * Lock bits
 * Signature / production signature / serial number
 * User row (usersig)
 * EEPROM (128 bytes)
 * Flash (8 KB)

## Common avrdude Options

	-p <partno>      Specify AVR device; `-p ?` lists all supported devices
	-c <programmer>  Specify programmer; `-c ?` lists all supported programmers
	-P <port>        Connection (e.g. /dev/ttyUSB0, usb)
	-b <baudrate>    Override serial baudrate
	-U <mem>:op:file[:fmt]  Perform memory operation
	-e               Erase chip before programming
	-t               Start interactive terminal
	-v               Verbose (repeat for more detail)
	-q               Quell progress output
	-T <terminal cmd line> Run terminal line when it is its turn

### Memory Operations (-U)

* <tt>flash:r|w|v:<file></tt> - read/write/verify flash
* <tt>eeprom:r|w|v:<file></tt> - read/write/verify EEPROM
* <tt>fuses:r|w:<file></tt> - access fuse bytes
* <tt>userrow:r|w:<file></tt> - read/write the USERROW

### File formats (:fmt)

* <tt>:a</tt> - auto-detect
* <tt>:b</tt> - 0b-binary byte list
* <tt>:d</tt> - decimal byte list
* <tt>:e</tt> - ELF
* <tt>:h</tt> - 0x-hexadecimal byte list
* <tt>:i</tt> - Intel Hex
* <tt>:I</tt> - Intel Hex with comments
* <tt>:m</tt> - in-place immediate
* <tt>:o</tt> - octal byte list
* <tt>:r</tt> - raw binary
* <tt>:R</tt> - R byte list
* <tt>:s</tt> - Motorola S-Record

## Practical Examples

### Read EEPROM

	avrdude -v -p t816 -c serialupdi -P /dev/ttyUSB0 -U eeprom:r:-:h

### Read USERROW

	avrdude -v -p t816 -c serialupdi -P /dev/ttyUSB0 -U userrow:r:-:h

### Interacrive shell

	avrdude -v -pt816 -cserialupdi -P /dev/ttyUSB0 -t

	dump userrow

	write userrow 0 0xBABBE0
	0000  e0 bb ba 00 ff ff ff ff  ff ff ff ff ff ff ff ff  |................|
	0010  ff ff ff ff ff ff ff ff  ff ff ff ff ff ff ff ff  |................|

	write userrow 0 0xBA, 0xBB, 0xE0, 0x00
	0000  ba bb e0 00 ff ff ff ff  ff ff ff ff ff ff ff ff  |................|
	0010  ff ff ff ff ff ff ff ff  ff ff ff ff ff ff ff ff  |................|

	flush   : synchronise flash and EEPROM cache with the device

	dump eeprom
	dump flash
	dump fuses

	erase flash; erase eeprom; flush

The shell session can also be condensed as a single <tt>-T</tt> command invocation:

	avrdude -v -pt816 -cserialupdi -P /dev/ttyUSB0 -T 'write userrow 0 0x1 0 255 16; flush'

## Appendix A – AVRISP mkII Setup Guide (Legacy)

The following section is preserved from an older tutorial. It describes how to
build avrdude with support for the AVRISP mkII on GNU/Linux. It remains useful
for reference if you are using older ATmega/ATtiny devices with ISP or PDI
interfaces.

### Introduction

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

### Installing Required Packages

First of all we are going to install some helper programs and libraries. This
process varies depending on your distribution of choice.

The packages listed below are the bare minimum required to build avrdude from
source. You may also like to install `gcc-avr binutils-avr avr-libc` in order to
compile the firmware for Atmel microcontrollers.

#### Debian/Ubuntu/Linux Mint

As root run:

	# apt-get install wget bison automake autoconf flex gcc libelf-dev
	libusb-dev libusb-1.0-0-dev libftdi-dev libftdi1-dev`

#### Red Hat/Centos/Fedora

As root run:

	# yum install wget bison automake autoconf flex gcc patch
	elfutils-libelf-devel libusb-devel libftdi-devel`

### Compiling and Installing avrdude

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

### Testing Communication

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

