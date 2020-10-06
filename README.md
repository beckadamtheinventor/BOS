# BOS
An Operating system (WIP) for the TI-84+CE family (eZ80) graphing calculators

# Building
See this link to locate the required version of fasmg to build this project.
https://github.com/CE-Programming/toolchain/tree/fatdrvce/tools/fasmg

# Building on Linux/Mac/Unix
Run the provided `build.sh` file in bash, and the binary will be in the `bin` folder.
Note for Mac users: You may have to install bash and run build.sh with bash

# Building on Windows
Run the provided `build.bat` file, and the binary will be in the `bin` folder.


# Documentation
`bos.inc` docs https://beckadamtheinventor.github.io/BOS/
`ti84pceg.inc` is somewhat lacking in documentation, and many of the routines are not applicable in BOS.
However, syscall addresses below 0x020000 are bootcode calls and can be used as normal.


# Contributing
Currently this OS is lacking in system executables. Said programs go into the `/src/data/adrive/src` directory.
These programs must be appended to `/src/data/adrive/src/main.asm` as well as built in both build.bat and build.sh.

For example, say you were to add a program called "program"

## Step 1
Appending `build.bat`/`build.sh`. Note that this must be placed before the last two lines.
```
fasmg src/program.asm obj/program.bin
```

## Step 2
The next two steps are different depending on whether your program runs from RAM or from flash.

### In RAM
Appending `src/main.asm`. Note that this must be placed before `end fs_fs` and not within any `fs_file`/`end fs_file` blocks.
```
fs_file "PROGRAM", "EXE", f_readonly+f_system
	file "../obj/program.bin"
end fs_file
```

header of `src/program.asm`
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

### In flash
Appending `src/main.asm`
```
fs_file "PROGRAM", "EXE", f_readonly+f_system
	include 'src/program.asm'
end fs_file
```

header of `src/program.asm`
```
;Note this file is directly included in the filesystem binary,
;and therefore does not need to include anything because they have already been included prior to this file being assembled.
;It should also not start with an org directive, because it is running from wherever it is in the filesystem.
;Also, it cannot write to itself from flash. This will cause a crash.
;Flash Executables cannot use libload libraries either, due to those requiring direct writing to the program.
	jr main ;jump to code
	db "FEX",0 ;header to mark this program as a Flash EXecutable
main:
	;your code here
```

## Step 3
Build BOS using the provided build.bat or build.sh files in the *root* directory of the repo.

## Using libload
BOS comes pre-loaded with some libload libraries. Some of these libraries are unstable at the moment.
+ fatdrvce (stable, subject to change)
+ fileioc (unstable)
+ graphx (stable)
+ srldrvce (empty at the moment)
+ usbdrvce (stable, subject to change)

Using these libraries requires your program to run from *RAM* as a *REX* (RAM) executable.

### the libload loader
Put the following code somewhere in your executable.
```
load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.notfound
	ld bc,0
	push bc,hl
	call bos.fs_GetClusterPtr
	pop bc,bc
	ld   de,libload_relocations ;pointer to libraries / routines to load.
	ld   bc,.notfound
	push   bc
	jp   (hl)
.notfound:
	xor   a,a
	inc   a
	ret
```

### including a libload library
All libraries and routines must be located in the libload_relocations section.
The library include header starts with the byte 0xC0 ($C0) and is followed by the null-terminated library name, which is then followed by a version byte.
Note that the version byte for each library is different. Since BOS comes pre-loaded with the latest libload libraries, it is unlikely that you will see a version error.
Headers for libload libraries included in BOS:
+ fatdrvce: db $C0,"FATDRVCE",0,1
+ fileioc: db $C0,"FILEIOC",0,6
+ graphx: db $C0,"GRAPHX",0,11
+ usbdrvce: db $C0,"USBDRVCE",0,0
Note that fileioc is currently unstable in BOS.

Example usage:
```
libload_relocations:
	db $C0,"GRAPHX",0,11
gfx_SetColor:
	jp 2*3
gfx_ZeroScreen:
	jp 76*3

; end of relocations marker. This is important.
	xor a,a
	pop hl
	ret

```

