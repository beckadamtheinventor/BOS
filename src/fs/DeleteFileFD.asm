
;@DOES delete a file/directory given a file descriptor
;@INPUT bool fs_DeleteFile(void *fd);
;@OUTPUT true/nz if success, false/zf if fail
fs_DeleteFileFD:
	call ti._frameset0
	ld hl,(ix+6)
	jr fs_DeleteFile.entryfd
