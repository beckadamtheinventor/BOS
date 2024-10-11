# BOS
An Operating system (WIP) for the TI-84+CE family (eZ80) graphing calculators, with the aim of being freely distributable.


# Eye Candy
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap6.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap7.gif)

![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap2.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap3.gif)

![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap4.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap5.gif)

![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap8.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap9.gif)



# A note on ".rom" Files
BOS ".rom" files are for use on CEmu [https://ce-programming.github.io/CEmu/] *only* and should not be installed on physical hardware. If you want BOS on physical hardware, use the ".8xp" file. (See installation for details)
Assuming only noti-ez80 bootcode and BOS are on the image, (which is the case if downloaded from this repository) it may be freely distributed between individuals. However, I do not permit rehosting of the image, without prior permission from myself. (Adam "beckadamtheinventor" Beckingham)
If you are getting the rom image from another author, read the author's provided LICENSE file (usually a plain text file without an extension) for further guidance on distribution of the ROM image.


# Downloads
Check the [releases](https://github.com/beckadamtheinventor/BOS/releases) page or [artifacts](https://github.com/beckadamtheinventor/BOS/tree/master/artifacts) for bleeding-edge builds.


# Installing BOS to Hardware
Before installing BOS, know that it is very much incomplete and lacks many features that TI-OS has.

*IMPORTANT NOTE* BOS will not work on any python edition calculator! BOS will *only* work on the TI-84+CE and TI-83 premium CE calculators. Additionally, BOS will not work on any calculator revision M or higher. Check the last character of the serial number on the back of the calculator. If it's "M" or higher, BOS will not work.
BOS will also fail to work on a non-patched bootcode 5.3.0 or higher due to boot-time OS verification. Patching your bootcode can be dangerous if done wrong, and unfortunately there is no longer a repo up containing the program necessary to patch your bootcode. You're on your own for now if your bootcode version is 5.3.0 or higher.

Before installing BOS, note that it will erase all memory on your calculator! Both RAM and Archive! Make sure to back up your calculator's files before installing BOS!
In order to install BOS on a calculator:
Download "BOSOS.8xp" and "BOSOSpt2.8xv" from the releases tab, transfer it to your calculator using TI-Connect CE or TiLP, then run it from the homescreen. You should see a formatting screen pop up.
If you do not get a formatting screen, but get an "invalid OS" error or the like, then your calc's bootcode needs to be patched or is incompatible with custom OSs. See above.


# Building
BOS requires the CE C toolchain version 12.0 or higher and the BOS toolchain extension.
Python 3.7 or higher is required to build includes and documentation.

Link to CE C toolchain:
https://github.com/CE-Programming/toolchain
Link to BOS toolchain files:
https://github.com/beckadamtheinventor/toolchain-bos

Once both toolchains are installed, run `make` from your system's command line while in the repo's root directory.

# Transferring programs
There are a few ways that programs can be transferred.
Programs can be packaged with the ROM image for use with CEmu, [https://ce-programming.github.io/CEmu/], transferred from a FAT32 formatted USB drive, or sent via serial-connect.
If the program is written for BOS, read the README file that came with the program, (chances are the author has provided one) and look for install instructions.


## FAT32 USB drive

You will need a USB-mini male to USB female OTG adapter (or equivalent) to connect a USB drive to the calc.
Once you have the drive, run the program titled "msd" (path on-calc: `/opt/bin/msd`), plug it in, and use enter to select files.


## serial-connect

You will need the cable that came with the calculator (or equivalent) to use serial-connect, as well as the PySerial Python module on your PC.
Run the program titled "srl" (path on-calc: `/opt/bin/srl`), plug the cable into your PC and calc, then run (with python) the file titled `serial-connect.py` in the BOS source folder.
From there, you should get an interactive prompt PC-side, with instructions.


# Updating BOS
In order to update BOS, you will need to either reinstall TIOS, transfer the updater via a FAT32 formatted USB flash drive, or using the serial-connect.
Updating by USB is over 3x faster than doing a fresh install however, and should be preferred if possible.
To uninstall, press the reset button found on the back of the calculator, (quickly) open the recovery menu by pressing F1/y= and press del.
The update files are BOSUPDTR.BIN and BOSOSPT2.BIN, the install files are BOSOS.8xp and BOSOSpt2.8xv.


# BOS Recovery Options
From BOS's homescreen, press the "Y=" key. (also known as "F1") If this doesn't go to the recovery menu, press "clear" to go back, then "F1" again.
From there, you can reboot, attempt filesystem recovery / run filesystem cleanup, reset the filesystem, uninstall BOS, or run emergency shell.
If you still cannot access the recovery menu, press the reset button found on the back of the calculator while pressing the recovery menu key.
If that still doesn't work, hold on+2nd+del and press reset, then reinstall TIOS using TI-Connect CE or TiLP.

## Emergency shell
`extract.all` Extract the filesystem without formatting.
`extract.os` Extract the OS filesystem sector.
`extract.rot` Extract the root directory.
`extract.opt` Extract files and directories that would be extracted on a fresh format.
`format` Format the filesystem

# Contributing
If there's a feature you want to see in BOS, you found a bug, or have any questions or concerns, feel free to make an [issue](https://github.com/beckadamtheinventor/BOS/issues).
Additionally, if you make a program for BOS that you feel should be included in the OS binaries, open an issue or make a pull request.
Made an enhancement? Optimized some code? Fixed a clerical error? Improved the UI? Make a pull request and I'll take a look.


# Documentation for developers

## BOS OS Call Documentation
`bos.inc` documentation for OS calls can be found here: https://beckadamtheinventor.github.io/BOS/
However, OS calls found in `ti84pceg.inc` within the 0x020124-0x0221F8 range are effectively unusable in BOS at this time.
Call addresses within the 0x000000-0x00063C range (adresses below 0x020000) are bootcode calls and can be used as normal.


## Writing C programs for BOS
I am currently working on a toolchain fork that targets BOS: [https://github.com/beckadamtheinventor/toolchain-bos]
This toolchain is installed alongside an existing CEdev toolchain. Simply dowload/clone the repo and copy the `bos` folder into your toolchain installation.
Many programs that compile on the standard CE C toolchain will compile in the BOS C toolchain, but steer clear from using most `os_` routines; many of them are not implemented in BOS and will cause crashes and other unexpected issues.
As well, do not directly write directly to files in BOS! All files are stored in flash/archive, so attempting to write to them directly will almost certainly cause a crash.


## Writing Assembly Programs for BOS
NOTE: This guide will be heavily modified if/when I implement an ELF-derived executable and linkable format.
The header of your program will be different depending if it is meant to run from RAM/USB, or flash.

### If your program runs from RAM/USB (usermem)
header:
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

format ram executable
	;your code here
```


### If Your Program Runs from Flash
Note that this kind of program requires a method of referencing itself and cannot write directly to itself.
The program will not know where it is being run from until runtime.
When the program is run it is passed arguments in a string on the stack, and a pointer to itself in HL.
header:
```
	jr main ;jump to code
	db "FEX",0 ;header to mark this program as a Flash EXecutable
main:
	;your code here
```


## Using libload
BOS comes pre-loaded with the standard libload libraries, including the USB drivers.
+ fatdrvce (stable, subject to change)
+ fontlibc (stable)
+ fileioc (volatile, do not use at the moment)
+ graphx (stable)
+ keypadc (stable)
+ msddrvce (stable, subject to change)
+ srldrvce (stable, subject to change)
+ usbdrvce (stable, subject to change)

There are three ways to use libload in BOS, depending on where your program runs from.
When writing an assembly program using `boslibloader.inc` you can use routines from any library loaded with the `libload` macro. The macros will handle the rest.

### Method A
Program runs from RAM, default libload settings, optionally displaying libload messages.
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'
include 'include/boslibloader.inc'

format ram executable
	libload load
	ret nz
	libload graphx ; or another standard libload library
	;your code here
```


### Method B
Program runs from RAM, libload uses malloc'd memory, libload does not display messages.
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'
include 'include/boslibloader.inc'

format ram executable
	libload load LIBLOAD_USEMALLOC
	ret nz
	libload graphx ; or another standard libload library
	; your code here
```


### Method C
Program runs from flash, libload uses malloc'd memory, libload does not display messages.
This is an advanced method!
This method is the most difficult to use due to it requiring either relocation or offsets of the program file.
To use this method, make sure the libload relocations are not stored in flash and BC = $aa5aa5 before the jump to libload.
In addition, the program will likely need a way to reference itself due to it not knowing where it's run from until runtime.

