	jq cd_main
	db "FEX",0
cd_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.help
	cp a,'/'
	jq z,.abspath
	cp a,'.'
	jq nz,.not_dot
	inc hl
	cp a,(hl)
	jq nz,.return
	ld hl,bos.current_working_dir
	push hl
	call bos.fs_ParentDir
	push hl
	call bos.fs_OpenFile
	pop hl,bc
	jq c,.fail
	ld de,bos.current_working_dir
	ld bc,255
	ldir
	jq .return
.not_dot:
	push hl
	call bos.fs_AbsPath
	pop bc
.abspath:
	push hl
	call bos.fs_CheckDirExists
	pop hl
	jq c,.fail
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld de,bos.current_working_dir
	ldir
	ex hl,de
	dec hl
	ld a,'/'
	cp a,(hl)
	inc hl
	jq z,.dont_put_fwd
	ld (hl),a
	inc hl
.dont_put_fwd:
	ld (hl),0
.return:
	xor a,a
	sbc hl,hl
	ret
.fail:
	ld hl,str_DirDoesNotExist
	call bos.gui_PrintLine
	ld hl,-2
	ret
.help:
	ld hl,str_HelpDoc
	call bos.gui_Print
	jq .return
str_DirDoesNotExist:
	db $9,"Directory does not exist.",$A,0
str_HelpDoc:
	db $9,"Usage: CD [dir]",$A,0

