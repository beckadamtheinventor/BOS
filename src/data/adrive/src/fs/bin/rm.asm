	jq rm_main
	db "FEX",0
rm_main:
	pop bc,hl
	push hl,bc
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	pop iy
	bit fb_readonly, (iy+$B)
	jq nz,.fail_readonly
	bit fb_subdir, (iy+$B)
	jq nz,.fail_subdir
	push hl
	call bos.fs_DeleteFile
	pop bc
	xor a,a
	sbc hl,hl
	ret
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

