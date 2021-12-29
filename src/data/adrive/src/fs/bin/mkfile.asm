	jq mkfile_main
	db "FEX",0
mkfile_main:
	call ti._frameset0
	call osrt.argv_1
	ld a,(hl)
	or a,a
	jq z,.info
	cp a,'-'
	jq nz,.create
.info:
	ld hl,.info_string
	call bos.gui_PrintLine
	jq .return
.create:
	ld bc,0
	push bc,bc,hl
	call bos.fs_OpenFile
	jr nc,.fail
	call bos.fs_CreateFile
.return:
	or a,a
	sbc hl,hl
	jr .exit
.fail:
	ld hl,mkdir_main.string_fileexists
	call bos.gui_PrintLine
	ld hl,1
.exit:
	ld sp,ix
	pop ix
	ret
.info_string:
	db $9,"mkfile -h",$A
	db $9,"mkfile [filename]",$A,0

