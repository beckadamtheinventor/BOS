;@DOES Return a random 8-bit number.
;@INPUT uint8_t sys_Random8();
;@OUTPUT A = number
;@DESTROYS HL, B, AF
sys_Random8:
	ld hl,(random_source_ptr)
	ld a,(hl)
	ld b,119
.loop:
	add a,(hl)
	xor a,(hl)
	djnz .loop
	ret
