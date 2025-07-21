	jq mkdir_main
	db "FEX",0
mkdir_main:
	call ti._frameset0
	syscall _argv_1
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
	ld c,1 shl bos.fd_subdir
	push bc,hl
	call bos.fs_OpenFile
	jr nc,.fail
	call bos.fs_CreateDir
.return:
	or a,a
	sbc hl,hl
	jr .exit
.fail:
	ld hl,.string_fileexists
	call bos.gui_PrintLine
	ld hl,1
.exit:
	ld sp,ix
	pop ix
	ret
.string_fileexists:
	db $9,"File/Dir already exists.",$A,0
.info_string:
	db $9,"mkdir [dirname]",$A,0

