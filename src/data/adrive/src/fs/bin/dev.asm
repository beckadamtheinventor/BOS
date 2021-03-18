	jr initdev_exe_main
	db "FEX",0
initdev_exe_main:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	ret z
	cp a,'-'
	jq nz,.info
	inc hl
	ld a,(hl)
	inc hl
	cp a,'h'
	jq z,.info
	cp a,'d'
	jq z,.deinitdev
	cp a,'i'
	jq z,.initdev
.info:
	ld hl,.info_string
	call bos.gui_Print
	jq .return
.initdev:
	push hl
	call bos.sys_InitDevice
	pop bc
	jq .return
.deinitdev:
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	call nc,bos.sys_DeinitDevice
	pop bc
.return:
	or a,a
	sbc hl,hl
	ret
.info_string:
	db $9,"dev -h : display this info",$A
	db $9,"dev -i file : init device",$A
	db $9,"dev -d file : deinit device",$A,0

