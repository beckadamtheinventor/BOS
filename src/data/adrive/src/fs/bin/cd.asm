	jq cd_main
	db "FEX",0
cd_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr nz,.info
	syscall _argv_1
	ld a,(hl)
	cp a,'/'
	jq z,.abspath
	cp a,'.'
	jq nz,.not_dot
	inc hl
	cp a,(hl)
	jr nz,.return
	ld hl,bos.current_working_dir
	push hl
	call bos.fs_ParentDir
	push hl
	call bos.fs_OpenFile
	pop hl,bc
	jr c,.fail
	ld de,bos.current_working_dir
	ld bc,255
	ldir
	jr .return
.not_dot:
	push hl
	call bos.fs_AbsPath
	pop bc
.abspath:
	push hl
	call bos.fs_OpenFile
	pop de
	jr c,.fail
	ld bc,$B
	add hl,bc
	bit bos.fd_subdir,(hl)
	jr z,.fail
	push de
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
	jr z,.dont_put_fwd
	ld (hl),a
	inc hl
.dont_put_fwd:
	ld (hl),0
.return:
	xor a,a
	sbc hl,hl
.exit:
	ld sp,ix
	pop ix
	ret
.fail:
	ld hl,str_DirDoesNotExist
	call bos.gui_PrintLine
	ld hl,-2
	jr .exit
.info:
	ld hl,str_HelpDoc
	call bos.gui_Print
	jr .return
str_DirDoesNotExist:
	db $9,"Directory does not exist.",$A,0
str_HelpDoc:
	db $9,"Usage: CD [dir]",$A,0

