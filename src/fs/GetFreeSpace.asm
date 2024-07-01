;@DOES Return remaining free space in the filesystem
;@INPUT int fs_GetFreeSpace(void);
;@OUTPUT filesystem remaining space in bytes
fs_GetFreeSpace:
	ld de,fs_cluster_map
	ld bc,fs_cluster_map.len
	call fs_IsOSBackupPresent
	jr z,.reentry
	; if an OS backup is present, we should not allocate within its bounds.
	; basically cluster map length minus root directory cluster minus the number of clusters reserved to the OS backup
	ld bc, fs_cluster_map.len - (($3B0000-fs_os_backup_location) shr fs_sector_size_bits) - fs_root_dir_lba
.reentry:
	or a,a
	sbc hl,hl
.loop:
	ld a,(de)
	inc de
	inc a
	inc a
	jq z,.next
	inc hl
.next:
	dec bc
	ld a,b
	or a,c
	jq nz,.loop
	jq fs_MultByBytesPerSector
	; ld b,fs_sector_size_bits
; .multloop:
	; add hl,hl
	; djnz .multloop
	; ret
