	jq info_exe_main
	db "FEX",0
info_exe_main:
	call ti._frameset0
	syscall _argv_1
	push hl
	call bos.fs_OpenFile
	jq c,.fail
	ex (sp),hl
	call bos.fs_GetFDAttr
	bit bos.fd_subdir,a
	jr z,.not_a_directory
	ld hl,.str_is_directory
	call bos.gui_PrintLine
	jr .skip_file_size_display
.not_a_directory:
	ld hl,.string_filesize
	call bos.gui_Print
	call bos.fs_GetFDLen
	call bos.gui_PrintInt
	call bos.gui_NewLine
.skip_file_size_display:
	call bos.sys_GetExecTypeFD
	jr c,.not_executable
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	ld (bos.fsOP1),de
	ld (bos.fsOP1+3),a
	xor a,a
	ld (bos.fsOP1+4),a
	ld hl,.str_executable_type
	call bos.gui_Print
	ld hl,bos.fsOP1
	call bos.gui_PrintLine
.not_executable:
	ld hl,.string_file_stored_at
	call bos.gui_Print
	pop hl
	push hl
	or a,a
	sbc hl,hl
	add hl,sp
	ld de,bos.fsOP1
	push de
	syscall _int_to_hexstr
	pop hl
	call bos.gui_PrintLine
	call bos.fs_GetFDPtr
	ex (sp),hl
	jr c,.dont_display_content_location
	ld hl,.string_data_stored_at
	call bos.gui_Print
	sbc hl,hl
	add hl,sp
	ld de,bos.fsOP1
	push de
	syscall _int_to_hexstr
	pop hl
	call bos.gui_PrintLine
.dont_display_content_location:
	call bos.gui_NewLine
	or a,a
	sbc hl,hl
	db $01
.fail:
	scf
.done:
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.str_is_directory:
	db "Directory",0
.string_filesize:
	db "File Size: ",0
.str_executable_type:
	db "Exec type: ",0
.string_file_stored_at:
	db "Desc addr: 0x",0
.string_data_stored_at:
	db "Data addr: 0x",0
; .string_bin:
	; db "Binary file",0
; .string_text:
	; db "Text file",0
; .string_fex:
	; db "Flash EXecutable",0
; .string_rex:
	; db "RAM EXecutable",0

