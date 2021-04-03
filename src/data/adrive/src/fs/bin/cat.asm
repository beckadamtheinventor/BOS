	jq cat_main
	db "FEX",0
cat_main:
	ld hl,-2
	call ti._frameset
	xor a,a
	ld (ix-1),a
	ld hl,(ix+6)
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
	ld hl,(hl)
	ex.s hl,de
	push de,hl
	call bos.gui_NewLine
	call bos.fs_GetSectorAddress
	pop bc,bc
	ld a,c
	or a,b
	jq z,.done ;nothing to print
.print_loop:
	ld a,(hl)
	inc hl
	ld (ix-2),a
	push hl,bc
	lea hl,ix-2
	call bos.gui_Print
	pop bc,hl
.print_next:
	dec bc
	ld a,b
	or a,c
	jq nz,.print_loop
	call bos.gui_NewLine
	jq .done
.fail_dir:
	ld hl,str_FailSubdir
	jq .print
.help:
	ld hl,str_CatHelp
.print:
	call bos.gui_Print
.done:
	xor a,a
	sbc hl,hl
	db $01
.fail:
	scf
	sbc hl,hl ;Cf is already unset
	ld sp,ix
	pop ix
	ret
str_CatHelp:
	db $9,"Usage: CAT [file]",$A,0
str_FailSubdir:
	db $9,"Cannot display directory as text.",$A,0

