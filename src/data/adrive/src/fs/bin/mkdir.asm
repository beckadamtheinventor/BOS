	jq mkdir_main
	db "FEX",0
mkdir_main:
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
	ld c,1 shl bos.fd_subdir
	push bc,hl
	call bos.fs_CreateDir
	pop bc,bc
.return:
	or a,a
	sbc hl,hl
	ret
.fail:
	ld hl,.string_fileexists
	call bos.gui_Print
	ld hl,1
	ret
.string_fileexists:
	db $9,"File/Dir already exists.",$A,0
.info_string:
	db $9,"mkdir -h",$A
	db $9,"mkdir [dirname]",$A,0

