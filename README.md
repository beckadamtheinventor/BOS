# BOS
An Operating system (WIP) for the TI-84+CE family (eZ80) graphing calculators, with the aim of being freely distributable.


# Eye Candy
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap2.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap3.gif)

![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap4.gif)
![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap5.gif)

![](https://raw.githubusercontent.com/beckadamtheinventor/BOS/master/cap/cap6.gif)


# A note on ".rom" Files
BOS ".rom" files are for use on CEmu [https://ce-programming.github.io/CEmu/] *only* and should not be installed on physical hardware. If you want BOS on physical hardware, use the ".8xp" file. (See installation for details)
Assuming only noti-ez80 bootcode and BOS are on the image, (which is the case if downloaded from this repository) it may be freely distributed between individuals. However, I do not permit rehosting of the image, without prior permission from myself. (Adam "beckadamtheinventor" Beckingham)
If you are getting the rom image from another author, read the author's provided LICENSE file (usually a plain text file without an extension) for further guidance on distribution of the ROM image.


# Installing BOS to Hardware
Before installing BOS, know that it is very much incomplete and lacks many features that TI-OS has.

*IMPORTANT NOTE* BOS will not work on any python edition calculator! BOS will *only* work on the TI-84+CE and TI-83 premium CE calculators. Additionally, BOS will not work on any calculator revision M or higher. Check the last character of the serial number on the back of the calculator. If it's "M" or higher, BOS will not work.
BOS will also fail to work on a non-patched bootcode 5.3.0 or higher due to boot-time OS verification. See BootSwap [https://github.com/commandblockguy/bootswap] for details on disabling OS verification. Warning: *DO NOT INSTALL ANY CUSTOM BOOTCODE UNLESS YOU ABSOLUTELY KNOW WHAT YOU ARE DOING!!! YOU COULD PERMANENTLY TURN YOUR CALCULATOR INTO A PAPERWEIGHT!* Only use the "disable OS verification" option!

Before installing BOS, note that it will erase all memory on your calculator! Both RAM and Archive! Make sure to back up your calculator's files before installing BOS!
In order to install BOS on a calculator:
Download "BOSOS.8xp" and "BOSOSpt2.8xv" from the releases tab, transfer it to your calculator using TI-Connect CE or TiLP, then run it from the homescreen. You should see a formatting screen pop up.
If you do not get a formatting screen, but get an "invalid OS" error or the like, then your calc's bootcode needs to be patched or is incompatible with custom OSs. See above.


# Building
BOS requires the CE C toolchain version 9.2 or higher and the BOS toolchain extension.
Python 3.7 or higher is required to build includes and documentation.

Link to CE C toolchain:
https://github.com/CE-Programming/toolchain
Link to BOS toolchain files:
https://github.com/beckadamtheinventor/toolchain-bos

Once both toolchains are installed, run `make` from your system's command line while in the repo's root directory.


# Updating BOS
In order to update BOS at this time you will need to either reinstall TIOS, or install the update via a FAT32 formatted USB flash drive.
Updating by USB is over 3x faster than doing a fresh install however, and should be preferred if possible.
To uninstall, press the reset button found on the back of the calculator, open the recovery menu by pressing F1/y= and press del.


# BOS Recovery Options
From BOS's homescreen, press the "Y=" key. (also known as "F1") If this doesn't go to the recovery menu, press "clear" to go back, then "F1" again.
From there, you can reboot, attempt filesystem recovery / run filesystem cleanup, reset the filesystem, and uninstall BOS.
If you still cannot access the recovery menu, press the reset button found on the back of the calculator while pressing the recovery menu key.
If that still doesn't work, hold on+2nd+del and press reset, then reinstall TIOS using TI-Connect CE or TiLP.


# Contributing
If there's a feature you want to see in BOS, you found a bug, or have any questions or concerns, feel free to make an [issue](https://github.com/beckadamtheinventor/BOS/issues).
Additionally, if you make a program for BOS that you feel should be included in the OS binaries, open an issue or make a pull request.
Made an enhancement? Optimized some code? Fixed a clerical error? Improved the UI? Make a pull request and I'll take a look.


# Installing programs on BOS
There are a few ways that BOS programs can be installed.
Programs written for BOS can be packaged with the ROM image for use with CEmu, [https://ce-programming.github.io/CEmu/], via BOS Package manager, (COMING SOON) or transferred from a FAT32 formatted USB drive.
In any case, read the README file that came with the program, (chances are the author has provided one) and look for install instructions.


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
NOTE: This guide will be heavily modified once I implement an ELF-derived executable and linkable format.
The header of your program is different depending if it is meant to run from RAM/USB, or flash.


### If your program runs from RAM or USB
header:
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem ;the address this executable runs from
	jr main ;jump to code
	db "REX",0 ;header to mark this program as a Ram EXecutable.
main:
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


### Method A
Program runs from RAM, default libload settings, optionally displaying libload messages.
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem ;the address this executable runs from
	jr init ;jump to code
	db "REX",0 ;header to mark this program as a Ram EXecutable.
init:
	call load_libload
	jq z,main
	scf
	sbc hl,hl
	ret

load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	jr c,.notfound
	ld   de,libload_relocations ;pointer to libraries / routines to load. Same format as libload programs written for TIOS
	ld   bc,.notfound
	push   bc
	ld	bc,$aa55aa ;remove this line to silence libload messages
	jp   (hl)
.notfound:
	xor   a,a
	inc   a
	ret

main:
	;your code here
```


### Method B
Program runs from RAM, libload uses malloc'd memory, libload does not display messages.
```
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem ;the address this executable runs from
	jr init ;jump to code
	db "REX",0 ;header to mark this program as a Ram EXecutable.
init:
	call load_libload
	jq z,main
	scf
	sbc hl,hl
	ret

load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	jr c,.notfound
	ld   de,libload_relocations ;pointer to libraries / routines to load. Same format as libload programs written for TIOS
	ld   bc,.notfound
	push   bc
	ld	bc,$aa5aa5
	jp   (hl)
.notfound:
	xor   a,a
	inc   a
	ret

main:
	;your code here
```


### Method C
Program runs from flash, libload uses malloc'd memory, libload does not display messages.
This is an advanced method!
This method is the most difficult to use due to it requiring either relocation or offsets of the program file.
To use this method, make sure the libload relocations are not stored in flash and BC = $aa5aa5 before the jump to libload.
In addition, the program will likely need a way to reference itself due to it not knowing where it's run from until runtime.


## Libload Relocations
All libraries and routines to be used in the program must be passed along to libload in DE before the jump to libload.
The library include header starts with the byte 0xC0 ($C0) and is followed by the null-terminated library name, which is then followed by a version byte.
Note that since BOS comes pre-loaded with some of the latest libload libraries, it is unlikely that you will see a version error.
Headers for libload libraries included in BOS:
+ fatdrvce: `db $C0,"FATDRVCE",0,1`
+ fontlibc: `db $C0, "FONTLIBC",0,2`
+ fileioc: `db $C0,"FILEIOC",0,7`
+ graphx: `db $C0,"GRAPHX",0,11`
+ keypadc: `db $C0,"KEYPADC",0,2`
+ msddrvce: `db $C0,"MSDDRVCE",0,1`
+ srldrvce: `db $C0,"SRLDRVCE",0,0`
+ usbdrvce: `db $C0,"USBDRVCE",0,0`

Example usage:
```
libload_relocations:
	db $C0,"GRAPHX",0,11
gfx_SetColor:
	jp 2*3
gfx_ZeroScreen:
	jp 76*3

; end of relocations marker. This is important, and is executed by libload on successful load.
	xor a,a
	pop hl ;pop error handler
	ret

```


