;@DOES Seek the read/write offset of a file descriptor.
;@INPUT int fsd_Seek(int pos, int origin, void** fd);
;@OUTPUT -1 if failed.
fsd_Seek:
	call ti._frameset0
	ld hl,(ix+12) ; fd
	call fsd_IsOpen.entryhl
	jr z,.fail
	ld bc,fsd_DataOffset
	add hl,bc
	ld bc,(ix+6) ; pos
	ld a,(ix+9) ; origin
	or a,a
	jr z,.seek_set
	dec a
	jr z,.seek_offset
	dec a
	jr nz,.fail
.seek_end:
assert fsd_DataLen = fsd_DataOffset-3
	dec hl
	dec hl
	dec hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	or a,a
	sbc hl,bc ; len - pos
	jr c,.fail ; fail if pos > len
	ex hl,de
	jr .ld_ihl_de_ex_hl_de_done
.seek_set:
	ld (hl),bc
	push bc
	pop hl
	jr .done
.seek_offset:
	ld de,(hl)
	ex hl,de
	add hl,bc
	ex hl,de
assert fsd_DataLen = fsd_DataOffset-3
	dec hl
	dec hl
	dec hl
	ld bc,(hl)
	ex hl,de
	or a,a
	sbc hl,bc
	jr nc,.fail ; fail if offset >= len
	add hl,bc
	ex hl,de
	inc hl
	inc hl
	inc hl
.ld_ihl_de_ex_hl_de_done:
	ld (hl),de
	ex hl,de
	db $01 ; ld bc,... dummify scf / sbc hl
.fail:
	scf
	sbc hl,hl
.done:
	pop ix
	ret
