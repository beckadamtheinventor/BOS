
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr bpm_outer_main
	db "REX",0
bpm_outer_main:
	push ix
	call bpm_main
	sbc hl,hl
	pop ix
	ret
bpm_main:
	call libload_load
	ret c

	ld hl,str_ConfigPath
	ld c,$10
	push bc,hl
	call bos.fs_CreateDir
	pop bc,bc
	
	ld ix,3
	add ix,sp
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.info
	ld de,str_Install
	ld bc,str_Install.len
	push bc,hl,de
	call ti._strncmp
	add hl,bc
	or a,a
	sbc hl,bc
	pop de,hl,bc
	jq z,bpm_install
	ld de,str_Remove
	ld bc,str_Remove.len
	push bc,hl,de
	call ti._strncmp
	add hl,bc
	or a,a
	sbc hl,bc
	pop de,hl,bc
	jq z,bpm_remove
	ld de,str_Purge
	ld bc,str_Purge.len
	push bc,hl,de
	call ti._strncmp
	add hl,bc
	or a,a
	sbc hl,bc
	pop de,hl,bc
	jq z,bpm_purge
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
	or a,a
	ret
.infostr:
	db "BOS Package Manager v1.0",$A
	db $9,"bpm install [-bru] package",$A
	db $9,"Install a package. -b uses PC bridge to connect to server or local.",$A
	db "-r uses remote server. -u installs package from usb",$A
	db $9,"bpm remove package",$9,"Uninstall a package.",$A
	db $9,"bpm purge package",$9,"Uninstall a package and",$A
	db "remove all data associated with it.",$A
	db 0

bpm_install:
	ld bc,str_Install.len
	add hl,bc
	ld a,(hl)
	cp a,'-'
	jq nz,.network_package_install
	inc hl
	ld a,(hl)
	cp a,'f'
	jq nz,.network_package_install
	inc hl
	inc hl
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq bpm_process_data

.network_package_install:
	
	ret

bpm_remove:
	ld bc,str_Remove.len
	add hl,bc
	ret

bpm_purge:
	ld bc,str_Purge.len
	add hl,bc
	ret

bpm_process_data:
	ret


libload_load:
	ld hl,.name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	ret c
	ld bc,.fail
	push bc
	ld de,.relocations
	jp (hl)
.fail:
	scf
	ret
.name:
	db "/lib/LibLoad.dll",0
.relocations:
	
	pop hl
	xor a,a
	ret

str_Install:
	db "install "
.len:=$-.
str_Remove:
	db "remove "
.len:=$-.
str_Purge:
	db "purge "
.len:=$-.

