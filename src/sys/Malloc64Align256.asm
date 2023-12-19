;@DOES Allocate 64 bytes of memory, 256-byte aligned.
;@INPUT void *sys_Malloc64Align256(void);
;@OUTPUT hl = malloc'd bytes. hl = 0 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc64Align256:
	ld de, (64/malloc_block_size) shl 8 or (256/malloc_block_size - 1)
; input e = alignment mask, d = desired block size in blocks
.entry:
	ld hl,malloc_cache
	ld bc,malloc_cache_len
.loop:
	xor a,a
	cpir
	jr z,.checklen
	pop hl ;fail if no 0x00 (free blocks) found
.fail:
	or a,a
	sbc hl,hl
	scf
	ret
.checklen:
	dec hl
	ld a,l
	and a,e
	jq nz,.loop ;continue checking if found block not aligned
	ld (ScrapMem),hl
	ld b,d
	inc hl
	ld a,(hl)
	or a,a
	jr nz,.loop
	jr sys_Malloc.return_and_mark_cache_hl
