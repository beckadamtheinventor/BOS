explorer_create_new_file:
	ld hl,$FF0000
	ld de,str_NewFileNamePrompt
	call explorer_input_file_name
	ld bc,0
	push bc,bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
	ret

explorer_delete_file:
	ld hl,str_ConfirmDelete
	ld bc,display_margin_bottom-9
	ld de,display_margin_left+11
	push bc,de,hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,ti.skEnter
	jq nz,explorer_main
	ld hl,(explorer_dirname_buffer)
	ld de,(current_working_dir)
	push hl,de
	call bos.fs_JoinPath
	ex (sp),hl
	call bos.fs_DeleteFile
	call bos.sys_Free ; free file path allocated by fs_JoinPath
	pop bc,bc
	jq explorer_dirlist

explorer_cut_file:
	db $3E
explorer_copy_file:
	xor a,a
	ld (explorer_cut_file_indicator),a
	ld hl,(explorer_dirname_buffer)
	push hl
	call ti._strlen
	inc hl
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	ld (bos.copy_buffer),de
	ldir
	ret

explorer_paste_file:
	ld hl,(bos.copy_buffer)
	add hl,bc
	xor a,a
	sbc hl,bc
	ret z
	or a,(hl)
	ret z

	push hl
	call bos.fs_BaseName
	push hl
	ld de,str_DestinationFilePrompt
	call explorer_input_file_name
	or a,a
	jq z,.cancel
	ex (sp),hl
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_ParentDir
	ex (sp),hl
	call bos.fs_JoinPath ; join(dirname(dest), basename(src))
	ld (.destfile),hl
	call bos.sys_Free ; free memory allocated by parentdir
	pop bc
	call bos.sys_Free ; free memory allocated by basename
	pop bc,bc

	ld hl,0
.destfile:=$-3
	add hl,bc
	or a,a
	sbc hl,bc
	ret z ; return if failed to get destination file name
	ld a,0
explorer_cut_file_indicator:=$-1
	or a,a
	jq z,.copy
	push hl,bc
	call bos.fs_MoveFile
	scf
	sbc hl,hl
	ld (bos.copy_buffer),hl
.cancel:
	pop bc,bc
	ret
.copy:
	push hl,bc
	call bos.fs_GetFilePtr ; returns bc=len, hl=ptr, a=attr
	pop de,de
	push bc,hl
	ld c,a
	push bc,de
	call bos.fs_WriteNewFile ; copy file in copy buffer to the current working directory
	pop bc,bc,bc,bc
	ret

explorer_input_file_name:
	xor a,a
	ld b,a
	mlt bc
	ld (bos.curcol),a
	ld a,23
	ld (bos.currow),a
	push de
	ld de,explorer_temp_name_input_buffer
	ld c,14
	ldir
	pop hl
	call bos.gui_PrintString
	ld hl,explorer_temp_name_input_buffer
	ld bc,14
	push bc,hl
.paste_wait_input:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.paste_wait_input
	pop hl,bc
	ret

explorer_temp_name_input_buffer:
	db 14 dup 0
