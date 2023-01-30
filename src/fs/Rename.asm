;@DOES rename a file
;@INPUT void *fs_Rename(const char *old_name, const char *new_name);
;@OUTPUT file descriptor. returns zero if failed
fs_Rename:
	ld hl,-22
	call ti._frameset
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	jr c,.fs_RenameFile.fail
	ld (ix-3),hl ; save old file descriptor
	ld hl,(ix+9)
	ex (sp),hl
	call fs_OpenFile
	jr nc,fs_RenameFile.fail ; fail if destination file exists
	call fs_ParentDir
	push hl
	call nc,fs_OpenFile
.fs_RenameFile.fail:
	jr c,fs_RenameFile.fail ; fail if parent dir of destination file does not exist
	ld (ix-22),hl
	pop bc
	call sys_Free.entryhl ; free malloc'd parent dir name
	; destination file name should be the first item on the stack
	jr fs_RenameFile._entry

