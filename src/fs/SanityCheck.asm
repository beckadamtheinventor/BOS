;@DOES check the filesystem for errors. Attempts to fix if there are any. If that fails, it reformats the filesystem.
;@DESTROYS All
fs_SanityCheck:
	ld a,($040000)
	inc a
	ret nz
	jq fs_Format ;if there's a 0xFF here, the filesystem hasn't been initialized yet.
	; jq c,.corrupted ;if we failed, either fs is corrupted or OS is corrupted
	; ret
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


