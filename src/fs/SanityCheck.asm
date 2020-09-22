;@DOES check the filesystem for errors. Attempts to fix if there are any. If that fails, it reformats the filesystem.
;@DESTROYS All
fs_SanityCheck:
	ld a,(fs_drive_a + fs_boot_magic_1)
	cp a,$55
	jq nz,.check_errors
	ld a,(fs_drive_a + fs_boot_magic_2)
	cp a,$AA
	jq nz,.check_errors
	
	
	ret
.check_errors:
;	ld hl,str_CheckingFilesystem
;	call gfx_DrawWarningWindow
;	ld hl,fs_drive_a
	
	
	
	jp fs_Format
