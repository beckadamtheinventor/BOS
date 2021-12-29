	jq rm_main
	db "FEX",0
rm_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr nz,.info
	call osrt.argv_1
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	pop iy
	bit fb_readonly, (iy + bos.fsentry_fileattr)
	jq nz,.fail_readonly
	bit fb_subdir, (iy + bos.fsentry_fileattr)
	jq nz,.fail_subdir
.delete:
	push hl
	call bos.fs_DeleteFile
	pop bc
	jr .return_0
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.return_0:
	xor a,a
	sbc hl,hl
	jr .exit
; .maybe_fail_subdir:
	; ld de, (iy + bos.fsentry_filelen)
	; ld a,d
	; or a,a
	; jq nz,.fail_subdir
	; ld h,a
	; ld l,49
	; ex.s hl,de
	; sbc hl,de
	; jq c,.delete
.fail_subdir:
	ld hl,.string_subdir
	jq .error_print
.fail_readonly:
	ld hl,.string_readonly
.error_print:
	call bos.gui_PrintLine
	ld hl,1
.exit:
	ld sp,ix
	pop ix
	ret
.infostr:
	db "rm file",0
.string_readonly:
	db $9,"Read only file cannot be removed.",0
.string_subdir:
	db $9,"Cannot remove subdirectory.",0

