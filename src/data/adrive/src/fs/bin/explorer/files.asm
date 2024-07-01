
explorer_create_new_file:
	ld hl,new_file_option_strings
	jq explorer_taskbar_menu

explorer_create_new_file_file:
	ld hl,$FF0000
	ld de,str_NewFileNamePrompt
	call explorer_input_file_name
	ld bc,0
	push bc,bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
explorer_create_new_file_link:
explorer_create_new_file_image:
	ret

explorer_create_new_file_dir:
	ld hl,$FF0000
	ld de,str_NewDirNamePrompt
	call explorer_input_file_name
	ld c,1 shl bos.fd_subdir
	push bc,hl
	call bos.fs_CreateDir
	pop bc,bc
	ret


explorer_delete_file:
; try not to delete root by mistake
	ld hl,(explorer_dirname_buffer)
	xor a,a
	sbc hl,hl
	ret z ; dirname is null
	or a,(hl)
	ret z ; dirname is empty string
	inc hl
	sub a,'/'
	or a,(hl)
	ret z ; dirname is "/"

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
	push de
	push hl
	ld bc,256
	push bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,.malloc_failed
	ld (explorer_temp_name_input_buffer),de
	ldir
.malloc_failed:
	pop hl
	ret c
	ld bc,188
	push bc
	ld c,b
	push bc,hl
	call gfx_PrintStringXY
	pop bc,bc
	ld hl,256
	ex (sp),hl
	ld hl,(explorer_temp_name_input_buffer)
	push hl
	xor a,a
	ld (ti.curCol),a
	ld a,22
	ld (ti.curRow),a
.paste_wait_input:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.paste_wait_input
	pop hl,bc
	or a,1
	ret
