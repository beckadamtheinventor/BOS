	jq mkfile_main
	db "FEX",0
mkfile_main:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	jq z,.info
	cp a,'-'
	jq nz,.create
.info:
	ld hl,.info_string
	call bos.gui_Print
	jq .return
.create:
	ld bc,0
	push bc,bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
.return:
	or a,a
	sbc hl,hl
	ret
.fail:
	ld hl,mkdir_main.string_fileexists
	call bos.gui_Print
	ld hl,1
	ret
.info_string:
	db $9,"mkfile -h",$A
	db $9,"mkfile [filename]",$A,0

