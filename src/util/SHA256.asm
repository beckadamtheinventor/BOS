;@DOES Compute a SHA256 hash for some data, writing the 32-byte result to a buffer.
;@INPUT void util_SHA256(void* buffer, void* data, unsigned int len);
;@OUTPUT Nothing.
;@NOTE: Unlocks and locks flash.
util_SHA256:
	call ti._frameset0
	call sys_FlashUnlock
	call .writeblock
	ld a,$0A
	jr .entry
.loop:
	call .writeblock
	ld a,$0E
.entry:
	ld (de),a
	ld hl,(ix+12)
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.loop
.done:
	ld hl,ti.mpShaData
	ld de,(ix+6)
	ld bc,32
	ldir
	pop ix
	jp sys_FlashLock

.writeblock:
	ld hl,(ix+12)
	ld bc,64
	or a,a
	sbc hl,bc
	jr nc,.over_64
	ld c,l
	ld b,h
	or a,a
	sbc hl,hl
.over_64:
	ld (ix+12),hl
	ld hl,(ix+9)
	ld de,ti.mpShaData
	ldir
	ld (ix+9),hl
assert ti.shaCtrl = 0
	ld e,c
	ret
