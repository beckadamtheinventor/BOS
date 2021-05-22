;@DOES Allocate 64 bytes of memory, 256-byte aligned.
;@INPUT void *sys_Malloc64Align256(void);
;@OUTPUT hl = malloc'd bytes. hl = 0 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc64Align256:
	ld hl,malloc_cache
	ld bc,4096
.loop:
	xor a,a
	cpir
	jq z,.checklen
	pop hl ;fail if no 0x00 (free blocks) found
.fail:
	or a,a
	sbc hl,hl
	scf
	ret
.checklen:
	dec hl
	ld a,l
	and a,256/32 - 1
	jq nz,.loop ;continue checking if found block not aligned
	inc hl
	ld a,(hl)
	or a,a
	jq nz,.loop

	ld de,-1 - malloc_cache ;dec hl \ ld de,-malloc_cache \ add hl,de
	add hl,de ; get offset from malloc_cache
	add hl,hl ; multiply by 32
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,bottom_of_malloc_RAM ;index malloc ram with offset*32
	add hl,de
	ex hl,de
	ld hl,(ScrapMem)
	ld a,(running_process_id)
	ld (hl),a
	inc hl

	pop bc
	dec bc
	ld a,b
	or a,c
	ex hl,de
	ret z
	ex hl,de
.mark_loop:
	ld (hl),$FF
	inc hl
	dec bc
	ld a,b
	or a,c
	jq nz,.mark_loop
	ex hl,de
	ret

