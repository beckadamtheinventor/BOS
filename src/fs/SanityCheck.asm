;@DOES check the filesystem for errors. Attempts to fix if there are any. If that fails, it reformats the filesystem.
;@DESTROYS All
fs_SanityCheck:
	ld hl,fs_filesystem_address
	ld a,$FF
	ld bc,$010000 ;if there's 64k of unwritten data here, the filesystem hasn't been formatted yet
.check_loop_1:
	cpi
	jp po,fs_Format
	jr z,.check_loop_1
	ld hl,fs_cluster_map_file
	push hl
	call fs_OpenFile
	pop bc
	jq c,.corrupted ;if the cluster map is not found, assume filesystem is corrupted.
	
	
	ret
.corrupted:
	ld hl,string_FilesystemCorrupt
	call gui_DrawConsoleWindow
.corrupted_wait:
	call sys_WaitKeyCycle
	cp a,9
	jq nz,.corrupted_wait
	call fs_Format
	ld hl,string_FilesystemReformatted
	call gui_Print
.finished_wait:
	call sys_WaitKeyCycle
	cp a,9
	jq nz,.finished_wait
	ret


