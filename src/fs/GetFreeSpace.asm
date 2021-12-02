;@DOES Return remaining free space in the filesystem
;@INPUT int fs_GetFreeSpace(void);
;@OUTPUT filesystem remaining space in bytes
fs_GetFreeSpace:
	ld de,fs_cluster_map
	ld bc,fs_cluster_map.len
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
	ld b,9
.multloop:
	add hl,hl
	djnz .multloop
	ret
