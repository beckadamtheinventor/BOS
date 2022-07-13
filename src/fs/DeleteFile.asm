
;@DOES delete a file/directory given a path
;@INPUT bool fs_DeleteFile(const char *name);
;@OUTPUT true/nz if success, false/zf if fail
fs_DeleteFile:
	call ti._frameset0

; open the file to be deleted and check if it's writable
	; ld hl,(ix+6)
	; call fs_CheckWritable.entryfd
	; dec a
	; jq nz,.fail
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	jr c,.fail
	pop bc
.entryfd:
	ex hl,de
	ld hl,fsentry_fileattr
	add hl,de
	bit fd_link, (hl)
	jr nz,.delete_descriptor
	push de ; free the file's data if it's not a link file
	bit fd_subdir, (hl)
	jr nz,.free_directory
.free_and_delete_descriptor:
	call fs_Free
	pop de
.delete_descriptor:
; mark the file descriptor as deleted
	call sys_FlashUnlock
	xor a,a
	call sys_WriteFlashA
	dec de
	call sys_FlashLock

	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	ld sp,ix
	pop ix
	ret

.free_directory:
	call fs_GetFDPtr
.free_directory_loop:
	push hl
.next_entry_in_dir:
	ld a,(hl)
	inc a
	jr z,.end_of_dir_reached
	dec a
	jr z,.skip_freed_entry
.delete_entry_in_dir:
	push hl
	call fs_DeleteFileFD
	pop hl
	jr z,.fail
.skip_freed_entry:
	ld bc,fs_file_desc_size
	add hl,bc
	jr .next_entry_in_dir
.end_of_dir_reached:
	pop hl
	push hl
	ld bc,fsentry_filesector
	add hl,bc
	ld de,(hl)
	; as long as 0 < bc <= sector_size, this will free the sector.
	call fs_Free.entrydebc
	pop hl
	; we don't need to check for the existence of the directory extender byte, only where it points to.
	ld bc,fs_directory_size+fsentry_filesector-fs_file_desc_size
	add hl,bc
	ld hl,(hl)
	ld a,h
	and a,l
	inc a
	jr z,.free_and_delete_descriptor ; directory extender does not point to another directory
	call fs_GetSectorAddress.entry
	jr .free_directory_loop
