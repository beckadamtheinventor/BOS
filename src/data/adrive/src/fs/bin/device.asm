	jr initdev_exe_main
	db "FEX",0
initdev_exe_main:
	call ti._frameset0
	ld a,(ix+6)
	dec a
	jr z,.info
	syscall _argv_1
	ld a,(hl)
	cp a,'-'
	jr nz,.info
	inc hl
	ld a,(hl)
	cp a,'h'
	jr z,.info
	ld b,a
	inc hl
	ld a,(hl)
	inc hl
	cp a,' '
	jr nz,.info
	ld a,(hl)
	or a,a
	jr z,.info
	ld a,b
	cp a,'d'
	jr z,.deinitdev
	cp a,'i'
	jr z,.initdev
.info:
	ld hl,.info_string
	call bos.gui_PrintLine
	or a,a
	sbc hl,hl
	jr .exit
.initdev:
	push hl
	call bos.sys_InitDevice
	pop bc
	jr .exit
.deinitdev:
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	call nc,bos.sys_DeinitDevice
	pop bc
	jr .exit
.exit:
	ld sp,ix
	pop ix
	ret
.info_string:
	db $9,"device -h : display this info",$A
	db $9,"device -i file : init device",$A
	db $9,"device -d file : deinit device",$A,0

