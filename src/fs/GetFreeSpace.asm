;@DOES Return remaining free space in the filesystem
;@INPUT int fs_GetFreeSpace(void);
;@OUTPUT filesystem remaining space in bytes
;@NOTE will sanity check the filesystem if cluster map file is not found or has zero length.
fs_GetFreeSpace:
	ld bc,fs_cluster_map_file
	push bc
	call fs_GetFilePtr
	pop de
	jq c,fs_SanityCheck
	ld a,b
	or a,c
	jq z,fs_SanityCheck
	ex hl,de
	sbc hl,hl
.loop:
	ld a,(de)
	inc de
	or a,a
	jq z,.increment
	inc a
	jq nz,.next
.increment:
	inc hl
.next:
	dec bc
	ld a,b
	or a,c
	jq nz,.loop
	ld b,9
.multloop:
	add hl,hl
	djnz .multloop
	ret
