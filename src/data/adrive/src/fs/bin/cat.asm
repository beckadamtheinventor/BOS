	jr cat_main
	db "FEX",0
cat_main:
	ld hl,bos.return_code_flags
	set bos.bSilentReturn,(hl)
	ld hl,-3
	call ti._frameset
	xor a,a
	ld (ix-1),a
	ld hl,(ix+6)
	ld bc,2
	add hl,bc
	or a,a
	sbc hl,bc
	jp c,.help
	call osrt.argv_1
	ld a,(hl)
	or a,a
	jp z,.help
	cp a,'-'
	jr nz,.print_file
	inc hl
	ld a,(hl)
	cp a,'c'
	jr z,.copy_file
.print_file:
	push hl
	call bos.gui_NewLine
	call bos.fs_GetFilePtr
	pop de
	jq c,.fail
	bit bos.fd_subdir,a
	jq nz,.fail_dir
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
	call bos.gui_NewLine
	jq .done
.copy_file:
	inc hl
	inc hl
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq c,.fail
	bit bos.fd_subdir,a
	jq nz,.fail_dir
	ld a,c
	or a,b
	jq nz,.read_file_into_buffer
	ld hl,$FF0000
	jq .return
.read_file_into_buffer:
	inc bc
	inc bc
	ld a,(bos.running_process_id)
	ld (ix-3),a
	push hl,bc
	ld a,1
	ld (bos.running_process_id),a
	call bos.sys_Malloc
	pop bc,de
	ld a,(ix-3)
	ld (bos.running_process_id),a
	jq c,.fail
	dec bc
	dec bc
	push hl
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ex hl,de
	ldir
	pop hl
	jq .return
.fail_dir:
	ld hl,str_FailSubdir
	jq .print
.help:
	ld hl,str_CatHelp
.print:
	call bos.gui_Print
.done:
	xor a,a
	db $3E
.fail:
	scf
	sbc hl,hl ;cf is unset if jumped to .done, else it's set from .fail
.return: ;return value in HL
	ld sp,ix
	pop ix
	ret
str_CatHelp:
	db "Usage:",$A
	db $9,"cat file     print file contents",$A
	db $9,"cat -c file  copy file into malloc'd buffer",$A,0
str_FailSubdir:
	db $9,"Cannot display directory as text.",$A,0

