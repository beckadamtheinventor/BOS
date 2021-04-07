# BOS
An Operating system (WIP) for the TI-84+CE family (eZ80) graphing calculators, with the aim of being freely distributable.

# A note on ".rom" Files
BOS ".rom" files are for use on CEmu [https://ce-programming.github.io/CEmu/] *only* and should not be installed on physical hardware. If you want BOS on physical hardware, use the ".8xp" file. (See installation for details)
Assuming only noti-ez80 bootcode and BOS are on the image, (which is the case if downloaded from this repository) it may be freely distributed between individuals. However I do not permit rehosting of the image, without prior permission from myself. (Adam "beckadamtheinventor" Beckingham)
If you are getting the rom image from another author, read the author's provided LICENSE file (usually a plain text file without an extension) for further guidance on distribution of the ROM image.

# Installing BOS to Hardware
Before installing BOS, know that it is very much incomplete and lacks many features that TI-OS has.

*IMPORTANT NOTE* BOS will not work on any python edition calculator! BOS will *only* work on the TI-84+CE and TI-83 premium CE calculators. Additionally, BOS will not work on any calculator revision M or higher. Check the last character of the serial number on the back of the calculator. If it's "M" or higher, BOS will not work.
BOS will also fail to work on a non-patched bootcode 5.3.0 or higher due to boot-time OS verification. See BootSwap [https://github.com/commandblockguy/bootswap] for details on disabling OS verification. *DO NOT INSTALL ANY CUSTOM BOOTCODES!!! YOU COULD PERMABRICK YOUR CALCULATOR!* Only use the "disable OS verification" option!

Before installing BOS, note that it will erase all memory on your calculator! Both RAM and Archive! Make sure to back up your calculator's files before installing BOS!
In order to install BOS on a calculator:
Download "BOSOS.8xp" from the releases page, transfer it to your calculator using TI-Connect CE or TiLP, then run it from the homescreen. You should see a formatting screen pop up.

# Building
BOS requires the CE C toolchain version 9+ in order to build.

Link to CE C toolchain:
https://github.com/CE-Programming/toolchain

Once the toolchain is installed, run `build.py` with python 3.7 or higher.
If you would prefer to use the build script via the command line, type `python3 build.py -h` for a list of options.


# Updating BOS
When building BOS there is a file that can be used to reinstall/update BOS from a FAT32-formatted USB flash drive.
Send `bin/BOSUPDTR.BIN` to the root directory of a FAT32 formatted flash drive, and plug it into the calculator.
Then from the console, type: `updater`. The calc will read from `BOSUPDTR.BIN` and execute it from UserMem.
It is essentially the same program that initially installs BOS. However this program will not modify BOS's filesystem, but when there is an update to any of the OS binaries, the filesystem will need to be reset. See "recovery options" for details


# BOS Recovery Options
From BOS's homescreen, press the "Y=" key. (also known as "F1") If this doesn't go to the recovery menu, press "clear" to go back, then "F1" again.
From there, you can reboot, attempt filesystem recovery, reset the filesystem, and uninstall BOS.


# Documentation
`bos.inc` docs https://beckadamtheinventor.github.io/BOS/
OS calls in `ti84pceg.inc` are mostly unimplemented and most of them will likely not be implemented.
However, syscall addresses below 0x020000 are bootcode calls and can be used as normal.


# Contributing
Currently this OS is lacking in system executables. Said programs go into the `/src/data/adrive/src` directory.
BOS is especially in need of a text editor.
System executables must be referenced in `/src/data/adrive/src/main.asm` as well as built in both build.bat and build.sh.
If you decide to make a program for BOS that you feel should be included in the OS binaries, feel free to make a pull request! I'll link them into the filesystem and provide credit.


# Installing programs on BOS
Threre are three ways that BOS programs can be installed, and it depends on how the author chooses to package.

Programs written for BOS can be transferred to BOS via a FAT32 formatted USB drive, or packaged with the ROM image for use with CEmu. [https://ce-programming.github.io/CEmu/]
In any case, read the README file (chances are the author has provided one) and look for how to install on BOS.

## If you do not see a ".bpk" file
Place the ".bin" file onto the drive, open BOS's USB program receiver, enter the path to the file transferred to the USB drive, enter the file you want the program to be written to within BOS's filesystem, and wait for the transfer to complete.

## If you see a ".bpk" file
Place the ".bpk" file and the "bpk/" directory on the drive, and run the bpk loader with the path to the ".bpk" file on the drive. Once the transfer is complete, the program should show up in the "/usr/bin/" directory under the same name as the ".bpk" file. (likely wity the ".exe" extension)

# Writing C programs for BOS
I am currently working on a toolchain fork that targets BOS: [https://github.com/beckadamtheinventor/toolchain/] Under the llvm-bos branch: [https://github.com/beckadamtheinventor/toolchain/tree/llvm-bos]
Many programs that compile on the standard CE C toolchain will compile in the BOS C toolchain, but steer clear from using OS routines; many of them are not implemented in BOS and will cause crashes and other unexpected issues.
As well, do not directly write directly to variables in BOS! All files are currently stored in flash/archive, so attempting to write to them directly will almost certainly cause a crash.

# Writing Assembly Programs for BOS
The header of your program is different depending if it is meant to run from RAM/USB, or flash.

## If your program runs from RAM or USB
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

## If Your Program Runs from Flash
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


# Using libload
BOS comes pre-loaded with the standard libload libraries.
+ fatdrvce (stable, subject to change)
+ fontlibc (stable)
+ fileioc (semi-stable)
+ graphx (stable)
+ keypadc (stable)
+ srldrvce (stable, subject to change)
+ usbdrvce (stable, subject to change)

There are three ways to use libload in BOS, depending on where your program runs from.

## Method A
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

## Method B
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

## Method C
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
+ fileioc: `db $C0,"FILEIOC",0,6`
+ graphx: `db $C0,"GRAPHX",0,11`
+ keypadc: `db $C0,"KEYPADC",0,2`
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


