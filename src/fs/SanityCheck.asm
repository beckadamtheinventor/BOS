;@DOES check the filesystem for errors. Attempts to fix if there are any. If that fails, it reformats the filesystem.
;@DESTROYS All
fs_SanityCheck:
	ld a,($040000)
	inc a
	jp z,fs_Format ;if there's a 0xFF here, the filesystem hasn't been initialized yet.
	ld hl,fs_cluster_map_file
	push hl
	call fs_OpenFile
	ld bc,7040
	push bc
	ld c,5 ;system, readonly file.
	push bc
	call c,fs_CreateFile ;if the cluster map is not found, try to create and initialize it.
	pop bc
	ld bc,$C
	add hl,bc
	ld hl,(hl)
	ex (sp),hl
	call fs_InitClusterMap
	pop bc
	jq c,.corrupted ;if we failed, either fs is corrupted or OS is corrupted
	push bc
	call fs_GetSectorAddress
	ld a,(hl)
	cp a,$FE
	call nz,fs_InitClusterMap
	pop bc
	pop bc
	jq c,.corrupted ;if we failed, either fs is corrupted or OS is corrupted
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


