	jq rm_main
	db "FEX",0
rm_main:
	pop bc,hl
	push hl,bc
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	pop iy
	bit fb_readonly, (iy + $B)
	jq nz,.fail_readonly
	bit fb_subdir, (iy + $B)
	jq nz,.maybe_fail_subdir
.delete:
	pop bc,hl
	push hl,bc,hl
	call bos.fs_DeleteFile
	pop bc
	xor a,a
	sbc hl,hl
	ret
.maybe_fail_subdir:
	ld de, (iy + $E)
	ld a,d
	or a,a
	jq nz,.fail_subdir
	ld h,a
	ld l,49
	ex.s hl,de
	sbc hl,de
	jq c,.delete
.fail_subdir:
	ld hl,.string_subdir
	jq .error_print
.fail_readonly:
	ld hl,.string_readonly
.error_print:
	call bos.gui_PrintLine
	ld hl,1
	ret
.string_readonly:
	db $9,"Read only file cannot be removed.",$A,0
.string_subdir:
	db $9,"Cannot remove subdirectory.",$A,0

