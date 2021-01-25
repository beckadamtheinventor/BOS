	jq cat_main
	db "FEX",0
cat_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.help
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	ld bc,$B
	add hl,bc
	bit bos.fd_subdir,(hl)
	jq nz,.fail_dir
	inc hl
	ld de,(hl)
	inc hl
	inc hl
	ld bc,(hl)
	push bc,de
	call bos.gui_NewLine
	call bos.fs_GetSectorAddress
	pop bc,de
	ld bc,0
	ld c,e
	ld b,d
	ld a,c
	or a,b
	jq z,.done ;nothing to print
.print_loop:
	ld a,(hl)
	inc hl
	push bc
	call bos.gui_PrintChar
	pop bc
.print_next:
	dec bc
	ld a,b
	or a,c
	jq nz,.print_loop
.done:
	sbc hl,hl ;Cf is already unset
	ret
.fail_dir:
	ld hl,str_FailSubdir
	jq .print
.help:
	ld hl,str_CatHelp
.print:
	call bos.gui_Print
	xor a,a
	sbc hl,hl
	ret
.fail:
	scf
	sbc hl,hl
	ret
str_CatHelp:
	db $9,"Usage: CAT [file]",$A,0
str_FailSubdir:
	db $9,"Cannot display directory as text.",$A,0

